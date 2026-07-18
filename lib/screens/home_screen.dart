import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/dose_card.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'weight_entry_screen.dart';

/// Home Screen
///
/// Inspired by Headspace's welcoming rhythm and Apple's spatial precision.
/// The screen is organized into distinct sections with generous whitespace,
/// a hero greeting, a beautiful search bar, and horizontal card rows.
///
/// Every element breathes. Nothing feels cramped. The hierarchy guides
/// the eye naturally from greeting → search → featured → more conditions.
class HomeScreen extends StatelessWidget {
  final ClinicalData data;

  const HomeScreen({super.key, required this.data});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final illnesses = List<Illness>.from(data.illnesses)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    // Split into featured (first 5) and more (remaining 5)
    const int featuredCount = 5;
    final featured = illnesses.take(featuredCount).toList();
    final more = illnesses.skip(featuredCount).toList();

    return Stack(
      children: [
        // ── Background image ────────────────────────────────────
        Positioned.fill(
          child: Image.asset(
            'assets/images/background/baby_photo.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.12),
          ),
        ),

        // ── Background color wash ──────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00695C).withValues(alpha: 0.2),
                    const Color(0xFF1DB954).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── Dark overlay for depth ──────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.surface.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.transparent,
                    AppTheme.surface,
                  ],
                  stops: const [0.0, 0.15, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── Scrollable content ──────────────────────────────────
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
        // ── Greeting + Hero Search ──────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.space20,
              AppTheme.space8,
              AppTheme.space20,
              AppTheme.space4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtle greeting
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space4),
                  child: Text(
                    _greeting(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.inkMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Main headline with icon
                Row(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 26,
                      color: AppTheme.primary,
                    ),
                    SizedBox(width: AppTheme.space12),
                    Flexible(
                      child: Text(
                        'Find the right dose',
                        style: AppTheme.displayMedium,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.space20),

                // Hero search bar
                _HeroSearchBar(
                  onTap: () {
                    // TODO: full search experience
                  },
                ),

                SizedBox(height: AppTheme.space24),

                // Section label
                Text(
                  'Featured Conditions',
                  style: AppTheme.headingLarge,
                ),

                SizedBox(height: AppTheme.space4),

                // Count
                Text(
                  '${featured.length} of ${illnesses.length} conditions',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
        ),

        // ── Featured Row (larger cards) ─────────────────────────
        _buildFeaturedRow(featured, data),

        // ── More Conditions Section ────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.space20,
              AppTheme.space36,
              AppTheme.space20,
              AppTheme.space4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Conditions',
                  style: AppTheme.headingLarge,
                ),
                Text(
                  '${more.length} remaining',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
        ),

        // ── All Conditions Row (compact cards) ────────────────
        _buildMoreRow(more, data),

        // ── Bottom padding for safe area ───────────────────────
        SliverToBoxAdapter(
          child: SizedBox(height: AppTheme.space40),
        ),
      ],
    ),

      ],
    );
  }

  // ── Featured Row ──────────────────────────────────────────────
  Widget _buildFeaturedRow(List<Illness> illnesses, ClinicalData data) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 188,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
          itemCount: illnesses.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppTheme.space16),
          itemBuilder: (context, index) {
            final illness = illnesses[index];
            return _StaggeredCard(
              index: index,
              child: DoseCard(
                label: illness.nameEn,
                width: 156,
                height: 188,
                imagePath: 'assets/images/conditions/${illness.id}.jpg',
                fallbackGradient: AppTheme.conditionGradients[illness.id] ??
                    [AppTheme.surfaceCard, AppTheme.surfaceCard],
                onTap: () => _navigateToWeightEntry(context, data, illness.id),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── More Conditions Row ───────────────────────────────────────
  Widget _buildMoreRow(List<Illness> illnesses, ClinicalData data) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 144,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
          itemCount: illnesses.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppTheme.space12),
          itemBuilder: (context, index) {
            final illness = illnesses[index];
            return _StaggeredCard(
              index: index + 5, // offset so second row starts after first
              child: DoseCard(
                label: illness.nameEn,
                width: 144,
                height: 144,
                imagePath: 'assets/images/conditions/${illness.id}.jpg',
                fallbackGradient: AppTheme.conditionGradients[illness.id] ??
                    [AppTheme.surfaceCard, AppTheme.surfaceCard],
                onTap: () => _navigateToWeightEntry(context, data, illness.id),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToWeightEntry(
      BuildContext context, ClinicalData data, String illnessId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeightEntryScreen(
          data: data,
          illnessId: illnessId,
        ),
      ),
    );
  }
}

// ── Staggered Card Entrance ─────────────────────────────────────
/// Wraps a card with a fade+slide entrance animation.
/// Each card animates with a 60ms delay after the previous one.
class _StaggeredCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredCard({required this.index, required this.child});

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Stagger: 60ms delay per card index
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: widget.child,
      ),
    );
  }
}

// ── Hero Search Bar ─────────────────────────────────────────────
/// A large, beautiful search bar that feels like the primary action.
/// Inspired by Headspace's prominent "Start a session" hero area.
class _HeroSearchBar extends StatefulWidget {
  final VoidCallback? onTap;

  const _HeroSearchBar({this.onTap});

  @override
  State<_HeroSearchBar> createState() => _HeroSearchBarState();
}

class _HeroSearchBarState extends State<_HeroSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderHairline),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppTheme.space16),
            Icon(
              Icons.search_rounded,
              color: AppTheme.inkMuted.withValues(alpha: 0.6),
              size: 22,
            ),
            const SizedBox(width: AppTheme.space12),
            Expanded(
              child: Text(
                'Search conditions or drugs...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.inkMuted.withValues(alpha: 0.5),
                  letterSpacing: 0.1,
                ),
              ),
            ),
            // Subtle CTA badge
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.space12),
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space12,
                    vertical: AppTheme.space6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(
                      alpha: 0.15 + (_pulseAnim.value * 0.1),
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary.withValues(
                        alpha: 0.7 + (_pulseAnim.value * 0.3),
                      ),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
