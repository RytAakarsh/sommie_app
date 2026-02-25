import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Sommie';
  static const String languageKey = 'app_language';
  
  // Colors (matching your CSS variables)
  static const Color primaryColor = Color(0xFF4B2B5F); // --primary: 75 43 95
  static const Color accentColor = Color(0xFF6D3FA6);
  static const Color backgroundColor = Color(0xFFFBF7FB);
  static const Color lightPurple = Color(0xFFF4E8FB);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E1428); // --foreground: 30 20 40
  static const Color textSecondary = Color(0xFF645A6E); // --muted-foreground: 100 90 110
  static const Color borderColor = Color(0xFFE6E1EB); // --border: 230 225 235
  
  // Border radius
  static const double borderRadius = 14.0; // --radius: 0.875rem
  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;
  
  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
}
