import 'package:flutter/material.dart';

/// Spotify-inspired dark design tokens for DoseGPT.
class AppTheme {
  // -- Spotify Colors --
  static const Color primary = Color(0xFF1DB954); // Spotify Green
  static const Color primaryDark = Color(0xFF169C46);
  static const Color accentGold = Color(0xFFC98A1F);
  static const Color urgent = Color(0xFFE91429);
  static const Color warning = Color(0xFFFFA42B);

  // -- Dark Surfaces --
  static const Color surface = Color(0xFF121212); // Spotify base bg
  static const Color surfaceCard = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF282828);
  static const Color surfaceInput = Color(0xFF2A2A2A);

  // -- Text --
  static const Color ink = Color(0xFFFFFFFF);
  static const Color inkMuted = Color(0xFFB3B3B3);
  static const Color inkSubtle = Color(0xFF6A6A6A);

  // -- Borders --
  static const Color borderHairline = Color(0xFF333333);

  // -- Card gradients per condition (fallback until images load) --
  static const Map<String, List<Color>> conditionGradients = {
    'malaria': [Color(0xFFD32F2F), Color(0xFFB71C1C)],
    'pneumonia': [Color(0xFF1976D2), Color(0xFF0D47A1)],
    'diarrhea': [Color(0xFFFBC02D), Color(0xFFF57F17)],
    'fever': [Color(0xFFF57C00), Color(0xFFE65100)],
    'uti': [Color(0xFF7B1FA2), Color(0xFF4A148C)],
    'tonsillitis': [Color(0xFFC62828), Color(0xFF8E0000)],
    'otitis_media': [Color(0xFFAD1457), Color(0xFF78002E)],
    'asthma': [Color(0xFF00695C), Color(0xFF00352C)],
    'impetigo': [Color(0xFF1565C0), Color(0xFF0D47A1)],
    'worms': [Color(0xFF2E7D32), Color(0xFF1B5E20)],
  };

  // -- Spacing (8px base) --
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // -- Corner radius --
  static const double radiusCard = 8.0; // Spotify card radius
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusPill = 24.0;

  // -- Tap target --
  static const double minTapHeight = 56.0;
  static const double minTapWidth = 48.0;

  // -- Card size for grid --
  static const double gridCardWidth = 165.0;
  static const double gridCardHeight = 165.0;

  // -- Shadow --
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // -- Text styles --
  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: ink,
    height: 1.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: ink,
    height: 1.3,
  );

  static const TextStyle cardLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ink,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ink,
    height: 1.5,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: inkMuted,
    height: 1.4,
  );

  static const TextStyle formulaSource = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: inkMuted,
    height: 1.4,
  );

  static const TextStyle doseResult = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: ink,
    height: 1.1,
  );

  // -- Theme --
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        onPrimary: surface,
        secondary: primaryDark,
        surface: surface,
        onSurface: ink,
        error: urgent,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: ink,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: ink,
        unselectedItemColor: inkSubtle,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: ink,
          minimumSize: const Size(double.infinity, minTapHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceInput,
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
        labelStyle: const TextStyle(color: inkMuted),
        hintStyle: const TextStyle(color: inkSubtle),
      ),
      textTheme: const TextTheme(
        bodyLarge: body,
        bodyMedium: bodyMuted,
        titleLarge: screenTitle,
      ),
    );
  }
}
