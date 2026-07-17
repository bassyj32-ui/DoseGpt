import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/disclaimer_line.dart';
import '../models/drug.dart';
import '../services/dose_calculator.dart';

/// Result screen — displays the calculated dose in a clear,
/// prescription-style format, with optional calculation details.
class ResultScreen extends StatelessWidget {
  final Drug drug;
  final DoseResult result;
  final double weightKg;
  final int ageMonths;
  final String illnessName;

  const ResultScreen({
    super.key,
    required this.drug,
    required this.result,
    required this.weightKg,
    required this.ageMonths,
    this.illnessName = '',
  });

  /// Extracts a simple arg map from the navigator arguments.
  static ResultScreen? fromArguments(Map<String, dynamic> args) {
    final drug = args['drug'] as Drug?;
    final result = args['result'] as DoseResult?;
    final weightKg = args['weightKg'] as double?;
    final ageMonths = args['ageMonths'] as int?;
    final illnessName = args['illnessName'] as String? ?? '';
    if (drug == null || result == null || weightKg == null || ageMonths == null) {
      return null;
    }
    return ResultScreen(
      drug: drug,
      result: result,
      weightKg: weightKg,
      ageMonths: ageMonths,
      illnessName: illnessName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(illnessName.isNotEmpty ? illnessName : 'Dose'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: result.isOutOfRange
            ? _buildOutOfRange(context)
            : _buildResult(context),
      ),
    );
  }

  Widget _buildOutOfRange(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppTheme.spacingXl),
        const Icon(
          Icons.warning_amber_rounded,
          color: AppTheme.urgent,
          size: 64,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Show drug name so user knows what was attempted
        Text(
          drug.drugNameEn,
          style: AppTheme.formulaSource.copyWith(fontSize: 15),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          result.outOfRangeMessage ??
              'This weight is outside the safe range for this calculation. '
              'Please double-check the weight or consult a colleague/refer the patient.',
          style: AppTheme.body,
          textAlign: TextAlign.center,
        ),
        // Show referral trigger if present
        if (drug.referralTriggerText != null) ...[
          const SizedBox(height: AppTheme.spacingMd),
          _WarningBanner(
            icon: Icons.local_hospital,
            message: drug.referralTriggerText!,
            color: AppTheme.urgent,
          ),
        ],
        const SizedBox(height: AppTheme.spacingXl),
        PrimaryButton(
          label: 'New Calculation',
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        const DisclaimerLine(),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final bool hasCriticalWarning = result.safetyWarning != null &&
        (result.safetyWarning!.contains('dangerous') ||
            result.safetyWarning!.contains('G6PD') ||
            result.safetyWarning!.contains('contraindicated'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drug name
        Text(
          drug.drugNameEn,
          style: AppTheme.formulaSource.copyWith(fontSize: 15),
        ),
        const SizedBox(height: AppTheme.spacingSm),

        // Patient info line
        Text(
          '${weightKg.toStringAsFixed(1)} kg · ${ageMonths ~/ 12}y ${ageMonths % 12}m',
          style: AppTheme.formulaSource,
        ),
        const SizedBox(height: AppTheme.spacingSm),

        // Hero prescription line
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(
            result.prescription ?? '',
            style: AppTheme.doseResult.copyWith(fontSize: 20),
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Dose visual (syringe-like indicator bar)
        if (result.calculatedMl != null) ...[
          _DoseVisual(
            calculatedMl: result.calculatedMl!,
            maxSafeMl: _maxSafeMl,
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],

        // Safety warning — red for critical, gold for informational
        if (result.safetyWarning != null)
          _WarningBanner(
            icon: hasCriticalWarning ? Icons.warning : Icons.info_outline,
            message: result.safetyWarning!,
            color: hasCriticalWarning ? AppTheme.urgent : AppTheme.accentGold,
          ),

        if (result.safetyWarning != null)
          const SizedBox(height: AppTheme.spacingSm),

        // Duration warning
        if (result.durationWarning != null) ...[
          _WarningBanner(
            icon: Icons.access_time,
            message: result.durationWarning!,
            color: AppTheme.accentGold,
          ),
          const SizedBox(height: AppTheme.spacingSm),
        ],

        // "Show calculation" toggle
        _CalculationToggle(result: result, drug: drug),

        const SizedBox(height: AppTheme.spacingMd),

        // Source
        Text(
          'Source: ${drug.sourceName}',
          style: AppTheme.formulaSource,
        ),

        const SizedBox(height: AppTheme.spacingLg),

        // New Calculation button
        PrimaryButton(
          label: 'New Calculation',
          onPressed: () => Navigator.of(context).pop(),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Per-result disclaimer
        const DisclaimerLine(),
      ],
    );
  }

  double? get _maxSafeMl {
    if (drug.concentrations == null || drug.concentrations!.isEmpty) return null;
    return drug.concentrations!.first.maxSafeMl;
  }
}

/// A visual indicator showing the dose amount (simplified bar).
class _DoseVisual extends StatelessWidget {
  final double calculatedMl;
  final double? maxSafeMl;

  const _DoseVisual({required this.calculatedMl, this.maxSafeMl});

  @override
  Widget build(BuildContext context) {
    final double fillPercent;
    if (maxSafeMl != null && maxSafeMl! > 0) {
      fillPercent = (calculatedMl / maxSafeMl!).clamp(0.0, 1.0);
    } else {
      fillPercent = (calculatedMl / 20).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dose volume: ${calculatedMl.toStringAsFixed(1)} ml',
            style: AppTheme.cardLabel,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            child: Container(
              height: 16,
              width: double.infinity,
              color: AppTheme.borderHairline,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fillPercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: fillPercent > 0.9
                        ? AppTheme.urgent
                        : AppTheme.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible "Show calculation" section.
class _CalculationToggle extends StatefulWidget {
  final DoseResult result;
  final Drug drug;

  const _CalculationToggle({required this.result, required this.drug});

  @override
  State<_CalculationToggle> createState() => _CalculationToggleState();
}

class _CalculationToggleState extends State<_CalculationToggle> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.inkMuted,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  _expanded ? 'Hide calculation' : 'Show calculation',
                  style: AppTheme.formulaSource,
                ),
              ],
            ),
          ),
        ),
        if (_expanded && widget.result.formula != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppTheme.spacingXs),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              widget.result.formula!,
              style: AppTheme.formulaSource,
            ),
          ),
      ],
    );
  }
}

/// A warning/info banner widget.
class _WarningBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _WarningBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              message,
              style: AppTheme.formulaSource.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
