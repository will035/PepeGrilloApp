import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6366F1);
  static const green = Color(0xFF059669);
  static const red = Color(0xFFDC4C64);
  static const ink = Color(0xFF1C1C1E);

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: dark ? const Color(0xFFA5A6FF) : primaryColor,
      surface: dark ? const Color(0xFF202127) : Colors.white,
      onSurface: dark ? const Color(0xFFF4F5F7) : ink,
      onSurfaceVariant:
          dark ? const Color(0xFFB2B4C3) : const Color(0xFF747783),
      outlineVariant: dark ? const Color(0xFF343641) : const Color(0xFFEEEFF3),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF14151A) : const Color(0xFFF4F5F7),
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
            fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.6),
        headlineMedium: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.8),
        titleLarge: const TextStyle(
            fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleMedium: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        bodyMedium: const TextStyle(fontSize: 13, height: 1.5),
        bodySmall: TextStyle(
            fontSize: 11, color: scheme.onSurfaceVariant, height: 1.5),
      ),
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface)),
      cardTheme: CardThemeData(
          color: scheme.surface,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
      dividerTheme:
          DividerThemeData(color: scheme.outlineVariant, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surface,
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: scheme.outlineVariant)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: scheme.outlineVariant))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: ink,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(48, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ink, foregroundColor: Colors.white, elevation: 3),
      snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }
}
