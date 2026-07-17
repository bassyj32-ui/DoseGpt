import 'package:flutter/material.dart';

/// Small, muted disclaimer line shown on every Result screen.
class DisclaimerLine extends StatelessWidget {
  const DisclaimerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Text(
        'Assistive tool only — verify diagnosis and contraindications.',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
