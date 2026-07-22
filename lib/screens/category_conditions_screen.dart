import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../widgets/app_theme.dart';
import '../widgets/condition_icons.dart';
import '../models/category.dart';
import '../models/illness.dart';
import '../services/data_loader.dart';
import 'drug_list_screen.dart';

/// Displays all conditions that belong to a given body-system [Category].
///
/// Accessed by tapping a [CategoryCard] on the home screen.
/// Each condition card reuses the same hero pill styling and on tap
/// navigates to the normal drug list flow.
class CategoryConditionsScreen extends StatelessWidget {
  final ClinicalData data;
  final Category category;

  const CategoryConditionsScreen({
    super.key,
    required this.data,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final illnesses = data.getIllnessesForCategory(category.id);
    final iconData = ConditionIcons.categoryIconFor(category.id);

    return Scaffold(
      backgroundColor: AppTheme.lightSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.lightSurface,
        foregroundColor: AppTheme.lightInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.lightCardBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                iconData,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category.nameEn,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightInk,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: illnesses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No conditions available in this category.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.lightInkMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 12),
              itemCount: illnesses.length,
              itemBuilder: (context, index) {
                final illness = illnesses[index];
                final isUrgent = illness.urgentAccent;
                return _ConditionCard(
                  index: index,
                  illness: illness,
                  iconData: ConditionIcons.iconFor(illness.id),
                  isUrgent: isUrgent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DrugListScreen(
                          data: data,
                          illnessId: illness.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Reusable condition card — same design as home screen hero cards
// but with simpler entrance animation (no staggered delay needed)
// ═══════════════════════════════════════════════════════════════════
class _ConditionCard extends StatefulWidget {
  final int index;
  final Illness illness;
  final IconData iconData;
  final bool isUrgent;
  final VoidCallback onTap;

  const _ConditionCard({
    required this.index,
    required this.illness,
    required this.iconData,
    required this.isUrgent,
    required this.onTap,
  });

  @override
  State<_ConditionCard> createState() => _ConditionCardState();
}

class _ConditionCardState extends State<_ConditionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOutCubic,
    );
    final delay = Duration(milliseconds: 50 * widget.index);
    Future.delayed(delay, () {
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 24;
    const double maxCardWidth = 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        (screenWidth - horizontalPadding * 2).clamp(0.0, maxCardWidth);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding)
            .copyWith(bottom: 14),
        child: Center(
          child: SizedBox(
            width: cardWidth,
            child: GestureDetector(
              onTap: widget.onTap,
              child: _CardContent(
                illness: widget.illness,
                iconData: widget.iconData,
                isUrgent: widget.isUrgent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final Illness illness;
  final IconData iconData;
  final bool isUrgent;

  const _CardContent({
    required this.illness,
    required this.iconData,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.lightShadowIcon,
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  illness.nameEn,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightInk,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
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
