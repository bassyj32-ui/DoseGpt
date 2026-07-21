import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/app_theme.dart';
import '../widgets/condition_icons.dart';
import '../widgets/category_card.dart';
import '../models/category.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'drug_list_screen.dart';
import 'category_conditions_screen.dart';
import 'fluid_options_screen.dart';

/// Home Screen — Light Mode
///
/// Apple Health-inspired design:
///   - White background, clean and clinical
///   - Vertically scrollable list of pill-shaped cards
///   - Custom glass-style icons in white rounded frames
///   - Staggered card entrance + press-down animation
///   - Responsive card width (full-width with max cap)
///   - Urgent accent lines on Malaria & Pneumonia
///   - Top 6 conditions are hero cards; the rest are grouped into
///     body-system [CategoryCard]s that navigate to a sub-screen.
///
/// Optionally accepts a [searchQuery] to filter the displayed illnesses
/// in real time (used by the parent [MainShell] search bar).
class HomeScreen extends StatefulWidget {
  final ClinicalData data;
  final String searchQuery;

  const HomeScreen({
    super.key,
    required this.data,
    this.searchQuery = '',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _maxPinnedCards = 6;

  @override
  Widget build(BuildContext context) {
    final illnesses = List<Illness>.from(widget.data.illnesses)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final query = widget.searchQuery.trim().toLowerCase();
    final hasSearch = query.isNotEmpty;

    // If user is searching, show ALL matching conditions (no categories)
    if (hasSearch) {
      final filtered = illnesses
          .where((i) => i.nameEn.toLowerCase().contains(query))
          .toList();
      return _buildSearchView(context, filtered);
    }

    // Normal (non-search) view: top 6 hero cards + category section
    final pinned = illnesses.where((i) => i.displayOrder <= _maxPinnedCards).toList();
    final categories = widget.data.categories;

    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _computeItemCount(pinned, categories),
      itemBuilder: (context, index) {
        int i = 0;

        // ── Top spacer ─────────────────────────────────────────
        if (index == i++) {
          return const SizedBox(height: 8);
        }

        // ── Pinned hero cards (display_order 1-6) ────────────
        for (int pinIdx = 0; pinIdx < pinned.length; pinIdx++) {
          if (index == i++) {
            final illness = pinned[pinIdx];
            return _ConditionCard(
              index: pinIdx,
              illness: illness,
              iconData: ConditionIcons.iconFor(illness.id),
              isUrgent: illness.urgentAccent,
              screenWidth: screenWidth,
              onTap: () => _onConditionTap(context, illness.id),
            );
          }
        }

        // ── Category section divider followed by category cards ──
        if (categories.isNotEmpty) {
          if (index == i++) {
            return _CategoryDivider();
          }

          for (int catIdx = 0; catIdx < categories.length; catIdx++) {
            if (index == i++) {
              final category = categories[catIdx];
              return CategoryCard(
                category: category,
                screenWidth: screenWidth,
                onTap: () => _onCategoryTap(context, category),
              );
            }
          }
        }

        // Fallback (shouldn't be reached)
        return const SizedBox.shrink();
      },
    );
  }

  int _computeItemCount(
    List<Illness> pinned,
    List<Category> categories,
  ) {
    // spacer (1) + pinned
    int count = 1 + pinned.length;

    if (categories.isNotEmpty) {
      count += 1; // divider
      count += categories.length; // category cards
    }

    return count;
  }

  /// Build a flat list of all matching conditions (search mode).
  Widget _buildSearchView(BuildContext context, List<Illness> filtered) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: filtered.length + 1, // +1 for top spacer
      itemBuilder: (context, index) {
        if (index == 0) return const SizedBox(height: 8);
        final illness = filtered[index - 1];
        final cardIndex = index - 1;
        return _ConditionCard(
          index: cardIndex,
          illness: illness,
          iconData: ConditionIcons.iconFor(illness.id),
          isUrgent: illness.urgentAccent,
          screenWidth: screenWidth,
          onTap: () => _onConditionTap(context, illness.id),
        );
      },
    );
  }

  void _onConditionTap(BuildContext context, String illnessId) {
    if (illnessId == 'fluids') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FluidOptionsScreen(data: widget.data),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrugListScreen(
          data: widget.data,
          illnessId: illnessId,
        ),
      ),
    );
  }

  void _onCategoryTap(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryConditionsScreen(
          data: widget.data,
          category: category,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Category Divider
// ═══════════════════════════════════════════════════════════════════
class _CategoryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 24;
    const double maxCardWidth = 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - horizontalPadding * 2)
        .clamp(0.0, maxCardWidth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 12),
      child: Center(
        child: SizedBox(
          width: cardWidth,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE8EBE9),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightInkSubtle.withValues(alpha: 0.8),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE8EBE9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Condition Card
// ═══════════════════════════════════════════════════════════════════
class _ConditionCard extends StatefulWidget {
  final int index;
  final Illness illness;
  final PhosphorDuotoneIconData iconData;
  final bool isUrgent;
  final double screenWidth;
  final VoidCallback onTap;

  const _ConditionCard({
    required this.index,
    required this.illness,
    required this.iconData,
    required this.isUrgent,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  State<_ConditionCard> createState() => _ConditionCardState();
}

class _ConditionCardState extends State<_ConditionCard>
    with TickerProviderStateMixin {
  // ── Staggered entrance ─────────────────────────────────────────
  late AnimationController _staggerCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Press animation ───────────────────────────────────────────
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  // ── Icon entrance pulse ───────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Staggered entrance
    _staggerCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOutCubic,
    ));

    final delay = Duration(milliseconds: 60 * widget.index);
    Future.delayed(delay, () {
      if (mounted) {
        _staggerCtrl.forward().then((_) {
          if (mounted) _pulseCtrl.forward();
        });
      }
    });

    // Press-down spring
    _pressCtrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOutCubic),
    );

    // Icon entrance pulse
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _pressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 24;
    const double maxCardWidth = 600;
    final cardWidth = (widget.screenWidth - horizontalPadding * 2).clamp(
      0.0,
      maxCardWidth,
    );

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ).copyWith(bottom: 18),
          child: Center(
            child: SizedBox(
              width: cardWidth,
              child: GestureDetector(
                onTapDown: (_) => _pressCtrl.forward(),
                onTapUp: (_) {
                  _pressCtrl.reverse();
                  widget.onTap();
                },
                onTapCancel: () => _pressCtrl.reverse(),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_scaleAnim, _pulseAnim]),
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                  child: _CardContent(
                    illness: widget.illness,
                    iconData: widget.iconData,
                    isUrgent: widget.isUrgent,
                    pulseAnim: _pulseAnim,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Card Content
// ═══════════════════════════════════════════════════════════════════
class _CardContent extends StatelessWidget {
  final Illness illness;
  final PhosphorDuotoneIconData iconData;
  final bool isUrgent;
  final Animation<double> pulseAnim;

  const _CardContent({
    required this.illness,
    required this.iconData,
    required this.isUrgent,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppTheme.lightShadowCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.lightShadowIcon,
                  ),
                  child: PhosphorIcon(
                    iconData,
                    color: AppTheme.primary,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  illness.nameEn,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightInk,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Text(
                  '\u203A',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.lightInkSubtle,
                  ),
                ),
              ),
            ],
          ),
          if (isUrgent)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: AppTheme.lightAccent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    bottomLeft: Radius.circular(36),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
