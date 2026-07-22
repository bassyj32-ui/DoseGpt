import 'package:flutter/material.dart';

import '../widgets/app_theme.dart';
import '../widgets/condition_icons.dart';
import '../widgets/category_card.dart';
import '../models/category.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'drug_list_screen.dart';
import 'category_conditions_screen.dart';
import 'fluid_options_screen.dart';

/// Home Screen — Light Mode (v2.0 with Section Grouping)
///
/// Cards are grouped into subtle rounded containers:
///   - "Common Conditions" (top 6 pinned hero cards)
///   - "Systems" (body-system category cards)
///
/// This eliminates floating whitespace by giving each group a
/// deliberate visual container, inspired by Apple Health.
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

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  static const int _maxPinnedCards = 6;

  // Subtle ambient breathe animation for section containers (scale)
  late AnimationController _breatheCtrl;
  late Animation<double> _breatheAnim;

  // Ambient card glow — shifts card bg between white and soft tint
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _breatheCtrl = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 1.0, end: 1.004).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOutSine),
    );

    // Ambient glow — card background shifts #FFFFFF ↔ #F4FAF7 over 6s
    _glowCtrl = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final illnesses = List<Illness>.from(widget.data.illnesses)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final query = widget.searchQuery.trim().toLowerCase();
    final hasSearch = query.isNotEmpty;

    if (hasSearch) {
      final filtered = illnesses
          .where((i) => i.nameEn.toLowerCase().contains(query))
          .toList();
      return _buildSearchView(context, filtered);
    }

    final pinned = illnesses.where((i) => i.displayOrder <= _maxPinnedCards).toList();
    final categories = widget.data.categories;

    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 24;
    const double maxContentWidth = 600;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),

        // ── Section: Pinned Conditions (no header) ────────────
        _SectionContainer(
          breatheAnim: _breatheAnim,
          header: null,
          child: Column(
            children: [
              for (int i = 0; i < pinned.length; i++)
                _ConditionCard(
                  index: i,
                  illness: pinned[i],
                  iconData: ConditionIcons.iconFor(pinned[i].id),
                  emoji: ConditionIcons.emojiFor(pinned[i].id),
                  isUrgent: pinned[i].urgentAccent,
                  screenWidth: screenWidth,
                  isPinned: true,
                  glowAnim: _glowAnim,
                  onTap: () => _onConditionTap(context, pinned[i].id),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Section: Systems ───────────────────────────────────
        if (categories.isNotEmpty)
          _SectionContainer(
            breatheAnim: _breatheAnim,
            header: 'Systems',
            child: Column(
              children: [
                for (int i = 0; i < categories.length; i++)
                  CategoryCard(
                    category: categories[i],
                    screenWidth: screenWidth,
                    onTap: () => _onCategoryTap(context, categories[i]),
                  ),
              ],
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSearchView(BuildContext context, List<Illness> filtered) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const SizedBox(height: 8);
        final illness = filtered[index - 1];
        final cardIndex = index - 1;
        return _ConditionCard(
          index: cardIndex,
          illness: illness,
          iconData: ConditionIcons.iconFor(illness.id),
          emoji: ConditionIcons.emojiFor(illness.id),
          isUrgent: illness.urgentAccent,
          screenWidth: screenWidth,
          glowAnim: _glowAnim,
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
// Section Container
// ═══════════════════════════════════════════════════════════════════
/// A subtle rounded container with a section header label.
///
/// The faint [AppTheme.lightSectionBg] background groups related cards
/// together visually, eliminating the floating whitespace problem.
class _SectionContainer extends StatelessWidget {
  final Animation<double> breatheAnim;
  final String? header;
  final Widget child;

  const _SectionContainer({
    required this.breatheAnim,
    required this.header,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 24;
    const double maxCardWidth = 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = (screenWidth - horizontalPadding * 2)
        .clamp(0.0, maxCardWidth);

    return Center(
      child: SizedBox(
        width: containerWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header (optional) ───────────────────────
            if (header != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  header!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightInkSubtle,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // ── Animated container ──────────────────────────────
            AnimatedBuilder(
              animation: breatheAnim,
              builder: (context, child) => Transform.scale(
                scale: breatheAnim.value,
                child: child,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightSectionBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSection),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                child: child,
              ),
            ),
          ],
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
  final IconData iconData;
  final String? emoji;
  final bool isUrgent;
  final double screenWidth;
  final bool isPinned;
  final Animation<double>? glowAnim;
  final VoidCallback onTap;

  const _ConditionCard({
    required this.index,
    required this.illness,
    required this.iconData,
    this.emoji,
    required this.isUrgent,
    required this.screenWidth,
    this.isPinned = false,
    this.glowAnim,
    required this.onTap,
  });

  @override
  State<_ConditionCard> createState() => _ConditionCardState();
}

class _ConditionCardState extends State<_ConditionCard>
    with TickerProviderStateMixin {
  // ── Staggered entrance (fast) ────────────────────────────────────
  late AnimationController _staggerCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Press animation ───────────────────────────────────────────
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  // ── Icon entrance pulse + heartbeat loop ──────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Staggered entrance — instant (60ms, no delay)
    _staggerCtrl = AnimationController(
      duration: const Duration(milliseconds: 60),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOutCubic,
    ));

    // Start immediately — no staggered delay
    Future.microtask(() {
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

    // Icon pulse entrance + continuous soft heartbeat
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnim = TweenSequence<double>([
      // Entrance pulse (plays once)
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.04), weight: 20),
      // Soft continuous heartbeat loop
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0), weight: 65),
    ]).animate(CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeInOutSine,
    ));

    // Repeat the heartbeat indefinitely after entrance
    _pulseCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseCtrl.repeat(
          period: const Duration(milliseconds: 3000),
          reverse: true,
        );
      }
    });
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
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
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
                emoji: widget.emoji,
                isUrgent: widget.isUrgent,
                pulseAnim: _pulseAnim,
                glowAnim: widget.glowAnim,
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
  final IconData iconData;
  final String? emoji;
  final bool isUrgent;
  final Animation<double> pulseAnim;
  final Animation<double>? glowAnim;

  const _CardContent({
    required this.illness,
    required this.iconData,
    this.emoji,
    required this.isUrgent,
    required this.pulseAnim,
    this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final glowValue = glowAnim?.value ?? 0.0;
        final cardColor = Color.lerp(
          Colors.white,
          const Color(0xFFF4FAF7),
          glowValue,
        )!;
        return Container(
          height: 72,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: cardColor,
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
                        color: emoji != null
                            ? const Color(0xFFF0FAF5)
                            : AppTheme.lightSectionBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.lightShadowIcon,
                      ),
                      child: emoji != null
                          ? Center(
                              child: Text(
                                emoji!,
                                style: const TextStyle(fontSize: 28),
                              ),
                            )
                          : Icon(
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
      },
    );
  }
}
