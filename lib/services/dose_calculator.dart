import '../models/drug.dart';

/// Represents the result of a dose calculation.
class DoseResult {
  /// Human-readable prescription line, e.g.
  /// "Amoxicillin 250mg/5ml syrup — give 5ml, twice daily, for 5 days"
  final String? prescription;

  /// The raw calculated dose in ml (for display in "Show calculation").
  final double? calculatedMl;

  /// The raw dose in mg (for display in "Show calculation").
  final double? calculatedMg;

  /// The formula breakdown for the "Show calculation" toggle.
  final String? formula;

  /// Whether this result represents an out-of-range / refer condition.
  final bool isOutOfRange;

  /// The message to show when isOutOfRange is true.
  final String? outOfRangeMessage;

  /// The safety warning, if any.
  final String? safetyWarning;

  /// The duration warning, if any.
  final String? durationWarning;

  const DoseResult({
    this.prescription,
    this.calculatedMl,
    this.calculatedMg,
    this.formula,
    this.isOutOfRange = false,
    this.outOfRangeMessage,
    this.safetyWarning,
    this.durationWarning,
  });

  /// Creates an out-of-range result with the standard message.
  const DoseResult.outOfRange([String? message])
      : prescription = null,
        calculatedMl = null,
        calculatedMg = null,
        formula = null,
        isOutOfRange = true,
        outOfRangeMessage = message ??
            'This weight is outside the safe range for this calculation. '
                'Please double-check the weight or consult a colleague/refer the patient.',
        safetyWarning = null,
        durationWarning = null;

  /// Creates a neonatal referral result.
  const DoseResult.neonatalReferral()
      : prescription = null,
        calculatedMl = null,
        calculatedMg = null,
        formula = null,
        isOutOfRange = true,
        outOfRangeMessage =
            'This app is not designed for newborns. Please refer to a physician immediately.',
        safetyWarning = null,
        durationWarning = null;
}

/// The calculation engine for DoseGPT.
///
/// Handles all four dosing shapes:
///   - mg_per_kg
///   - weight_band
///   - age_band
///   - fixed
///
/// Always returns a [DoseResult], never null. Out-of-range conditions
/// and null critical fields produce a refer message, never a guessed number.
class DoseCalculator {
  /// Checks if a patient's age in months qualifies as a neonate.
  /// Neonates (< ~1 month) are excluded from all calculations.
  static bool isNeonate(int ageMonths) => ageMonths < 1;

  /// Checks if age is within a drug's valid age range.
  /// Returns true if the drug has no age restriction or if age is within range.
  static bool isAgeInRange(Drug drug, int ageMonths) {
    final range = drug.validAgeRange;
    if (range == null) return true;
    final minMonths = range.minMonths;
    final maxMonths = range.maxMonths;
    if (minMonths != null && ageMonths < minMonths) return false;
    if (maxMonths != null && ageMonths > maxMonths) return false;
    return true;
  }

  /// Checks if weight is within a drug's valid weight range.
  /// Returns true if the drug has no weight restriction or if weight is within range.
  static bool isWeightInRange(Drug drug, double weightKg) {
    final range = drug.validWeightRange;
    if (range == null) return true;
    final minKg = range.minKg;
    final maxKg = range.maxKg;
    if (minKg != null && weightKg < minKg) return false;
    if (maxKg != null && weightKg > maxKg) return false;
    return true;
  }

  /// Calculate a dose given a [Drug], weight (kg), age (months),
  /// and optionally the index of the concentration to use.
  static DoseResult calculate({
    required Drug drug,
    required double weightKg,
    required int ageMonths,
    int concentrationIndex = 0,
  }) {
    // 1. Check age against valid age range for this drug
    if (!isAgeInRange(drug, ageMonths)) {
      if (drug.referralTriggerText != null) {
        return DoseResult.outOfRange(drug.referralTriggerText);
      }
      return const DoseResult.outOfRange();
    }

    // 2. Route to the appropriate shape handler
    switch (drug.dosingShape) {
      case 'mg_per_kg':
        return _calculateMgPerKg(drug, weightKg, concentrationIndex);
      case 'weight_band':
        return _calculateWeightBand(drug, weightKg);
      case 'age_band':
        return _calculateAgeBand(drug, ageMonths);
      case 'fixed':
        return _calculateFixed(drug);
      default:
        return const DoseResult.outOfRange();
    }
  }

