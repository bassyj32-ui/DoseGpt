import 'package:flutter/material.dart';
import 'app_theme.dart';

/// A reusable illness card component.
/// Pill-shaped, surface-card background, soft shadow, icon left-aligned + name + chevron.
class DoseCard extends StatelessWidget {
  final String label;
  final bool urgentAccent;
  final bool isRecommended;
  final VoidCallback? onTap;

  const DoseCard({
    super.key,
    required this.label,
    this.urgentAccent = false,
    this.isRecommended = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppTheme.minTapHeight,
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            // Urgent accent line (far left)
            if (urgentAccent)
              Container(
                width: 4,
                height: AppTheme.minTapHeight,
                decoration: const BoxDecoration(
                  color: AppTheme.urgent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    bottomLeft: Radius.circular(24.0),
                  ),
                ),
              )
            else
              const SizedBox(width: 4),

            // Icon area (placeholder)
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: AppTheme.primary,
                size: 22,
              ),
            ),

            const SizedBox(width: AppTheme.spacingMd),

            // Label
            Expanded(
              child: Text(
                label,
                style: AppTheme.cardLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Recommended tag
            if (isRecommended)
              Container(
                margin: const EdgeInsets.only(right: AppTheme.spacingXs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),

            // Chevron
            const Padding(
              padding: EdgeInsets.only(right: AppTheme.spacingMd),
              child: Icon(
                Icons.chevron_right,
                color: AppTheme.inkMuted,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
