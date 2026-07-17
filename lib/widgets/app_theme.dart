import 'package:flutter/material.dart';

/// Design tokens for DoseGPT — Apple-inspired restraint, high contrast,
/// large tap targets, suitable for bright daylight use.
class AppTheme {
  // -- Colors --
  static const Color primary = Color(0xFF0B6E4F);
  static const Color primaryDark = Color(0xFF07543C);
  static const Color accentGold = Color(0xFFC98A1F);
  static const Color urgent = Color(0xFFB3402B);
  static const Color ink = Color(0xFF16211C);
  static const Color inkMuted = Color(0xFF5B6B62);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFF4F6F5);
  static const Color borderHairline = Color(0xFFE1E6E3);

  // -- Spacing (8px base grid) --
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // -- Corner radius --
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusPill = 24.0;

  // -- Tap target --
  static const double minTapHeight = 56.0;
  static const double minTapWidth = 48.0;

  // -- Shadow --
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // -- Text styles --
  static const TextStyle doseResult = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: ink,
    height: 1.1,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ink,
    height: 1.3,
  );

  static const TextStyle cardLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ink,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ink,
    height: 1.5,
  );

  static const TextStyle formulaSource = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: inkMuted,
    height: 1.4,
  );

  // -- Theme --
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: surface,
        secondary: primaryDark,
        surface: surface,
        onSurface: ink,
        error: urgent,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: screenTitle,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: inkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: surface,
          minimumSize: const Size(double.infinity, minTapHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderHairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderHairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
