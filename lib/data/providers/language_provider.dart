import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage;

  LanguageProvider(this._currentLanguage);

  String get currentLanguage => _currentLanguage;

  Future<void> setLanguage(String language) async {
    if (_currentLanguage == language) return;
    
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, language);
    notifyListeners();
  }

  void toggleLanguage() {
    if (_currentLanguage == 'en') {
      setLanguage('pt');
    } else {
      setLanguage('en');
    }
  }
}