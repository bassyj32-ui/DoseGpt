import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/app_theme.dart';
import '../services/data_loader.dart';
import 'home_screen.dart';

/// Main Navigation Shell — Light Mode
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

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Scrollable content ──────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: HomeScreen(
                  data: currentData,
                  searchQuery: _searchController.text,
                ),
              ),

              // ── Glass-morphism app bar ──────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black.withValues(alpha: 0.06),
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _isSearching
                          ? _buildSearchField()
                          : _buildTitleBar(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: Colors.white.withValues(alpha: 0.72),
                child: _BottomNav(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    _searchController.clear();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Title bar (default state) ──────────────────────────────────
  Widget _buildTitleBar() {
    return Row(
      children: [
        PhosphorIcon(
          PhosphorIconsDuotone.stethoscope,
          color: AppTheme.primary,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          'DoseGPT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.lightInk,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleSearch,
          child: PhosphorIcon(
            PhosphorIconsRegular.magnifyingGlass,
            color: AppTheme.lightInkMuted,
            size: 22,
          ),
        ),
      ],
    );
  }

  // ── Search field (expanded state) ─────────────────────────────
  Widget _buildSearchField() {
    return Row(
      children: [
        GestureDetector(
          onTap: _toggleSearch,
          child: PhosphorIcon(
            PhosphorIconsRegular.arrowLeft,
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
              hintText: 'Search conditions…',
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
            child: PhosphorIcon(
              PhosphorIconsRegular.xCircle,
              color: AppTheme.lightInkSubtle,
              size: 20,
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Custom Bottom Navigation
// ═══════════════════════════════════════════════════════════════════
/// A minimal two-tab bottom navigation with Phosphor icons and a
/// pill-shaped active indicator for a premium, modern feel.
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _NavItem(
              icon: PhosphorIconsRegular.baby,
              activeIcon: PhosphorIconsFill.baby,
              label: 'Pediatrics',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: PhosphorIconsRegular.person,
              activeIcon: PhosphorIconsFill.person,
              label: 'Adults',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual nav item with a pill indicator below the label.
class _NavItem extends StatelessWidget {
  final PhosphorIconData icon;
  final PhosphorIconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.lightNavActive : AppTheme.lightNavInactive;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            // Active indicator pill
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.lightNavActive : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
