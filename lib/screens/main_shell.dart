import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/widgets.dart';
import '../services/data_loader.dart';
import '../widgets/breakpoints.dart';
import 'home_screen.dart';

/// Main Navigation Shell â€” Light Mode
///
/// Two tabs: Pediatrics | Adults
///
/// Features a frosted-glass navigation bar with an expandable search
/// field (iOS-style). The search query is passed down to [HomeScreen]
/// to filter condition cards in real time.
class MainShell extends StatefulWidget {
  final ClinicalData pediatricData;
  final ClinicalData adultData;

  const MainShell({
    super.key,
    required this.pediatricData,
    required this.adultData,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _isSearching = false;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _applyLaunchTab();
  }

  /// Honours the PWA manifest shortcuts, which open the app directly on the
  /// paediatric or adult tab. Requires the URL to carry `?tab=pediatric`
  /// or `?tab=adult`. Safe to call on mobile, where there is no query.
  void _applyLaunchTab() {
    if (!kIsWeb) return;
    final tab = Uri.base.queryParameters['tab']?.toLowerCase();
    if (tab == 'adult') _currentIndex = 1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchFocus.unfocus();
      } else {
        _searchFocus.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentData = switch (_currentIndex) {
      0 => widget.pediatricData,
      1 => widget.adultData,
      _ => widget.pediatricData,
    };

    if (Breakpoints.isDesktop(context)) {
      return _buildDesktop(context, currentData);
    }

    final topPadding = MediaQuery.of(context).padding.top;
    const barHeight = 60;
    final totalBarHeight = barHeight + topPadding;

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        body: Stack(
          children: [
            // â”€â”€ Scrollable content (no cross-fade) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: EdgeInsets.only(top: totalBarHeight, bottom: 0),
              child: HomeScreen(
                key: ValueKey(_currentIndex),
                data: currentData,
                searchQuery: _searchController.text,
              ),
            ),

            // â”€â”€ Glass-morphism app bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: totalBarHeight,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black.withValues(alpha: 0.06),
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: topPadding,
                      left: 16,
                      right: 16,
                    ),
                    child: _isSearching
                        ? _buildSearchField()
                        : _buildTitleBar(),
                  ),
                ),
              ),
            ),
          ],
        ),
        // â”€â”€ Floating glass bottom nav (Apple-style) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        bottomNavigationBar: _FloatingBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            _searchController.clear();
          },
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // Desktop layout
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  /// Persistent sidebar navigation instead of the floating bottom bar.
  ///
  /// The bottom bar is a phone affordance: it depends on reach, wastes
  /// vertical space on a monitor, and gives no room for context. On desktop
  /// it is replaced by a fixed rail, and the search field is always present
  /// rather than hidden behind an icon.
  Widget _buildDesktop(BuildContext context, ClinicalData currentData) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        body: Row(
          children: [
            _DesktopSidebar(
              currentIndex: _currentIndex,
              onTap: _selectTab,
            ),
            Expanded(
              child: Column(
                children: [
                  _DesktopTopBar(
                    searchController: _searchController,
                    searchFocus: _searchFocus,
                    onSearchChanged: () => setState(() {}),
                    onSearchCleared: () => setState(() {
                      _searchController.clear();
                    }),
                  ),
                  Expanded(
                    child: HomeScreen(
                      key: ValueKey(_currentIndex),
                      data: currentData,
                      searchQuery: _searchController.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _searchController.clear();
    });
  }

  // â”€â”€ Title bar: Logo tile + DoseGPT text (no repetition) â”€â”€â”€â”€â”€â”€
  Widget _buildTitleBar() {
    return Row(
      children: [
        // DoseLogoTile (small) + DoseGPT
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DoseLogoTile(size: 38),
            const SizedBox(width: 8),
            Text(
              'DoseGPT',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightInk,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleSearch,
          child: Icon(
            LucideIcons.search,
            color: AppTheme.lightInkMuted,
            size: 22,
          ),
        ),
      ],
    );
  }

  // â”€â”€ Search field (expanded state) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildSearchField() {
    return Row(
      children: [
        GestureDetector(
          onTap: _toggleSearch,
          child: Icon(
            LucideIcons.arrow_left,
            color: AppTheme.lightInkMuted,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: (_) => setState(() {}),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search conditionsâ€¦',
              hintStyle: TextStyle(
                fontSize: 17,
                color: AppTheme.lightInkSubtle,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: 17,
              color: AppTheme.lightInk,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (_searchController.text.isNotEmpty)
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {});
            },
            child: Icon(
              LucideIcons.circle_x,
              color: AppTheme.lightInkSubtle,
              size: 20,
            ),
          ),
      ],
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•[...]
// Floating Bottom Navigation â€” Apple-inspired glass + emoji
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•[...]
/// Apple-style floating bottom nav with:
///   - Glass-morphism backdrop (same as app bar)
///   - Left/right/bottom margin for floating effect
///   - Emoji instead of icons, with brand-green active pill
///   - Soft shadow for depth
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Desktop chrome â€” sidebar rail and persistent search
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

/// Fixed left rail used instead of the floating bottom bar on desktop.
///
/// Carries the brand, the two age-group tabs, and the unverified-data
/// notice, which on mobile lives only on the first-launch disclaimer.
class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DesktopSidebar({required this.currentIndex, required this.onTap});

  static const _tabs = [
    (label: 'Pediatrics', emoji: 'ðŸ‘¶'),
    (label: 'Adults', emoji: 'ðŸ§‘'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Breakpoints.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppTheme.lightSectionBg,
        border: Border(
          right: BorderSide(color: AppTheme.lightDivider, width: 0.5),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const DoseLogoTile(size: 38),
                  const SizedBox(width: 10),
                  Text(
                    'DoseGPT',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightInk,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'AGE GROUP',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightInkSubtle,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < _tabs.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _SidebarTab(
                    label: _tabs[i].label,
                    emoji: _tabs[i].emoji,
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
              const Spacer(),
              // Stated in the chrome rather than buried in a screen a
              // clinician may never visit. Uses the AA amber for text, not
              // the decorative gold that fails contrast.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentGoldInk.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.triangle_alert,
                      size: 15,
                      color: AppTheme.accentGoldInk,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dosing data is not yet clinically verified.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.45,
                          color: AppTheme.lightInkWarning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarTab extends StatefulWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTab({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarTab> createState() => _SidebarTabState();
}

class _SidebarTabState extends State<_SidebarTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    // Hover is the affordance that makes the web build feel like a web app,
    // and it does not exist on touch so mobile is unaffected.
    final background = active
        ? AppTheme.lightNavActive
        : (_hovered ? AppTheme.lightSectionBg : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : AppTheme.lightInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop top bar: page title plus an always-visible search field.
class _DesktopTopBar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final VoidCallback onSearchChanged;
  final VoidCallback onSearchCleared;

  const _DesktopTopBar({
    required this.searchController,
    required this.searchFocus,
    required this.onSearchChanged,
    required this.onSearchCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.lightDivider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Text(
            'Dosing reference',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightInkMuted,
            ),
          ),
          const SizedBox(width: 24),
          // Capped so the field does not stretch the full width of a large
          // monitor, which makes the text cursor hard to track.
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _SearchField(
                  controller: searchController,
                  focusNode: searchFocus,
                  onChanged: onSearchChanged,
                  onCleared: onSearchCleared,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Not for clinical use without verification',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.lightInkSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final VoidCallback onCleared;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.lightDivider, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 16, color: AppTheme.lightInkSubtle),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (_) => onChanged(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.lightInk,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: 'Search conditionsâ€¦',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.lightInkSubtle,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onCleared,
                child: Icon(
                  LucideIcons.circle_x,
                  size: 16,
                  color: AppTheme.lightInkSubtle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _EmojiNavItem(
                  emoji: 'ðŸ§¸',
                  label: 'Pediatrics',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _EmojiNavItem(
                  emoji: 'â¤ï¸',
                  label: 'Adults',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual nav item with emoji + brand-green active container.
class _EmojiNavItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiNavItem({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: isSelected ? 32 : 28,
                height: isSelected ? 32 : 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(isSelected ? 16 : 14),
                  border: isSelected
                      ? Border.all(color: AppTheme.primary, width: 1.5)
                      : Border.all(
                          color: AppTheme.lightNavInactive.withValues(alpha: 0.3),
                          width: 1,
                        ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: isSelected ? 16 : 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: isSelected ? 13 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.lightNavActive
                      : AppTheme.lightNavInactive,
                  letterSpacing: 0.1,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
