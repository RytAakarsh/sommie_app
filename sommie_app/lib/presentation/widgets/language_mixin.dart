import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/language_provider.dart';

mixin LanguageMixin {
  bool isPortuguese(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    return lang.currentLanguage == 'pt';
  }

  String tr(BuildContext context, String enText, String ptText) {
    return isPortuguese(context) ? ptText : enText;
  }
}