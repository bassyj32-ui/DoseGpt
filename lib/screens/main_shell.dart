import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_theme.dart';
import '../widgets/widgets.dart';
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
        body: Stack(
          children: [
            // ── Scrollable content (no cross-fade) ──────────
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 0),
              child: HomeScreen(
                key: ValueKey(_currentIndex),
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
        // ── Floating glass bottom nav (Apple-style) ──────────
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

  // ── Title bar: Logo tile + DoseGPT text (no repetition) ──────
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

  // ── Search field (expanded state) ─────────────────────────────
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

// ═══════════════════════════════════════════════════════════════════
// Floating Bottom Navigation — Apple-inspired glass + emoji
// ═══════════════════════════════════════════════════════════════════
/// Apple-style floating bottom nav with:
///   - Glass-morphism backdrop (same as app bar)
///   - Left/right/bottom margin for floating effect
///   - Emoji instead of icons, with brand-green active pill
///   - Soft shadow for depth
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
                  emoji: '🧸',
                  label: 'Pediatrics',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _EmojiNavItem(
                  emoji: '❤️',
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
