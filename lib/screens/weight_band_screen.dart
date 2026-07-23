import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../models/drug.dart';
import '../models/illness.dart';
import '../services/dose_calculator.dart';
import 'result_screen.dart';

/// Shows weight bands directly for drugs like Coartem and Primaquine.
/// No weight/age input needed — the user reads the band that matches their patient.
/// The band table is the result itself.
class WeightBandScreen extends StatelessWidget {
  final Drug drug;
  final Illness illness;
  final double? weightKg;
  final int? ageMonths;

  const WeightBandScreen({
    super.key,
    required this.drug,
    required this.illness,
    this.weightKg,
    this.ageMonths,
  });

  @override
  Widget build(BuildContext context) {
    final bands = drug.bands ?? [];

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.lightSurface,
        appBar: AppBar(
          title: Text(illness.nameEn),
          backgroundColor: AppTheme.lightSurface,
          foregroundColor: AppTheme.lightInk,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(color: AppTheme.lightDivider, height: 0.5),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drug name
              Center(
                child: Text(
                  drug.drugNameEn,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightNavActive,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 4),

              // Duration hint
              Center(
                child: Text(
                  _durationHint(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.lightInkMuted,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Weight band table header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.lightShadowCard,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select dose by patient weight:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightInk,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Band items
                    for (int i = 0; i < bands.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      _BandRow(
                        band: bands[i],
                        isLast: i == bands.length - 1,
                        onTap: () =>
                            _showResult(context, bands[i].doseDisplayEn),
                      ),
                    ],
                  ],
                ),
              ),

              // Safety warning
              if (drug.safetyWarning != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.accentGold,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          drug.safetyWarning!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.accentGold,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Notes
              if (drug.notes != null) ...[
                const SizedBox(height: 12),
                Text(
                  drug.notes!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.lightInkMuted,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Source
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightCardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 14,
                      color: AppTheme.lightInkSubtle,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Source: ${drug.sourceName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightInkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _durationHint() {
    final dur = drug.durationDays != null
        ? ' · ${drug.durationDays} days'
        : '';
    return '${drug.frequencyEn}$dur';
  }

  void _showResult(BuildContext context, String doseText) {
    // Build a simple prescription from the selected band
    final durPart =
        drug.durationDays != null ? ' for ${drug.durationDays} day(s)' : '';
    final prescription = '$doseText ${drug.frequencyEn}$durPart';

    // Use DoseCalculator to get a properly formatted result
    final result = DoseResult(
      prescription: prescription,
      formula: 'Weight-based dosing selected from band table.',
      safetyWarning: drug.safetyWarning,
      durationWarning: null,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          drug: drug,
          result: result,
          weightKg: 0,
          ageMonths: 0,
          illnessName: illness.nameEn,
        ),
      ),
    );
  }
}

/// A single band row in the table — tappable to select
class _BandRow extends StatelessWidget {
  final WeightBand band;
  final bool isLast;
  final VoidCallback onTap;

  const _BandRow({
    required this.band,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final weightLabel = _weightLabel();
    final doseLines = band.doseDisplayEn.split('\n');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Weight range badge
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                weightLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            // Dose description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in doseLines)
                    Text(
                      line,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightInk,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.lightInkSubtle,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _weightLabel() {
    final min = band.minKg;
    final max = band.maxKg;
    if (min > 0 && max < double.infinity) return '${min.toStringAsFixed(0)}-${max.toStringAsFixed(0)} kg';
    if (min > 0) return '≥${min.toStringAsFixed(0)} kg';
    if (max < double.infinity) return '<${max.toStringAsFixed(0)} kg';
    return 'All';
  }
}