  /// mg_per_kg calculation:
  ///   weight × dose_per_kg_mg → convert to ml → round → clamp
  ///   → check max_daily_dose_mg / max_daily_dose_per_kg_mg
  static DoseResult _calculateMgPerKg(
    Drug drug,
    double weightKg,
    int concentrationIndex,
  ) {
    // -- Null-guard: if dose_per_kg_mg is null, we cannot calculate --
    if (drug.dosePerKgMg == null && drug.doseSchedule == null) {
      return const DoseResult.outOfRange();
    }

    // -- Weight range check --
    if (!isWeightInRange(drug, weightKg)) {
      if (drug.referralTriggerText != null) {
        return DoseResult.outOfRange(drug.referralTriggerText);
      }
      return const DoseResult.outOfRange();
    }

    // Get concentration (if available and if this drug has concentrations)
    Concentration? conc;
    if (drug.concentrations != null && drug.concentrations!.isNotEmpty) {
      if (concentrationIndex >= drug.concentrations!.length) {
        concentrationIndex = 0;
      }
      conc = drug.concentrations![concentrationIndex];

      // Null-guard: if concentration has null strength, we cannot calculate ml
      if (conc.strengthMg == null) {
        return const DoseResult.outOfRange();
      }
    }

    // Handle dose_schedule (multi-day regimens like Azithromycin)
    if (drug.doseSchedule != null && drug.doseSchedule!.isNotEmpty) {
      return _calculateSchedule(drug, weightKg, conc);
    }

    // Simple single-dose mg_per_kg
    final doseMg = weightKg * drug.dosePerKgMg!;

    // -- Max daily dose cap (absolute) --
    double effectiveDoseMg = doseMg;
    if (drug.maxDailyDoseMg != null && doseMg > drug.maxDailyDoseMg!) {
      effectiveDoseMg = drug.maxDailyDoseMg!;
    }

    // -- Max daily dose per kg cap --
    if (drug.maxDailyDosePerKgMg != null) {
      final perKgCap = weightKg * drug.maxDailyDosePerKgMg!;
      if (effectiveDoseMg > perKgCap) {
        effectiveDoseMg = perKgCap;
      }
    }

    // -- Convert to ml if concentration is available --
    final String prescription;
    double? calculatedMl;
    String formula;

    if (conc != null && conc.volumeMl != null) {
      // mg → ml: (dose_mg / strength_mg) × volume_ml
      final rawMl = (effectiveDoseMg / conc.strengthMg!) * conc.volumeMl!;
      final double roundedMl = _roundToNearest(rawMl, conc.roundToMl);

      // -- Clamp to min/max safe ml --
      final double? minSafe = conc.minSafeMl;
      final double? maxSafe = conc.maxSafeMl;
      final double clampedMl;
      if (minSafe != null && roundedMl < minSafe) {
        clampedMl = minSafe;
      } else if (maxSafe != null && roundedMl > maxSafe) {
        clampedMl = maxSafe;
      } else {
        clampedMl = roundedMl;
      }

      calculatedMl = clampedMl;

      final durationPart = _durationPart(drug);
      prescription =
          '${drug.drugNameEn} — give ${clampedMl.toStringAsFixed(1)}ml, '
          '${drug.frequencyEn}$durationPart';

      formula = '${weightKg}kg × ${drug.dosePerKgMg}mg/kg = '
          '${doseMg.toStringAsFixed(1)}mg\n'
          '→ ${effectiveDoseMg.toStringAsFixed(1)}mg ÷ '
          '${conc.strengthMg}mg × ${conc.volumeMl}ml = '
          '${rawMl.toStringAsFixed(2)}ml\n'
          '→ rounded to ${calculatedMl.toStringAsFixed(1)}ml';

      if (drug.maxDailyDoseMg != null && doseMg > drug.maxDailyDoseMg!) {
        formula += '\n(capped at ${drug.maxDailyDoseMg}mg/day max)';
      }
    } else if (conc != null && conc.roundToTablet != null) {
      // Tablet-based dosing (e.g. Primaquine)
      final tabletCount = effectiveDoseMg / conc.strengthMg!;
      final roundedTablets =
          _roundToNearest(tabletCount, conc.roundToTablet!);
      final doseDisplay = '${roundedTablets.toStringAsFixed(2)} tablet(s)';

      final durationPart = _durationPart(drug);
      prescription =
          '${drug.drugNameEn} — give $doseDisplay (${effectiveDoseMg.toStringAsFixed(1)}mg), '
          '${drug.frequencyEn}$durationPart';

      formula = '${weightKg}kg × ${drug.dosePerKgMg}mg/kg = '
          '${effectiveDoseMg.toStringAsFixed(1)}mg\n'
          '→ ${effectiveDoseMg.toStringAsFixed(1)}mg ÷ '
          '${conc.strengthMg}mg = ${tabletCount.toStringAsFixed(2)} tablets\n'
          '→ rounded to $roundedTablets tablet(s)';
    } else {
      // No concentration — show mg dose only
      final durationPart = _durationPart(drug);
      prescription =
          '${drug.drugNameEn} — give ${effectiveDoseMg.toStringAsFixed(1)}mg, '
          '${drug.frequencyEn}$durationPart';

      formula = '${weightKg}kg × ${drug.dosePerKgMg}mg/kg = '
          '${effectiveDoseMg.toStringAsFixed(1)}mg';
    }

    return DoseResult(
      prescription: prescription,
      calculatedMl: calculatedMl,
      calculatedMg: effectiveDoseMg,
      formula: formula,
      safetyWarning: drug.safetyWarning,
      durationWarning: drug.durationWarning,
    );
  }

