import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Small, muted disclaimer line shown on every Result screen.
/// "Assistive tool only — verify diagnosis and contraindications."
class DisclaimerLine extends StatelessWidget {
  const DisclaimerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Text(
        'Assistive tool only — verify diagnosis and contraindications.',
        style: AppTheme.formulaSource,
        textAlign: TextAlign.center,
      ),
    );
  }
}
