import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

/// Reference screen — stubbed as "Coming soon" for MVP1.
class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: const Icon(
                Icons.library_books_outlined,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            const Text(
              'Full reference content, protocol citations, and clinical guidelines will be available here in a future update.',
              style: AppTheme.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
