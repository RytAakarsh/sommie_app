import 'package:flutter/material.dart';
import '../models/wine_model.dart';
import '../../core/utils/storage_helper.dart';

class CellarProvider extends ChangeNotifier {
  List<WineModel> _wines = [];
  String? _userId;
  static const int maxFreeBottles = 6;

  List<WineModel> get wines => _wines;
  int get wineCount => _wines.length;
  int get remainingFreeSpots => maxFreeBottles - _wines.length;
  bool get canAddMore => _wines.length < maxFreeBottles;

  CellarProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageHelper.getUser();
    if (user != null) {
      _userId = user.userId;
      await loadWines();
    }
  }

  Future<void> loadWines() async {
    if (_userId == null) return;
    _wines = await StorageHelper.getCellarWines(_userId!);
    notifyListeners();
  }

  Future<void> addWine(WineModel wine) async {
    if (_userId == null) return;
    
    // Check limit for free users
    final user = await StorageHelper.getUser();
    if (user?.plan != 'PRO' && _wines.length >= maxFreeBottles) {
      throw Exception('Free plan limit reached');
    }

    _wines.add(wine);
    await StorageHelper.saveCellarWines(_userId!, _wines);
    notifyListeners();
  }

  Future<void> updateWine(WineModel wine) async {
    final index = _wines.indexWhere((w) => w.id == wine.id);
    if (index != -1) {
      _wines[index] = wine;
      if (_userId != null) {
        await StorageHelper.saveCellarWines(_userId!, _wines);
      }
      notifyListeners();
    }
  }

  Future<void> deleteWine(String wineId) async {
    _wines.removeWhere((w) => w.id == wineId);
    if (_userId != null) {
      await StorageHelper.saveCellarWines(_userId!, _wines);
    }
    notifyListeners();
  }

  List<String> getUniqueCountries() {
    return _wines
        .map((w) => w.country)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
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
      filtered = filtered.where((w) =>
        w.name.toLowerCase().contains(searchQuery.toLowerCase())
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