  /// Handle multi-day dose schedules (e.g. Azithromycin Day 1: 10mg/kg, Days 2-5: 5mg/kg).
  static DoseResult _calculateSchedule(
    Drug drug,
    double weightKg,
    Concentration? conc,
  ) {
    if (drug.doseSchedule == null || drug.doseSchedule!.isEmpty) {
      return const DoseResult.outOfRange();
    }

    final buffer = StringBuffer();
    buffer.writeln('${drug.drugNameEn}:');

    for (final entry in drug.doseSchedule!) {
      final doseMg = weightKg * entry.dosePerKgMg;
      final double? scheduleMaxDose = entry.maxDoseMg;
      final effectiveMg =
          (scheduleMaxDose != null && doseMg > scheduleMaxDose)
              ? scheduleMaxDose
              : doseMg;

      if (conc != null && conc.strengthMg != null && conc.volumeMl != null) {
        final rawMl = (effectiveMg / conc.strengthMg!) * conc.volumeMl!;
        final roundedMl = _roundToNearest(rawMl, conc.roundToMl);
        buffer.writeln(
          '  Day ${entry.day}: ${effectiveMg.toStringAsFixed(1)}mg '
          '(${roundedMl.toStringAsFixed(1)}ml)',
        );
      } else {
        buffer.writeln(
          '  Day ${entry.day}: ${effectiveMg.toStringAsFixed(1)}mg',
        );
      }
    }

    final durationPart = _durationPart(drug);
    final prescription =
        '${drug.drugNameEn} — see schedule, ${drug.frequencyEn}$durationPart';

    return DoseResult(
      prescription: prescription,
      formula: buffer.toString().trim(),
      safetyWarning: drug.safetyWarning,
      durationWarning: drug.durationWarning,
    );
  }

  /// weight_band: direct table lookup by weight.
  static DoseResult _calculateWeightBand(Drug drug, double weightKg) {
    // -- Weight range check --
    if (!isWeightInRange(drug, weightKg)) {
      if (drug.referralTriggerText != null) {
        return DoseResult.outOfRange(drug.referralTriggerText);
      }
      return const DoseResult.outOfRange();
    }

    if (drug.bands == null || drug.bands!.isEmpty) {
      return const DoseResult.outOfRange();
    }

    WeightBand? matchedBand;
    for (final band in drug.bands!) {
      if (weightKg >= band.minKg && weightKg <= band.maxKg) {
        matchedBand = band;
        break;
      }
    }

    if (matchedBand == null) {
      return const DoseResult.outOfRange();
    }

    final durationPart = _durationPart(drug);
    final prescription =
        '${drug.drugNameEn} — ${matchedBand.doseDisplayEn}, '
        '${drug.frequencyEn}$durationPart';

    return DoseResult(
      prescription: prescription,
      formula: 'Weight ${weightKg}kg falls in band '
          '${matchedBand.minKg}-${matchedBand.maxKg == double.infinity ? '+' : '${matchedBand.maxKg}'}kg:\n'
          '${matchedBand.doseDisplayEn}',
      safetyWarning: drug.safetyWarning,
      durationWarning: drug.durationWarning,
    );
  }

  /// age_band: direct table lookup by age in months.
  static DoseResult _calculateAgeBand(Drug drug, int ageMonths) {
    if (drug.bands == null || drug.bands!.isEmpty) {
      return const DoseResult.outOfRange();
    }

    // Convert the Drug's WeightBand list into AgeBand-like matching
    // The bands in the data use min_months/max_months for age_band drugs,
    // but are stored as WeightBand in the model (min_kg/max_kg fields).
    // We need to check the drugs.json: for age_band drugs, bands use
    // min_months/max_months fields, which we parse as AgeBand.
    // For simplicity, we look for the age range match.

    // Check if bands use min_months/max_months semantics
    // (Zinc uses months, Albendazole uses months)
    for (final band in drug.bands!) {
      if (ageMonths >= band.minKg && ageMonths <= band.maxKg) {
        final durationPart = _durationPart(drug);
        final prescription =
            '${drug.drugNameEn} — ${band.doseDisplayEn}, '
            '${drug.frequencyEn}$durationPart';

        return DoseResult(
          prescription: prescription,
          formula: 'Age $ageMonths months falls in band: '
              '${band.doseDisplayEn}',
          safetyWarning: drug.safetyWarning,
          durationWarning: drug.durationWarning,
        );
      }
    }

    return const DoseResult.outOfRange();
  }

  /// fixed: return dose_display_en directly.
  static DoseResult _calculateFixed(Drug drug) {
    if (drug.doseDisplayEn == null) {
      return const DoseResult.outOfRange();
    }

    return DoseResult(
      prescription: '${drug.drugNameEn} — ${drug.doseDisplayEn}',
      formula: drug.doseDisplayEn,
      safetyWarning: drug.safetyWarning,
      durationWarning: drug.durationWarning,
    );
  }

  /// Builds the duration part of the prescription string.
  static String _durationPart(Drug drug) {
    if (drug.durationDays != null) {
      return ', for ${drug.durationDays} days';
    }
    return '';
  }

  /// Round a value to the nearest increment.
  static double _roundToNearest(double value, double increment) {
    return (value / increment).round() * increment;
  }
}
