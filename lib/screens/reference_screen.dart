import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

/// Reference screen — Light mode, inside the main shell.
class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.lightNavActive.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.library_books_outlined,
                color: AppTheme.lightNavActive,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Full reference content, protocol citations, and clinical guidelines will be available here in a future update.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightInkMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
