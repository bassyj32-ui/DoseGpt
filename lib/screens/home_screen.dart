import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/condition_icons.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'drug_list_screen.dart';

/// Home Screen — Light Mode
///
/// Apple Health-inspired design:
///   - White background, clean and clinical
///   - Vertically scrollable list of pill-shaped cards
///   - Custom glass-style icons in white rounded frames
///   - Staggered card entrance + press-down animation
///   - Responsive card width (full-width with max cap)
///   - Urgent accent lines on Malaria & Pneumonia
class HomeScreen extends StatelessWidget {
  final ClinicalData data;

  const HomeScreen({super.key, required this.data});

  /// Map illness ID → icon painter
  static CustomPainter iconPainterFor(String id) {
    switch (id) {
      case 'malaria':
        return MosquitoIconPainter();
      case 'pneumonia':
        return LungsIconPainter();
      case 'diarrhea':
        return DropletIconPainter();
      case 'fever':
        return ThermometerIconPainter();
      case 'uti':
        return KidneyIconPainter();
      case 'tonsillitis':
        return ThroatIconPainter();
      case 'otitis_media':
        return EarIconPainter();
      case 'asthma':
        return InhalerIconPainter();
      case 'hypertension':
        return HeartIconPainter();
      case 'diabetes':
        return DropletIconPainter();
      case 'dyspepsia':
        return StomachIconPainter();
      case 'typhoid':
        return TyphoidIconPainter();
      default:
        return MosquitoIconPainter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final illnesses = List<Illness>.from(data.illnesses)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    // All illnesses are shown in display_order — no hardcoded filtering
    final filtered = illnesses;

    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: filtered.length + 1, // +1 for top spacer
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 8); // Top breathing room
        }
        final illness = filtered[index - 1];
        final cardIndex = index - 1;
        final isUrgent = illness.urgentAccent;
        return _ConditionCard(
          index: cardIndex,
          illness: illness,
          painter: iconPainterFor(illness.id),
          isUrgent: isUrgent,
          screenWidth: screenWidth,
          onTap: () => _navigateToDrugList(context, data, illness.id),
        );
      },
    );
  }

  void _navigateToDrugList(
      BuildContext context, ClinicalData data, String illnessId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrugListScreen(
          data: data,
          illnessId: illnessId,
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
  final CustomPainter painter;
  final bool isUrgent;
  final double screenWidth;
  final VoidCallback onTap;

  const _ConditionCard({
    required this.index,
    required this.illness,
    required this.painter,
    required this.isUrgent,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  State<_ConditionCard> createState() => _ConditionCardState();
}

class _ConditionCardState extends State<_ConditionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

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

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _staggerCtrl.forward();
    });

    // Press-down spring
    _pressCtrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive card width
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
                  animation: _scaleAnim,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                  child: _CardContent(
                    illness: widget.illness,
                    painter: widget.painter,
                    isUrgent: widget.isUrgent,
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
// Card Content (stateless — no animation)
// ═══════════════════════════════════════════════════════════════════
class _CardContent extends StatelessWidget {
  final Illness illness;
  final CustomPainter painter;
  final bool isUrgent;

  const _CardContent({
    required this.illness,
    required this.painter,
    required this.isUrgent,
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
          // ── Main content row ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Constant spacer for alignment consistency
              const SizedBox(width: 12),

              // ── Icon frame ────────────────────────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.lightShadowIcon,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: CustomPaint(
                    size: const Size(34, 34),
                    painter: painter,
                  ),
                ),
              ),

              // ── Label ─────────────────────────────────────────
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

              // ── Chevron ───────────────────────────────────────
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

          // ── Urgent accent bar (overlay — doesn't affect layout)
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
