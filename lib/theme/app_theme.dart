import 'package:flutter/material.dart';

/// Burgundy theme for the shopping app (light + dark).
class AppTheme {
  static const Color burgundy = Color(0xFF6E1F2E);
  static const Color burgundyLight = Color(0xFFF7DCE1);
  static const Color burgundyOnDark = Color(0xFFE59AAB);
  static const Color burgundyDeep = Color(0xFF3B0E19);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? burgundyOnDark : burgundy;
    final onPrimary = isDark ? burgundyDeep : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: burgundy,
        brightness: brightness,
      ).copyWith(
        primary: primary,
        onPrimary: onPrimary,
        secondary: primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor:
          isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFDDDDDD),
          ),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E5E5),
          ),
        ),
      ),
    );
  }
}