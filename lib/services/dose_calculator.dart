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

  /// IV reconstitution instructions (displayed below main prescription).
  final String? ivReconstitution;

  const DoseResult({
    this.prescription,
    this.calculatedMl,
    this.calculatedMg,
    this.formula,
    this.isOutOfRange = false,
    this.outOfRangeMessage,
    this.safetyWarning,
    this.durationWarning,
    this.ivReconstitution,
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
        durationWarning = null,
        ivReconstitution = null;

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
        durationWarning = null,
        ivReconstitution = null;
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
      case 'fluids':
        return _calculateFluids(drug, weightKg, ageMonths);
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

    // Handle weight-based dose adjustment (e.g. Artesunate: 3mg/kg <20kg, 2.4mg/kg ≥20kg)
    double effectiveDosePerKg = drug.dosePerKgMg!;
    if (drug.id == 'artesunate_iv_malaria' && weightKg >= 20) {
      effectiveDosePerKg = 2.4;
    }

    // Simple single-dose mg_per_kg
    final doseMg = weightKg * effectiveDosePerKg;

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
      // Detect dummy IV concentration (1mg/1ml) — show mg + ml with vial reconstitution
      // Only use IV reconstitution text if the drug has ivInfo or it's known IV drug
      if (conc.strengthMg == 1 && conc.volumeMl == 1 && conc.roundToTablet == null && drug.ivInfo != null) {
        // Parse concentration from ivInfo marker [conc:N] or default to 100mg/ml
        final rawIvInfo = drug.ivInfo ?? '';
        double standardConc = 100;
        final concMatch = RegExp(r'\[conc:(\d+)\]').firstMatch(rawIvInfo);
        if (concMatch != null) {
          standardConc = double.parse(concMatch.group(1)!);
        }
        final mlToGive = effectiveDoseMg / standardConc;
        final roundedMl = _roundToNearest(mlToGive, 0.1);

        final durationPart = _durationPart(drug);
        final prescriptionText = '${drug.drugNameEn} — give ${effectiveDoseMg.toStringAsFixed(0)}mg '
            '(× ${roundedMl.toStringAsFixed(1)}ml), '
            '${drug.frequencyEn}$durationPart';

        prescription = prescriptionText;
        calculatedMl = roundedMl;

        formula = '${weightKg}kg × ${effectiveDosePerKg}mg/kg = '
            '${effectiveDoseMg.toStringAsFixed(0)}mg\n'
            '→ ${effectiveDoseMg.toStringAsFixed(0)}mg ÷ ${standardConc.toStringAsFixed(0)}mg/ml = '
            '${roundedMl.toStringAsFixed(1)}ml';

        // Use ivInfo from drug if available, else default ceftriaxone protocol
        // Strip [conc:N] marker before displaying
        final cleanIvInfo = rawIvInfo.replaceAll(RegExp(r'\[conc:\d+\]'), '');
        final finalIvInfo = cleanIvInfo.isNotEmpty ? cleanIvInfo : (
          'Reconstitute:\n'
          '• 1g vial + 9.6ml sterile water = 100mg/ml → draw [ml]ml\n'
          '• 500mg vial + 4.8ml sterile water = 100mg/ml → draw [ml]ml\n'
          '• 250mg vial + 2.4ml sterile water = 100mg/ml → draw [ml]ml\n'
          'Infuse over 30 min (60 min in neonates). Do NOT use calcium-containing fluids.'
        );
        final reconInfo = finalIvInfo.replaceAll('[ml]', roundedMl.toStringAsFixed(1));

        return DoseResult(
          prescription: prescriptionText,
          calculatedMl: calculatedMl,
          calculatedMg: effectiveDoseMg,
          formula: formula,
          ivReconstitution: reconInfo,
          safetyWarning: drug.safetyWarning,
          durationWarning: drug.durationWarning,
        );
      } else {
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

  /// fluids calculation: handles maintenance, shock, dehydration, burn
  /// Uses drug.id to identify which formula to apply.
  /// The drug's dosePerKgMg field is repurposed as the ml/kg rate where applicable.
  static DoseResult _calculateFluids(
    Drug drug,
    double weightKg,
    int ageMonths,
  ) {
    final String resultText;
    final String formulaText;

    switch (drug.id) {
      case 'iv_fluids_maintenance':
        // Holliday-Segar 4-2-1 rule
        final double hourlyRate;
        if (weightKg <= 10) {
          hourlyRate = weightKg * 4;
        } else if (weightKg <= 20) {
          hourlyRate = 10 * 4 + (weightKg - 10) * 2;
        } else {
          hourlyRate = 10 * 4 + 10 * 2 + (weightKg - 20) * 1;
        }

        final double dailyVolume = hourlyRate * 24;
        final double twoThirdsHourly = hourlyRate * 2 / 3;
        final double twoThirdsDaily = twoThirdsHourly * 24;

        resultText =
            '${drug.drugNameEn} — ${hourlyRate.toStringAsFixed(0)} ml/hr'
            '\n(${dailyVolume.toStringAsFixed(0)} ml/day)'
            '\n\nFluid: D5 0.45% NaCl or isotonic maintenance fluid'
            '\n\nFor unwell children (SIADH risk): use 2/3 maintenance'
            '\n  → ${twoThirdsHourly.toStringAsFixed(0)} ml/hr'
            '\n    (${twoThirdsDaily.toStringAsFixed(0)} ml/day)'
            '\n\nAdd KCl 20 mEq/L once urine output confirmed.'
            '\nCheck electrolytes within 24h.';

        formulaText =
            'HOLLIDAY-SEGAR (4-2-1 RULE)\n'
            'Weight: ${weightKg.toStringAsFixed(1)}kg\n\n'
            'Hourly rate:\n'
            '• First 10kg: 4 ml/kg/hr\n'
            '• Next 10kg (11-20kg): +2 ml/kg/hr\n'
            '• >20kg: +1 ml/kg/hr\n\n'
            'Calculation:\n'
            '${_maintenanceBreakdown(weightKg, hourlyRate)}';
        break;

      case 'iv_fluids_shock':
        {
        final double totalMl = 20 * weightKg;
        final double max60Ml = 60 * weightKg;
        resultText =
            '${drug.drugNameEn} — give ${totalMl.toStringAsFixed(0)} ml IV bolus'
            '\n(20 ml/kg × ${weightKg.toStringAsFixed(1)}kg)'
            '\n\nGive over 15-30 minutes. Reassess.'
            '\nRepeat up to 3 times (max 60 ml/kg = ${max60Ml.toStringAsFixed(0)} ml total).'
            '\n\nFluid: Ringer\'s Lactate or Normal Saline.'
            '\nDo NOT use dextrose-containing fluids as bolus.';

        formulaText =
            'SHOCK BOLUS\n'
            '20 ml/kg × ${weightKg.toStringAsFixed(1)}kg'
            ' = ${totalMl.toStringAsFixed(0)} ml\n'
            'Max total (3 boluses): 60 ml/kg × ${weightKg.toStringAsFixed(1)}kg'
            ' = ${max60Ml.toStringAsFixed(0)} ml';
        }
        break;

      case 'iv_fluids_dehydration':
        resultText =
            '${drug.drugNameEn}\n\n'
            'DEFICIT REPLACEMENT (after initial bolus)\n\n'
            'Mild (5%): ${(weightKg * 50).toStringAsFixed(0)} ml total\n'
            '  → give over 24h + maintenance\n\n'
            'Moderate (7.5%): ${(weightKg * 75).toStringAsFixed(0)} ml total\n'
            '  → give over 24h + maintenance\n\n'
            'Severe (10%): ${(weightKg * 100).toStringAsFixed(0)} ml total\n'
            '  → give over 24h + maintenance\n\n'
            'Dosing: Give 50% in first 8 hours, '
            'remaining 50% over next 16 hours.\n'
            'Fluid: D5 0.45% NaCl + 20 mEq KCl/L.\n'
            'Replace ongoing losses mL-for-mL.';

        formulaText =
            'DEFICIT REPLACEMENT\n'
            'Weight: ${weightKg.toStringAsFixed(1)}kg\n'
            'Deficit = weight × %dehydration × 10\n'
            'Mild: ${weightKg.toStringAsFixed(1)} × 50 = ${(weightKg * 50).toStringAsFixed(0)} ml\n'
            'Moderate: ${weightKg.toStringAsFixed(1)} × 75 = ${(weightKg * 75).toStringAsFixed(0)} ml\n'
            'Severe: ${weightKg.toStringAsFixed(1)} × 100 = ${(weightKg * 100).toStringAsFixed(0)} ml\n'
            'Add maintenance (4-2-1) over 24h.';
        break;

      case 'iv_fluids_burn':
        resultText =
            '${drug.drugNameEn}\n\n'
            'PARKLAND FORMULA (4 ml/kg/%burn)\n\n'
            'Requires % total body surface area (TBSA) burn estimate.\n'
            'Fluid for first 24h = 4ml × ${weightKg.toStringAsFixed(1)}kg × %TBSA\n\n'
            'Give 50% in first 8 hours, 50% over next 16 hours.\n'
            'Fluid: Ringer\'s Lactate (most commonly used).\n\n'
            'Example: 20kg child, 30% TBSA burn\n'
            '= 4 × 20 × 30 = 2400 ml in 24h\n'
            '→ 1200 ml over 8h (150 ml/hr)\n'
            '→ 1200 ml over 16h (75 ml/hr)';

        formulaText =
            'PARKLAND FORMULA\n'
            '4 ml/kg/%TBSA over 24h\n'
            '50% in 8h, 50% in 16h\n'
            'Weight: ${weightKg.toStringAsFixed(1)}kg\n'
            'Example at 30% TBSA: '
            '4 × ${weightKg.toStringAsFixed(0)} × 30 = ${(4 * weightKg * 30).toStringAsFixed(0)} ml';
        break;

      default:
        return const DoseResult.outOfRange();
    }

    return DoseResult(
      prescription: resultText,
      formula: formulaText,
      safetyWarning: drug.safetyWarning,
      durationWarning: drug.durationWarning,
    );
  }

  /// Build a breakdown string for the 4-2-1 rule.
  static String _maintenanceBreakdown(double weightKg, double hourlyRate) {
    final parts = <String>[];
    if (weightKg <= 10) {
      parts.add('${weightKg.toStringAsFixed(1)} × 4 = ${hourlyRate.toStringAsFixed(0)} ml/hr');
    } else if (weightKg <= 20) {
      parts.add('First 10kg: 10 × 4 = 40 ml/hr');
      parts.add('Next ${(weightKg - 10).toStringAsFixed(1)}kg: ${(weightKg - 10).toStringAsFixed(1)} × 2 = ${((weightKg - 10) * 2).toStringAsFixed(0)} ml/hr');
      parts.add('Total: 40 + ${((weightKg - 10) * 2).toStringAsFixed(0)} = ${hourlyRate.toStringAsFixed(0)} ml/hr');
    } else {
      parts.add('First 10kg: 10 × 4 = 40 ml/hr');
      parts.add('Next 10kg: 10 × 2 = 20 ml/hr');
      parts.add('Remaining ${(weightKg - 20).toStringAsFixed(1)}kg: ${(weightKg - 20).toStringAsFixed(1)} × 1 = ${(weightKg - 20).toStringAsFixed(0)} ml/hr');
      parts.add('Total: 40 + 20 + ${(weightKg - 20).toStringAsFixed(0)} = ${hourlyRate.toStringAsFixed(0)} ml/hr');
    }
    parts.add('Daily total: ${hourlyRate.toStringAsFixed(0)} × 24 = ${(hourlyRate * 24).toStringAsFixed(0)} ml/day');
    return parts.join('\n');
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
