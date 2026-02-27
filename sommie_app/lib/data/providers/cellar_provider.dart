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
        print('❌ CellarProvider: No user found');
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
      return;
    }
    
    try {
      // Load from local storage
      _wines = await StorageHelper.getCellarWines(_userId!);
      print('✅ CellarProvider: Loaded ${_wines.length} wines from local storage');
      
      // If no local wines, try to fetch from server
      if (_wines.isEmpty) {
        print('🔄 No local wines, attempting to fetch from server...');
        // Note: This requires a server endpoint to fetch wines
        // You'll need to implement this endpoint
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ CellarProvider: Error loading wines: $e');
      _wines = [];
      notifyListeners();
    }
  }

  Future<void> addWine(WineModel wine) async {
    if (_userId == null) {
      print('❌ CellarProvider: Cannot add wine - No userId');
      throw Exception('User not authenticated');
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

  // Call this after login to ensure data is loaded
  Future<void> refreshAfterLogin() async {
    final user = await StorageHelper.getUser();
    if (user != null) {
      _userId = user.userId;
      await loadWines();
    }
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
