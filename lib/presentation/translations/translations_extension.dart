import 'package:flutter/material.dart';
import '../../main.dart';

extension TranslateX on BuildContext {
  String tr(String key) {
    // Safely get AppLocalizations
    final localizations = Localizations.of<AppLocalizations>(this, AppLocalizations);
    if (localizations != null) {
      return localizations.translate(key);
    }
    return key;
  }
}