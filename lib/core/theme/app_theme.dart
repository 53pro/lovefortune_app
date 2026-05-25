import 'package:flutter/material.dart';

// 앱의 전체적인 디자인 시스템을 관리하는 클래스입니다. (Clay Design System 적용)
class AppTheme {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF0A0A0A);
  static const Color primaryActive = Color(0xFF1F1F1F);
  static const Color primaryDisabled = Color(0xFFE5E5E5);
  static const Color brandPink = Color(0xFFFF4D8B);
  static const Color brandTeal = Color(0xFF1A3A3A);
  static const Color brandLavender = Color(0xFFB8A4ED);
  static const Color brandPeach = Color(0xFFFFB084);
  static const Color brandOchre = Color(0xFFE8B94A);
  static const Color brandMint = Color(0xFFA4D4C5);
  static const Color brandCoral = Color(0xFFFF6B5A);

  // Surface Colors
  static const Color canvas = Color(0xFFFFFAF0);
  static const Color surfaceSoft = Color(0xFFFAF5E8);
  static const Color surfaceCard = Color(0xFFF5F0E0);
  static const Color surfaceStrong = Color(0xFFEBE6D6);
  static const Color surfaceDark = Color(0xFF0A1A1A);
  static const Color surfaceDarkElevated = Color(0xFF1A2A2A);
  static const Color hairline = Color(0xFFE5E5E5);
  static const Color hairlineSoft = Color(0xFFF0F0F0);

  // Text Colors
  static const Color ink = Color(0xFF0A0A0A);
  static const Color body = Color(0xFF3A3A3A);
  static const Color bodyStrong = Color(0xFF1A1A1A);
  static const Color muted = Color(0xFF6A6A6A);
  static const Color mutedSoft = Color(0xFF9A9A9A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkSoft = Color(0xFFA0A0A0);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Rounded values
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 9999.0;

  // 레거시 하위 호환을 위한 상수 (가능한 사용 자제)
  static const Color primaryColor = primary;
  static const Color accentColor = brandPink;

  // 라이트 테마 정의
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: brandPink,
      unselectedItemColor: muted,
      backgroundColor: canvas,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: brandPink,
      surface: surfaceCard,
      error: error,
      onPrimary: onPrimary,
      onSecondary: ink,
      onSurface: ink,
      onError: onPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: canvas,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: ink),
      ),
      labelStyle: const TextStyle(color: muted),
      hintStyle: const TextStyle(color: mutedSoft),
    ),
    useMaterial3: true,
  );
}
