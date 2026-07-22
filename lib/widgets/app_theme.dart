import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DoseGPT Design System — v2.0 (Emerald)
///
/// Philosophy: "Apple designed Headspace for doctors."
///
/// Principles:
///   • Calm — generous whitespace, muted surfaces, restrained color
///   • Premium — long-burr shadows, large corner radii, tactile elevation
///   • Trustworthy — clear hierarchy, excellent contrast, no gimmicks
///   • Medical — professional tone, purposeful greens
///
/// Brand colours shifted to emerald family with neon emerald (#00FF87)
/// used sparingly for accents (icons, active states, the DOSE "O" capsule).
class AppTheme {
  // ── Brand Colors (Emerald Palette) ──────────────────────────
  static const Color primary = Color(0xFF004D36); // Dark emerald
  static const Color primaryDark = Color(0xFF003326);
  static const Color primaryMid = Color(0xFF006B4D); // Mid emerald
  static const Color neonEmerald = Color(0xFF00FF87); // Vibrant accent
  static const Color mintWhite = Color(0xFFE6F9F0); // Mint tint

  static const Color accentGold = Color(0xFFC98A1F);
  static const Color urgent = Color(0xFFE91429);
  static const Color warning = Color(0xFFFFA42B);

  // ── Surface Palette (Dark) ───────────────────────────────────
  static const Color surface = Color(0xFF0D1110); // Emerald-black base
  static const Color surfaceCard = Color(0xFF161A18); // Slightly warm
  static const Color surfaceElevated = Color(0xFF1E2421);
  static const Color surfaceHighlight = Color(0xFF282E2B);

  // ── Surface Palette (Light) ──────────────────────────────────
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSectionBg = Color(0xFFF0F4F2); // Section container
  static const Color lightCardBg = Color(0xFFF4F6F5);
  static const Color lightDivider = Color(0xFFD0D5D2);

  // ── Text (Dark) ──────────────────────────────────────────────
  static const Color ink = Color(0xFFFFFFFF);
  static const Color inkPrimary = Color(0xFFF0F0F0);
  static const Color inkMuted = Color(0xFFB0B5B0);
  static const Color inkSubtle = Color(0xFF6B706B);

  // ── Text (Light) ─────────────────────────────────────────────
  static const Color lightInk = Color(0xFF16211C);
  static const Color lightInkMuted = Color(0xFF6B7B73);
  static const Color lightInkSubtle = Color(0xFF8A9B93);
  static const Color lightAccent = Color(0xFFB3402B);

  // ── Nav (Light) ──────────────────────────────────────────────
  static const Color lightNavActive = Color(0xFF004D36); // Dark emerald
  static const Color lightNavInactive = Color(0xFF6B7B73);

  // ── Borders (Dark) ───────────────────────────────────────────
  static const Color borderHairline = Color(0xFF282E2B);
  static const Color borderActive = Color(0xFF343A37);

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
  static const double radiusCard = 18.0;
  static const double radiusPill = 28.0;
  static const double radiusSection = 14.0; // Section container corners

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

  // ── Shadows (Light) — Apple-inspired, single long-blur ────
  /// Single-layer shadow for cards — very low opacity, long blur.
  /// Pure neutral black at 3% for realistic elevation without competing
  /// with the card itself.
  static const List<BoxShadow> lightShadowCard = [
    BoxShadow(
      color: Color(0x08000000), // black 3%
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  /// Subtle shadow for icon frames.
  static const List<BoxShadow> lightShadowIcon = [
    BoxShadow(
      color: Color(0x04000000), // black 1.5%
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // ── Typography — 5-Tier System ────────────────────────────
  // Tier 1: Display (28/700) — hero numbers, dose results
  // Tier 2: Heading (22/700) — section titles, app bar
  // Tier 3: Body (17/500) — card labels, main text
  // Tier 4: Secondary (14/400) — subtitles, descriptions
  // Tier 5: Label (12/600) — badges, tab text, small labels

  /// T1: Display — 28px, Bold. Hero numbers, splash heading.
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700, color: ink,
    height: 1.1, letterSpacing: -0.5,
  );

  /// T2: Heading — 22px, Bold. Section titles, app bar title.
  static TextStyle get headingLarge => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w700, color: ink,
    height: 1.2, letterSpacing: -0.3,
  );

  /// T3: Body — 17px, Medium. Card labels, primary reading.
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w500, color: ink,
    height: 1.4, letterSpacing: 0.1,
  );

  /// T3: Body (light) — 17px, Medium for light theme.
  static TextStyle get bodyLargeLight => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w500, color: lightInk,
    height: 1.4, letterSpacing: 0.1,
  );

  /// T3: Body (muted) — 17px, Regular for secondary content.
  static TextStyle get bodyMuted => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w400, color: inkMuted,
    height: 1.45, letterSpacing: 0.1,
  );

  /// T4: Secondary — 14px, Regular. Subtitles, descriptions.
  static TextStyle get secondaryText => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: inkMuted,
    height: 1.35, letterSpacing: 0.15,
  );

  /// T4: Secondary (light) — 14px, Regular for light theme.
  static TextStyle get secondaryTextLight => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: lightInkMuted,
    height: 1.35, letterSpacing: 0.15,
  );

  /// T5: Label — 12px, Semibold. Small labels, badges, tab text.
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w600, color: ink,
    height: 1.2, letterSpacing: 0.3,
  );

  /// T5: Label (light muted) — for category divider text.
  static TextStyle get labelSmallMuted => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w600, color: inkSubtle,
    height: 1.2, letterSpacing: 0.8,
  );

  /// Dose hero — 48px, Bold. Big dose result number.
  static TextStyle get doseHero => GoogleFonts.inter(
    fontSize: 48, fontWeight: FontWeight.w700, color: ink,
    height: 1.05, letterSpacing: -1.0,
  );

  // ── Deprecated / Legacy aliases ──────────────────────────────
  static const double spacingXs = space4;
  static const double spacingSm = space8;
  static const double spacingMd = space16;
  static const double spacingLg = space24;
  static const double spacingXl = space32;
  static const double spacingXxl = space48;

  static const double radiusCardOld = 12.0;
  static const double minTapHeight = 56.0;
  static const double minTapWidth = 48.0;

  static const List<BoxShadow> cardShadow = shadowCard;

  // Legacy aliases
  static TextStyle get screenTitle => displayLarge;
  static TextStyle get sectionTitle => headingLarge;
  static TextStyle get cardLabel => bodyLarge;
  static TextStyle get formulaSource => bodyMuted;
  static TextStyle get doseResult => doseHero;

  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryMid,
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
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0D1110),
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
          backgroundColor: primaryMid,
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
          borderSide: const BorderSide(color: primaryMid, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: inkMuted),
        hintStyle: GoogleFonts.inter(color: inkSubtle),
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge,
        headlineLarge: headingLarge,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMuted,
        labelSmall: labelSmall,
      ),
    );
  }

  // ── Light Theme ──────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF004D36),
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
        selectedItemColor: Color(0xFF004D36),
        unselectedItemColor: Color(0xFF6B7B73),
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
