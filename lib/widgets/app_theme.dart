import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DoseGPT Design System
///
/// Philosophy: "Apple designed Headspace for doctors."
///
/// Principles:
///   • Calm — generous whitespace, muted surfaces, restrained color
///   • Premium — soft shadows, large corner radii, tactile elevation
///   • Trustworthy — clear hierarchy, excellent contrast, no gimmicks
///   • Medical — professional tone, warm dark palette, purposeful greens
///
/// Inspired by Headspace's visual rhythm and Apple's spatial precision.
///
/// The theme exposes both a [theme] (dark) and [lightTheme] (light).
/// Dark is used for sub-screens (weight entry, result, disclaimer).
/// Light is used for the main shell (home, reference).
class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────
  static const Color primary = Color(0xFF1DB954); // Medical green
  static const Color primaryDark = Color(0xFF169C46);
  static const Color primaryLight = Color(0xFF2EE76A);

  static const Color accentGold = Color(0xFFC98A1F);
  static const Color urgent = Color(0xFFE91429);
  static const Color warning = Color(0xFFFFA42B);

  // ── Surface Palette (Dark) ───────────────────────────────────
  static const Color surface = Color(0xFF121212); // Deep base
  static const Color surfaceCard = Color(0xFF1A1D1A); // Slightly warm
  static const Color surfaceElevated = Color(0xFF242724);
  static const Color surfaceHighlight = Color(0xFF2E312E);

  // ── Surface Palette (Light) ──────────────────────────────────
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightCardBg = Color(0xFFF4F6F5); // Light grey-green
  static const Color lightDivider = Color(0xFFD0D5D2); // Visible hairline

  // ── Text (Dark) ──────────────────────────────────────────────
  static const Color ink = Color(0xFFFFFFFF);
  static const Color inkPrimary = Color(0xFFF0F0F0);
  static const Color inkMuted = Color(0xFFB0B5B0);
  static const Color inkSubtle = Color(0xFF6B706B);

  // ── Text (Light) ─────────────────────────────────────────────
  static const Color lightInk = Color(0xFF16211C); // Dark charcoal-green
  static const Color lightInkMuted = Color(0xFF6B7B73); // Muted grey-green
  static const Color lightInkSubtle = Color(0xFF8A9B93); // Chevron grey
  static const Color lightAccent = Color(0xFFB3402B); // Urgent red-orange

  // ── Nav (Light) ──────────────────────────────────────────────
  static const Color lightNavActive = Color(0xFF0B6E4F); // Deep green
  static const Color lightNavInactive = Color(0xFF5B6B62); // Muted grey

  // ── Borders (Dark) ───────────────────────────────────────────
  static const Color borderHairline = Color(0xFF2E312E);
  static const Color borderActive = Color(0xFF3A3E3A);

  // ── Condition Gradients ─────────────────────────────────────
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

  // ── Spacing (12pt base — Apple HIG inspired) ─────────────────
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space36 = 36.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // ── Corner Radius ────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusCard = 18.0; // Headspace-inspired
  static const double radiusPill = 28.0;

  // ── Shadows (Dark) ──────────────────────────────────────────
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ── Shadows (Light) — layered for realistic elevation ──────
  /// Apple-like pill card shadow stack: 3 layers for soft depth.
  static const List<BoxShadow> lightShadowCard = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Subtle icon frame shadow.
  static const List<BoxShadow> lightShadowIcon = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 1,
      offset: Offset(0, 0),
    ),
  ];

  // ── Typography ───────────────────────────────────────────────
  // Inter font family — clean, modern, designed for UI at all sizes.
  // Headspace uses large, welcoming headings with generous leading.
  // Apple uses dynamic type with strict hierarchy.

  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 34, fontWeight: FontWeight.w700, color: ink,
    height: 1.1, letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700, color: ink,
    height: 1.15, letterSpacing: -0.3,
  );

  static TextStyle get headingLarge => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700, color: ink,
    height: 1.2, letterSpacing: -0.2,
  );

  static TextStyle get headingMedium => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w600, color: ink,
    height: 1.25, letterSpacing: -0.2,
  );

  static TextStyle get subtitleLarge => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w500, color: inkMuted,
    height: 1.3, letterSpacing: 0.1,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w400, color: inkPrimary,
    height: 1.5, letterSpacing: 0.1,
  );

  static TextStyle get bodyMuted => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w400, color: inkMuted,
    height: 1.45, letterSpacing: 0.1,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400, color: inkSubtle,
    height: 1.35, letterSpacing: 0.2,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w600, color: ink,
    height: 1.3,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w600, color: ink,
    height: 1.3,
  );

  static TextStyle get doseHero => GoogleFonts.inter(
    fontSize: 48, fontWeight: FontWeight.w700, color: ink,
    height: 1.05, letterSpacing: -1.0,
  );

  // ── Deprecated / Legacy aliases ──────────────────────────────
  // Keep these so existing screens don't break — they'll be
  // migrated one at a time.
  static const double spacingXs = space4;
  static const double spacingSm = space8;
  static const double spacingMd = space16;
  static const double spacingLg = space24;
  static const double spacingXl = space32;
  static const double spacingXxl = space48;

  static const double radiusCardOld = 12.0; // Used by legacy cards

  static const double minTapHeight = 56.0;
  static const double minTapWidth = 48.0;

  static const List<BoxShadow> cardShadow = shadowCard;

  // Legacy aliases — use these to avoid const issues with GoogleFonts getters
  static TextStyle get screenTitle => displayMedium;
  static TextStyle get sectionTitle => headingLarge;
  static TextStyle get cardLabel => headingMedium;
  static TextStyle get formulaSource => bodyMuted;
  static TextStyle get doseResult => doseHero;

  // ── Theme ────────────────────────────────────────────────────
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
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: ink,
        unselectedItemColor: inkSubtle,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space12,
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
        labelStyle: GoogleFonts.inter(color: inkMuted),
        hintStyle: GoogleFonts.inter(color: inkSubtle),
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        titleLarge: subtitleLarge,
        bodyLarge: body,
        bodyMedium: bodyMuted,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
      ),
    );
  }

  // ── Light Theme ──────────────────────────────────────────────
  /// Clean white theme for the main shell (Home + Reference).
  /// Used in [MainShell]; dark sub-screens use [theme].
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0B6E4F),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF16211C),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF16211C),
        error: Color(0xFFB3402B),
      ),
      scaffoldBackgroundColor: lightSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightInk,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: lightInk,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFF0B6E4F),
        unselectedItemColor: Color(0xFF5B6B62),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
