import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../models/category.dart';
import 'app_theme.dart';
import 'condition_icons.dart';

/// A compact card representing a body-system [Category].
///
/// Designed to be visually distinct from the hero condition cards:
/// - 56px height (vs 72px)
/// - White background with a subtle teal left border accent
/// - Smaller 32px icon frame
/// - 15px medium-weight label
/// - Gentle entrance animation (no staggered delay)
class CategoryCard extends StatefulWidget {
  final Category category;
  final double screenWidth;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOutCubic,
    );
    // Short delay so category cards appear after hero cards
    Future.delayed(const Duration(milliseconds: 450), () {
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
    // Fills whatever width the parent gives it.
    //
    // This used to derive its own width from screenWidth minus a 24px
    // gutter, capped at 600. That double-applied the gutter on mobile
    // inside the section container, and fought the desktop grid, where the
    // parent has already divided the available space between columns.
    const double cardWidth = double.infinity;

    final iconData = ConditionIcons.categoryIconFor(widget.category.id);
    final dotColor = _dotColorFor(widget.category.id);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Center(
          child: SizedBox(
            width: cardWidth,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: widget.onTap,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFE8EBE9),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF08805B).withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      // ── Colored dot ──────────────────────────
                      const SizedBox(width: 16),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ── Icon frame ────────────────────────────
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          iconData,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),

                      // ── Label ─────────────────────────────────
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.category.nameEn,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.lightInkMuted,
                            letterSpacing: 0.15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // ── Chevron ───────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          LucideIcons.chevron_right,
                          size: 16,
                          color: AppTheme.lightInkSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns a subtle accent colour for the category dot.
  Color _dotColorFor(String categoryId) {
    switch (categoryId) {
      case 'respiratory':
        return const Color(0xFF1976D2); // blue
      case 'git':
        return const Color(0xFFFBC02D); // amber
      case 'infectious':
        return const Color(0xFFD32F2F); // red
      case 'ent':
        return const Color(0xFFAD1457); // pink
      case 'renal':
        return const Color(0xFF7B1FA2); // purple
      case 'dermatology':
        return const Color(0xFF1565C0); // blue
      case 'skin':
        return const Color(0xFF00695C); // teal
      case 'cardiovascular':
        return const Color(0xFFD32F2F); // red
      case 'endocrine':
        return const Color(0xFFF57C00); // orange
      default:
        return AppTheme.primary;
    }
  }
}
