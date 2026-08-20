import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color greenLight = Color(0xFF8CC63F);
  static const Color green = Color(0xFF27A148);
  static const Color blue = Color(0xFF4A90E2);
  static const Color ink = Color(0xFF17324D);
  static const Color muted = Color(0xFF6B7C8F);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF9FBFD),
    colorScheme: ColorScheme.fromSeed(seedColor: green),
    fontFamily: 'Arial',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD9E2EA))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD9E2EA))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: green, width: 1.5)),
    ),
  );
}
