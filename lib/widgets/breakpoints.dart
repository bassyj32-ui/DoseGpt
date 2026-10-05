import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

/// Layout decisions that depend on available width.
///
/// The app runs as an Android APK, an installable PWA, and a desktop
/// browser, and those want genuinely different layouts rather than the same
/// column stretched to fill a monitor. Mobile keeps the existing single
/// column and floating bottom nav; the desktop breakpoint gets a persistent
/// sidebar, multi-column cards, and a persistent search field.
///
/// Mobile layout is unchanged by anything here. Every helper returns the
/// current mobile value below [desktop].
class Breakpoints {
  const Breakpoints._();

  /// Below this the layout is the phone layout.
  static const double desktop = 1000;

  /// Between [desktop] and this, tablets get two columns but no sidebar.
  static const double wide = 760;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// True on a desktop-sized browser window.
  ///
  /// Guarded on [kIsWeb] so a large tablet in landscape keeps the phone
  /// layout rather than losing its bottom nav to a sidebar.
  static bool isDesktop(BuildContext context) =>
      kIsWeb && widthOf(context) >= desktop;

  /// True on any window wide enough for more than one card column.
  static bool isMultiColumn(BuildContext context) =>
      widthOf(context) >= wide;

  /// How many card columns to lay out at the current width.
  static int columnsFor(BuildContext context) {
    final w = widthOf(context);
    if (w >= 1400) return 4;
    if (w >= 1100) return 3;
    if (w >= wide) return 2;
    return 1;
  }

  /// Maximum width for a column of content.
  ///
  /// 600 on mobile keeps the existing reading measure. Desktop widens it so
  /// a multi-column grid has room without cards stretching into banners.
  static double contentMaxWidth(BuildContext context) =>
      isMultiColumn(context) ? 1320 : 600;

  /// Horizontal page padding.
  static double gutter(BuildContext context) =>
      isMultiColumn(context) ? 32 : 24;

  /// Width of the desktop sidebar. The content area reserves this much
  /// leading space when the sidebar is showing.
  static const double sidebarWidth = 248;

  /// Extra top padding on desktop, where there is no status bar inset but
  /// the bar is not full-bleed.
  static double topInset(BuildContext context) => isDesktop(context) ? 16 : 0;
}
