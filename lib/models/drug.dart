class Concentration {
  final String labelEn;
  final double? strengthMg;
  final double? volumeMl;
  final double roundToMl;
  final double? minSafeMl;
  final double? maxSafeMl;
  final double? roundToTablet;
  final List<PracticalBand>? practicalBandsDraft;

  Concentration({
    required this.labelEn,
    this.strengthMg,
    this.volumeMl,
    this.roundToMl = 0.5,
    this.minSafeMl,
    this.maxSafeMl,
    this.roundToTablet,
    this.practicalBandsDraft,
  });

  factory Concentration.fromJson(Map<String, dynamic> json) {
    return Concentration(
      labelEn: json['label_en'] as String? ?? '',
      strengthMg: (json['strength_mg'] as num?)?.toDouble(),
      volumeMl: (json['volume_ml'] as num?)?.toDouble(),
      roundToMl: (json['round_to_ml'] as num?)?.toDouble() ?? 0.5,
      minSafeMl: (json['min_safe_ml'] as num?)?.toDouble(),
      maxSafeMl: (json['max_safe_ml'] as num?)?.toDouble(),
      roundToTablet: (json['round_to_tablet'] as num?)?.toDouble(),
      practicalBandsDraft: (json['practical_bands_DRAFT'] as List?)
          ?.map((b) => PracticalBand.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PracticalBand {
  final double minKg;
  final double maxKg;
  final String doseDisplayEn;

  PracticalBand({
    required this.minKg,
    required this.maxKg,
    required this.doseDisplayEn,
  });

  factory PracticalBand.fromJson(Map<String, dynamic> json) {
    return PracticalBand(
      minKg: (json['min_kg'] as num).toDouble(),
      maxKg: (json['max_kg'] as num?)?.toDouble() ?? double.infinity,
      doseDisplayEn: json['dose_display_en'] as String? ?? '',
    );
  }
}

class WeightRange {
  final double? minKg;
  final double? maxKg;

  WeightRange({this.minKg, this.maxKg});

  factory WeightRange.fromJson(Map<String, dynamic> json) {
    return WeightRange(
      minKg: (json['min_kg'] as num?)?.toDouble(),
      maxKg: (json['max_kg'] as num?)?.toDouble(),
    );
  }
}

class AgeRange {
  final double? minMonths;
  final double? maxMonths;

  AgeRange({this.minMonths, this.maxMonths});

  factory AgeRange.fromJson(Map<String, dynamic> json) {
    return AgeRange(
      minMonths: (json['min_months'] as num?)?.toDouble(),
      maxMonths: (json['max_months'] as num?)?.toDouble(),
    );
  }
}

class WeightBand {
  final double minKg;
  final double maxKg;
  final String doseDisplayEn;

  WeightBand({
    required this.minKg,
    required this.maxKg,
    required this.doseDisplayEn,
  });

  /// Parses a weight band.
  ///
  /// Throws [FormatException] if given `min_months`/`max_months`. Weight and
  /// age bands share a JSON shape, so an age_band drug whose data was written
  /// with month keys must fail loudly here rather than being read as kilograms.
  factory WeightBand.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('min_months') || json.containsKey('max_months')) {
      throw const FormatException(
        'WeightBand received age keys (min_months/max_months). '
        'This drug must use dosing_shape "age_band" so the entry is read '
        'as an AgeBand, not a weight in kg.',
      );
    }
    return WeightBand(
      minKg: (json['min_kg'] as num?)?.toDouble() ?? 0,
      maxKg: (json['max_kg'] as num?)?.toDouble() ?? double.infinity,
      doseDisplayEn: json['dose_display_en'] as String? ?? '',
    );
  }
}

class AgeBand {
  final double minMonths;
  final double maxMonths;
  final String doseDisplayEn;

  AgeBand({
    required this.minMonths,
    required this.maxMonths,
    required this.doseDisplayEn,
  });

  factory AgeBand.fromJson(Map<String, dynamic> json) {
    return AgeBand(
      minMonths: (json['min_months'] as num?)?.toDouble() ?? 0,
      maxMonths: (json['max_months'] as num?)?.toDouble() ?? double.infinity,
      doseDisplayEn: json['dose_display_en'] as String? ?? '',
    );
  }
}

class DoseScheduleEntry {
  final dynamic day;
  final double dosePerKgMg;
  final double? maxDoseMg;

  DoseScheduleEntry({
    required this.day,
    required this.dosePerKgMg,
    this.maxDoseMg,
  });

  factory DoseScheduleEntry.fromJson(Map<String, dynamic> json) {
    return DoseScheduleEntry(
      day: json['day'],
      dosePerKgMg: (json['dose_per_kg_mg'] as num?)?.toDouble() ?? 0,
      maxDoseMg: (json['max_dose_mg'] as num?)?.toDouble(),
    );
  }
}

class Drug {
  final String id;
  final String illnessId;
  final String drugNameEn;
  final String drugNameAm;
  final List<String> drugSynonyms;
  final bool isRecommended;
  final bool combinationDrug;
  final String dosingShape;
  final String? notes;
  final double? dosePerKgMg;
  final List<DoseScheduleEntry>? doseSchedule;
  final String frequencyEn;
  final int? durationDays;
  final String? durationWarning;
  final String? durationNote;
  final double? maxDailyDoseMg;
  final double? maxDailyDosePerKgMg;
  final List<Concentration>? concentrations;
  final WeightRange? validWeightRange;
  final AgeRange? validAgeRange;
  final String? foodRequirement;
  final String? referralTriggerText;
  final List<WeightBand>? bands;

  /// Age bands for `age_band` drugs, parsed from `min_months`/`max_months`.
  ///
  /// Kept separate from [bands] so month values can never be compared
  /// against a weight. See `DoseCalculator._calculateAgeBand`.
  final List<AgeBand>? ageBands;

  final String? doseDisplayEn;
  final String? safetyWarning;
  final List<String>? penicillinAllergyAlternative;
  final String sourceName;
  final String? sourceDetail;
  final String? lastVerified;
  final String verifiedBy;
  final String? ivInfo;

  Drug({
    required this.id,
    required this.illnessId,
    required this.drugNameEn,
    this.drugNameAm = '',
    this.drugSynonyms = const [],
    required this.isRecommended,
    this.combinationDrug = false,
    required this.dosingShape,
    this.notes,
    this.dosePerKgMg,
    this.doseSchedule,
    required this.frequencyEn,
    this.durationDays,
    this.durationWarning,
    this.durationNote,
    this.maxDailyDoseMg,
    this.maxDailyDosePerKgMg,
    this.concentrations,
    this.validWeightRange,
    this.validAgeRange,
    this.foodRequirement,
    this.referralTriggerText,
    this.bands,
    this.ageBands,
    this.doseDisplayEn,
    this.safetyWarning,
    this.penicillinAllergyAlternative,
    required this.sourceName,
    this.sourceDetail,
    this.lastVerified,
    required this.verifiedBy,
    this.ivInfo,
  });

/// Parses `bands` as kilograms, but only for weight-banded drugs.
  ///
  /// Returns null for every other dosing shape so an age_band drug cannot
  /// have month values silently read as a weight, and so a weight_band drug
  /// with month keys fails loudly in [WeightBand.fromJson].
  static List<WeightBand>? _parseBands(
      Map<String, dynamic> json, String dosingShape) {
    if (dosingShape != 'weight_band') return null;
    return (json['bands'] as List?)
        ?.map((b) => WeightBand.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  /// Parses `bands` as months, but only for age-banded drugs.
  static List<AgeBand>? _parseAgeBands(
      Map<String, dynamic> json, String dosingShape) {
    if (dosingShape != 'age_band') return null;
    return (json['bands'] as List?)
        ?.map((b) => AgeBand.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  factory Drug.fromJson(Map<String, dynamic> json) {
    final dosingShape = json['dosing_shape'] as String? ?? '';
    return Drug(
      id: json['id'] as String? ?? '',
      illnessId: json['illness_id'] as String? ?? '',
      drugNameEn: json['drug_name_en'] as String? ?? '',
      drugNameAm: json['drug_name_am'] as String? ?? '',
      drugSynonyms: List<String>.from(json['drug_synonyms'] as List? ?? []),
      isRecommended: json['is_recommended'] as bool,
      combinationDrug: json['combination_drug'] as bool? ?? false,
      dosingShape: dosingShape,
      notes: json['notes'] as String?,
      dosePerKgMg: (json['dose_per_kg_mg'] as num?)?.toDouble(),
      doseSchedule: (json['dose_schedule'] as List?)
          ?.map((e) => DoseScheduleEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      frequencyEn: json['frequency_en'] as String? ?? '',
      durationDays: json['duration_days'] as int?,
      durationWarning: json['duration_warning'] as String?,
      durationNote: json['duration_note'] as String?,
      maxDailyDoseMg: (json['max_daily_dose_mg'] as num?)?.toDouble(),
      maxDailyDosePerKgMg:
          (json['max_daily_dose_per_kg_mg'] as num?)?.toDouble(),
      concentrations: (json['concentrations'] as List?)
          ?.map((c) => Concentration.fromJson(c as Map<String, dynamic>))
          .toList(),
      validWeightRange: json['valid_weight_range'] != null
          ? WeightRange.fromJson(json['valid_weight_range'] as Map<String, dynamic>)
          : null,
      validAgeRange: json['valid_age_range'] != null
          ? AgeRange.fromJson(json['valid_age_range'] as Map<String, dynamic>)
          : null,
      referralTriggerText: json['referral_trigger_text'] as String?,
      foodRequirement: json['food_requirement'] as String?,
      bands: _parseBands(json, dosingShape),
      ageBands: _parseAgeBands(json, dosingShape),
      doseDisplayEn: json['dose_display_en'] as String?,
      safetyWarning: json['safety_warning'] as String?,
      penicillinAllergyAlternative:
          (json['penicillin_allergy_alternative'] as List?)
              ?.map((e) => e as String)
              .toList(),
      sourceName: json['source_name'] as String? ?? '',
      sourceDetail: json['source_detail'] as String?,
      lastVerified: json['last_verified'] as String?,
      verifiedBy: json['verified_by'] as String? ?? '',
      ivInfo: json['iv_info'] as String?,
    );
  }
}
