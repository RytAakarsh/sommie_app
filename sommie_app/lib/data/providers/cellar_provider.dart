import 'package:flutter/material.dart';
import '../models/wine_model.dart';
import '../services/wine_service.dart';
import '../../core/utils/storage_helper.dart';

class CellarProvider extends ChangeNotifier {
  List<WineModel> _wines = [];
  String? _userId;
  static const int maxFreeBottles = 6;
  final WineService _wineService = WineService();

  List<WineModel> get wines => _wines;
  int get wineCount => _wines.length;
  int get remainingFreeSpots => maxFreeBottles - _wines.length;
  bool get canAddMore => _wines.length < maxFreeBottles;

  CellarProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await StorageHelper.getUser();
      if (user != null) {
        _userId = user.userId;
        print('✅ CellarProvider: User loaded: ${user.name} (ID: ${_userId})');
        await loadWines();
      } else {
        print('❌ CellarProvider: No user found - clearing wines');
        _wines = [];
        notifyListeners();
      }
    } catch (e) {
      print('❌ CellarProvider: Error loading user: $e');
      _wines = [];
    }
  }

  Future<void> loadWines() async {
    if (_userId == null) {
      print('❌ CellarProvider: Cannot load wines - No userId');
      _wines = [];
      notifyListeners();
      return;
    }
    
    try {
      // First try to load from local storage
      final localWines = await StorageHelper.getCellarWines(_userId!);
      
      if (localWines.isNotEmpty) {
        _wines = localWines;
        print('✅ CellarProvider: Loaded ${_wines.length} wines from local storage');
      } else {
        // If no local wines, try to fetch from server
        print('🔄 No local wines, fetching from server...');
        final serverWines = await _wineService.getUserWines(_userId!);
        
        if (serverWines.isNotEmpty) {
          _wines = serverWines;
          // Save to local storage
          await StorageHelper.saveCellarWines(_userId!, _wines);
          print('✅ CellarProvider: Loaded ${_wines.length} wines from server');
        } else {
          _wines = [];
          print('✅ No wines found for user');
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ CellarProvider: Error loading wines: $e');
      _wines = [];
      notifyListeners();
    }
  }

  // Call this method after login to refresh wines
  Future<void> refreshAfterLogin() async {
    final user = await StorageHelper.getUser();
    if (user != null) {
      _userId = user.userId;
      await loadWines();
    }
  }

  Future<void> addWine(WineModel wine) async {
    if (_userId == null) {
      print('❌ CellarProvider: Cannot add wine - No userId');
      
      // Try to reload user
      await _loadUser();
      
      if (_userId == null) {
        throw Exception('User not authenticated');
      }
    }
    
    try {
      // Check limit for free users
      final user = await StorageHelper.getUser();
      if (user?.plan != 'PRO' && _wines.length >= maxFreeBottles) {
        print('❌ CellarProvider: Free plan limit reached (${_wines.length}/$maxFreeBottles)');
        throw Exception('PLAN_LIMIT_EXCEEDED');
      }

      _wines.add(wine);
      
      // Save to local storage
      await StorageHelper.saveCellarWines(_userId!, _wines);
      print('✅ CellarProvider: Added wine: ${wine.name} - Total: ${_wines.length}');
      
      // TODO: Also save to server when API is available
      // await _wineService.saveWine(_userId!, wine);
      
      notifyListeners();
    } catch (e) {
      print('❌ CellarProvider: Error adding wine: $e');
      rethrow;
    }
  }

  Future<void> updateWine(WineModel wine) async {
    if (_userId == null) return;

    final index = _wines.indexWhere((w) => w.id == wine.id);
    if (index != -1) {
      _wines[index] = wine;
      await StorageHelper.saveCellarWines(_userId!, _wines);
      print('✅ CellarProvider: Updated wine: ${wine.name}');
      notifyListeners();
    }
  }

  Future<void> deleteWine(String wineId) async {
    if (_userId == null) return;

    _wines.removeWhere((w) => w.id == wineId);
    await StorageHelper.saveCellarWines(_userId!, _wines);
    print('✅ CellarProvider: Deleted wine: $wineId');
    notifyListeners();
  }

  Future<void> refreshWines() async {
    await loadWines();
  }

  List<String> getUniqueCountries() {
    return _wines
        .map((w) => w.country)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<WineModel> filterWines({
    String? country,
    String? searchQuery,
    String? sortBy,
  }) {
    var filtered = List<WineModel>.from(_wines);

    if (country != null && country.isNotEmpty && country != 'all') {
      filtered = filtered.where((w) => w.country == country).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((w) =>
        w.name.toLowerCase().contains(query) ||
        w.grape.toLowerCase().contains(query) ||
        w.region.toLowerCase().contains(query)
      ).toList();
    }

    if (sortBy == 'name-az') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortBy == 'year-desc') {
      filtered.sort((a, b) => b.year.compareTo(a.year));
    }

    return filtered;
  }
}
