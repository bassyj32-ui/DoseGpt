import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/disclaimer_line.dart';
import '../models/drug.dart';
import '../services/dose_calculator.dart';

/// Result screen — light theme.
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
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        appBar: AppBar(
          title: Text(illnessName.isNotEmpty ? illnessName : 'Dose'),
          backgroundColor: AppTheme.lightSurface,
          foregroundColor: AppTheme.lightInk,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(color: AppTheme.lightDivider, height: 0.5),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: result.isOutOfRange
              ? _buildOutOfRange(context)
              : _buildResult(context),
        ),
      ),
    );
  }

  Widget _buildOutOfRange(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.lightAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.lightAccent,
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          drug.drugNameEn,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightInkMuted,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          result.outOfRangeMessage ??
              'This weight is outside the safe range for this calculation. '
              'Please double-check the weight or consult a colleague/refer the patient.',
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.lightInk,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (drug.referralTriggerText != null) ...[
          const SizedBox(height: 16),
          _WarningBanner(
            icon: Icons.local_hospital,
            message: drug.referralTriggerText!,
            color: AppTheme.lightAccent,
          ),
        ],
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'New Patient',
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        const SizedBox(height: 20),
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
        // Drug name + patient info
        _LightCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drug.drugNameEn,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightInkMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${weightKg.toStringAsFixed(1)} kg · ${ageMonths ~/ 12}y ${ageMonths % 12}m',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.lightInkSubtle,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Hero dose result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.lightShadowCard,
          ),
          child: Column(
            children: [
              Text(
                result.prescription ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightNavActive,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              if (result.calculatedMl != null) ...[
                const SizedBox(height: 12),
                _DoseVisual(
                  calculatedMl: result.calculatedMl!,
                  maxSafeMl: _maxSafeMl,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Safety warning
        if (result.safetyWarning != null)
          _WarningBanner(
            icon: hasCriticalWarning ? Icons.warning : Icons.info_outline,
            message: result.safetyWarning!,
            color: hasCriticalWarning ? AppTheme.lightAccent : AppTheme.accentGold,
          ),

        if (result.safetyWarning != null) const SizedBox(height: 8),

        // Duration warning
        if (result.durationWarning != null) ...[
          _WarningBanner(
            icon: Icons.access_time,
            message: result.durationWarning!,
            color: AppTheme.accentGold,
          ),
          const SizedBox(height: 8),
        ],

        // Calculation toggle
        _CalculationToggle(result: result, drug: drug),

        const SizedBox(height: 16),

        // Source
        _LightCard(
          child: Row(
            children: [
              Icon(Icons.article_outlined,
                  size: 16, color: AppTheme.lightInkSubtle),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Source: ${drug.sourceName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.lightInkMuted,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // New Calculation button
        PrimaryButton(
          label: 'New Patient',
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),

        const SizedBox(height: 16),

        // Disclaimer
        const DisclaimerLine(),
      ],
    );
  }

  double? get _maxSafeMl {
    if (drug.concentrations == null || drug.concentrations!.isEmpty) return null;
    return drug.concentrations!.first.maxSafeMl;
  }
}

// ── Light card ─────────────────────────────────────────────────

class _LightCard extends StatelessWidget {
  final Widget child;
  const _LightCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// ── Dose volume bar ────────────────────────────────────────────

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dose volume: ${calculatedMl.toStringAsFixed(1)} ml',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightInkMuted,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 12,
            width: double.infinity,
            color: AppTheme.lightCardBg,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fillPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: fillPercent > 0.9
                      ? AppTheme.lightAccent
                      : AppTheme.lightNavActive,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Calculation toggle ─────────────────────────────────────────

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
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightCardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.lightInkMuted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _expanded ? 'Hide calculation' : 'Show calculation',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.lightInkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded && widget.result.formula != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightCardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.result.formula!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.lightInkMuted,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Warning banner ─────────────────────────────────────────────

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
