import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Displays the universal out-of-range / referral message.
class OutOfRangeView extends StatelessWidget {
  final String message;

  const OutOfRangeView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.urgent,
              size: 48,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message,
              style: AppTheme.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
