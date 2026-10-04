import 'dart:convert';
import 'dart:io';

import 'package:dose_gpt/models/drug.dart';
import 'package:dose_gpt/services/dose_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real bundled dataset so tests exercise the data a clinician
/// actually sees, not hand-built fixtures that can drift from it.
Map<String, dynamic> _readData(String name) =>
    jsonDecode(File('lib/data/$name').readAsStringSync()) as Map<String, dynamic>;

List<Drug> _pediatricDrugs() => (_readData('drugs.json')['drugs'] as List)
    .map((d) => Drug.fromJson(d as Map<String, dynamic>))
    .toList();

List<Drug> _adultDrugs() => (_readData('adult_drugs.json')['drugs'] as List)
    .map((d) => Drug.fromJson(d as Map<String, dynamic>))
    .toList();

Drug _byId(List<Drug> drugs, String id) =>
    drugs.firstWhere((d) => d.id == id, orElse: () => fail('no drug "$id"'));

/// Holliday-Segar 4-2-1, independently recomputed rather than copied from
/// the implementation, so a change in one does not silently pass the other.
double _expectedMaintenance(double kg) {
  if (kg <= 10) return kg * 4;
  if (kg <= 20) return 40 + (kg - 10) * 2;
  return 60 + (kg - 20);
}

void main() {
  late List<Drug> pediatric;
  late List<Drug> adult;

  setUpAll(() {
    pediatric = _pediatricDrugs();
    adult = _adultDrugs();
  });

  // ── 4-2-1 maintenance (Holliday-Segar) ───────────────────────────────
  group('IV fluids: 4-2-1 maintenance', () {
    Drug fluids(String id) => _byId(pediatric, id);

    test('matches Holliday-Segar at every weight', () {
      const weights = [
        1.0, 2.5, 3.0, 5.0, 8.0, 9.9, 10.0, 10.1, 12.0, 15.0,
        19.9, 20.0, 20.1, 25.0, 30.0, 40.0, 55.0, 60.0, 75.0,
      ];
      for (final kg in weights) {
        final r = DoseCalculator.calculate(
          drug: fluids('iv_fluids_maintenance'),
          weightKg: kg,
          ageMonths: 24,
        );
        expect(r.isOutOfRange, isFalse,
            reason: '$kg kg must calculate, got: ${r.outOfRangeMessage}');
        final expected = _expectedMaintenance(kg);
        expect(r.prescription, contains('${expected.toStringAsFixed(0)} ml/hr'),
            reason: '4-2-1 mismatch at $kg kg');
      }
    });

    test('hits the documented breakpoints exactly', () {
      // 10 kg = 40 ml/hr, 20 kg = 60 ml/hr — the points where the
      // per-kilogram multiplier steps down.
      expect(
        DoseCalculator.calculate(
          drug: fluids('iv_fluids_maintenance'),
          weightKg: 10,
          ageMonths: 24,
        ).prescription,
        contains('40 ml/hr'),
      );
      expect(
        DoseCalculator.calculate(
          drug: fluids('iv_fluids_maintenance'),
          weightKg: 20,
          ageMonths: 24,
        ).prescription,
        contains('60 ml/hr'),
      );
    });

    test('offers 2/3 maintenance for SIADH risk', () {
      final r = DoseCalculator.calculate(
        drug: fluids('iv_fluids_maintenance'),
        weightKg: 10,
        ageMonths: 24,
      );
      expect(r.prescription, contains('2/3 maintenance'));
      // 40 ml/hr * 2/3 = 26.67 -> displayed as 27 ml/hr
      expect(r.prescription, contains('27 ml/hr'));
    });
  });

  // ── Shock bolus ───────────────────────────────────────────────────────
  group('IV fluids: shock bolus', () {
    test('is 20 ml/kg with a 60 ml/kg ceiling', () {
      for (final kg in [3.0, 7.5, 12.0, 20.0]) {
        final r = DoseCalculator.calculate(
          drug: _byId(pediatric, 'iv_fluids_shock'),
          weightKg: kg,
          ageMonths: 24,
        );
        expect(r.isOutOfRange, isFalse);
        expect(r.prescription, contains('${(20 * kg).toStringAsFixed(0)} ml IV bolus'),
            reason: 'bolus volume wrong at $kg kg');
        expect(r.prescription, contains('${(60 * kg).toStringAsFixed(0)} ml total'),
            reason: 'max cumulative volume wrong at $kg kg');
      }
    });

    test('forbids dextrose-containing fluid for the bolus', () {
      final r = DoseCalculator.calculate(
        drug: _byId(pediatric, 'iv_fluids_shock'),
        weightKg: 10,
        ageMonths: 24,
      );
      expect(r.prescription, contains('Do NOT use dextrose'));
    });
  });

  // ── Dehydration deficit ───────────────────────────────────────────────
  group('IV fluids: dehydration deficit', () {
    test('scales deficit as weight x %dehydration x 10', () {
      final cases = <double, Map<String, int>>{
        10.0: {'Mild': 500, 'Moderate': 750, 'Severe': 1000},
        20.0: {'Mild': 1000, 'Moderate': 1500, 'Severe': 2000},
      };
      cases.forEach((kg, expect_) {
        final r = DoseCalculator.calculate(
          drug: _byId(pediatric, 'iv_fluids_dehydration'),
          weightKg: kg,
          ageMonths: 24,
        );
        expect(r.isOutOfRange, isFalse);
        expect_.forEach((label, ml) {
          expect(r.prescription, contains('$ml ml total'),
              reason: '$label deficit wrong at $kg kg (expected $ml ml)');
          expect(r.formula, contains('= $ml ml'.replaceAll(' ', ' ')),
              reason: '$label deficit arithmetic wrong at $kg kg');
        });
      });
    });

    test('splits replacement 50% / 8h and 50% / 16h', () {
      final r = DoseCalculator.calculate(
        drug: _byId(pediatric, 'iv_fluids_dehydration'),
        weightKg: 10,
        ageMonths: 24,
      );
      expect(r.prescription, contains('50% in first 8 hours'));
      expect(r.prescription, contains('next 16 hours'));
    });
  });

  // ── Parkland burns ────────────────────────────────────────────────────
  group('IV fluids: Parkland burns', () {
    test('computes 4 ml/kg/%TBSA', () {
      for (final kg in [5.0, 10.0, 20.0, 30.0]) {
        final r = DoseCalculator.calculate(
          drug: _byId(pediatric, 'iv_fluids_burn'),
          weightKg: kg,
          ageMonths: 24,
        );
        expect(r.isOutOfRange, isFalse);
        final expected = (4 * kg * 30).toStringAsFixed(0);
        expect(r.formula, contains('= $expected ml'),
            reason: 'Parkland 30% TBSA wrong at $kg kg');
      }
    });

    test('splits 50% over 8h then 50% over 16h', () {
      final r = DoseCalculator.calculate(
        drug: _byId(pediatric, 'iv_fluids_burn'),
        weightKg: 20,
        ageMonths: 24,
      );
      expect(r.prescription, contains('50% in first 8 hours, 50% over next 16 hours'));
    });

    test('requires a TBSA estimate from the clinician', () {
      // The app cannot compute a burn volume without %TBSA, so it must not
      // present a number as if the burn size were known.
      final r = DoseCalculator.calculate(
        drug: _byId(pediatric, 'iv_fluids_burn'),
        weightKg: 20,
        ageMonths: 24,
      );
      expect(r.prescription, contains('Requires % total body surface area'));
    });
  });

  // ── Age handling ──────────────────────────────────────────────────────
  group('age handling', () {
    test('an age of 0 is treated as missing, not as a neonatal age', () {
      // Whole-month entry cannot distinguish a neonate from an empty field,
      // so 0 means "no age given" and must never reach a calculation.
      expect(DoseCalculator.isAgeMissing(0), isTrue);
      expect(DoseCalculator.isAgeMissing(1), isFalse);
      expect(DoseCalculator.isAgeMissing(24), isFalse);
    });

    test('a real age is never reported as missing', () {
      for (var months = 1; months <= 240; months++) {
        expect(DoseCalculator.isAgeMissing(months), isFalse);
      }
    });
  });

  // ── age_band lookup ───────────────────────────────────────────────────
  group('age_band drugs', () {
    test('vitamin A covers every month in its valid range', () {
      final drug = _byId(pediatric, 'vitamin_a_measles');
      final maxAge = drug.validAgeRange!.maxMonths!;
      // Regression: the band table previously stopped at 10 months while the
      // drug accepted up to 60, so most children were told to "refer".
      for (var m = 1; m <= maxAge.toInt(); m++) {
        final r = DoseCalculator.calculate(
          drug: drug,
          weightKg: 8,
          ageMonths: m,
        );
        expect(r.isOutOfRange, isFalse,
            reason: '$m months fell through every vitamin A band');
      }
    });

    test('vitamin A steps up at 6 and 12 months', () {
      final drug = _byId(pediatric, 'vitamin_a_measles');
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 8, ageMonths: 3)
            .prescription,
        contains('50,000 IU'),
      );
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 8, ageMonths: 9)
            .prescription,
        contains('100,000 IU'),
      );
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 8, ageMonths: 24)
            .prescription,
        contains('200,000 IU'),
      );
    });

    test('age bands are read as months, weight bands as kilograms', () {
      // An age_band drug must expose months and never kilograms. Salbutamol
      // is the discriminator: its bands start at 0 months and run to 18,
      // which as kilograms would make no sense for a paediatric inhaler.
      final salbutamol = _byId(pediatric, 'salbutamol_asthma');
      expect(salbutamol.bands, isNull,
          reason: 'age_band drug must not expose weight bands');
      expect(salbutamol.ageBands, isNotEmpty);
      expect(salbutamol.ageBands!.last.maxMonths,
          greaterThan(salbutamol.ageBands!.last.minMonths));

      final coartem = _byId(pediatric, 'al_malaria');
      expect(coartem.ageBands, isNull,
          reason: 'weight_band drug must not expose age bands');
      expect(coartem.bands, isNotEmpty);
      expect(coartem.bands!.first.maxKg, greaterThan(1));
    });

    test('salbutamol routes a 5-month-old and a 5-year-old differently', () {
      final drug = _byId(pediatric, 'salbutamol_asthma');
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 8, ageMonths: 5)
            .prescription,
        contains('via spacer + mask'),
      );
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 22, ageMonths: 60)
            .prescription,
        contains('6-8 puffs'),
      );
    });

    test('albendazole splits at 12 months', () {
      final drug = _byId(pediatric, 'albendazole_worms');
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 8, ageMonths: 6)
            .prescription,
        contains('200mg'),
      );
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 25, ageMonths: 36)
            .prescription,
        contains('400mg'),
      );
    });
  });

  // ── weight_band lookup ────────────────────────────────────────────────
  group('weight_band drugs', () {
    test('Coartem matches WHO weight bands', () {
      final drug = _byId(pediatric, 'al_malaria');
      final cases = <double, String>{
        6.0: '1 tablet',
        12.0: '1 tablet',
        18.0: '2 tablet',
        30.0: '3 tablet',
        50.0: '4 tablet',
      };
      cases.forEach((kg, tablets) {
        final r = DoseCalculator.calculate(
          drug: drug,
          weightKg: kg,
          ageMonths: 36,
        );
        expect(r.isOutOfRange, isFalse, reason: '$kg kg out of range');
        expect(r.prescription, contains(tablets),
            reason: '$kg kg should get $tablets');
      });
    });

    test('weight bands leave no unmatchable weight between them', () {
      // Bands use inclusive bounds, so 14 then 15 leaves 14.5 kg with no
      // band at all. That is a real hole: the app would refer a patient who
      // sits squarely inside the drug's weight range.
      for (final drug in pediatric.where((d) => d.dosingShape == 'weight_band')) {
        final bands = drug.bands!;
        for (var i = 1; i < bands.length; i++) {
          final previousMax = bands[i - 1].maxKg;
          final nextMin = bands[i].minKg;
          if (previousMax == double.infinity) continue;
          // Inclusive bounds mean the next band must start at or below the
          // previous band's end, or the weights in between match nothing.
          expect(nextMin, lessThanOrEqualTo(previousMax + 0.001),
              reason: '${drug.id}: ${previousMax + 0.001}-$nextMin kg '
                  'matches no band');
        }
      }
    });

    test('weight below the first band refers rather than guessing', () {
      final drug = _byId(pediatric, 'al_malaria');
      final r = DoseCalculator.calculate(
        drug: drug,
        weightKg: 3,
        ageMonths: 36,
      );
      expect(r.isOutOfRange, isTrue);
      expect(r.prescription, isNull);
    });
  });

  // ── mg_per_kg and clamping ────────────────────────────────────────────
  group('mg_per_kg with concentration', () {
    test('converts mg to ml using the syrup strength', () {
      // Amoxicillin 40 mg/kg at 10 kg = 400 mg.
      // Against the 250mg/5ml syrup that is 400 / 250 x 5 = 8.0 ml.
      final drug = pediatric
          .firstWhere((d) => d.id == 'amoxicillin_pneumonia');
      final r = DoseCalculator.calculate(
        drug: drug,
        weightKg: 10,
        ageMonths: 24,
        concentrationIndex: 1,
      );
      expect(r.isOutOfRange, isFalse);
      expect(r.calculatedMg, closeTo(400, 0.01));
      expect(r.calculatedMl, closeTo(8.0, 0.01));
    });

    test('clamps to max_safe_ml instead of exceeding it', () {
      final drug = pediatric
          .firstWhere((d) => d.id == 'amoxicillin_pneumonia');
      for (final conc in drug.concentrations!) {
        final max = conc.maxSafeMl;
        if (max == null) continue;
        // Heaviest allowed patient should never exceed the ceiling.
        final r = DoseCalculator.calculate(
          drug: drug,
          weightKg: 40,
          ageMonths: 120,
          concentrationIndex: drug.concentrations!.indexOf(conc),
        );
        expect(r.calculatedMl, lessThanOrEqualTo(max + 0.001),
            reason: 'exceeded max_safe_ml $max for ${conc.labelEn}');
      }
    });

    test('never exceeds an absolute max daily dose', () {
      for (final drug in pediatric.where((d) =>
          d.dosingShape == 'mg_per_kg' &&
          d.maxDailyDoseMg != null &&
          d.dosePerKgMg != null)) {
        final r = DoseCalculator.calculate(
          drug: drug,
          weightKg: 60,
          ageMonths: 120,
        );
        if (r.isOutOfRange) continue;
        expect(r.calculatedMg, lessThanOrEqualTo(drug.maxDailyDoseMg! + 0.001),
            reason: '${drug.id} exceeded maxDailyDoseMg');
      }
    });

    test('artesunate steps down to 2.4 mg/kg at 20 kg', () {
      // WHO: 3 mg/kg below 20 kg, 2.4 mg/kg at or above it.
      final drug = _byId(pediatric, 'artesunate_iv_malaria');
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 10, ageMonths: 24)
            .calculatedMg,
        closeTo(30, 0.01),
      );
      expect(
        DoseCalculator.calculate(drug: drug, weightKg: 25, ageMonths: 60)
            .calculatedMg,
        closeTo(60, 0.01),
      );
    });
  });

  // ── Referential safety: never guess ───────────────────────────────────
  group('out-of-range handling', () {
    test('an unknown dosing shape refers rather than dosing', () {
      final drug = Drug.fromJson({
        'id': 'bogus',
        'illness_id': 'x',
        'drug_name_en': 'Bogus',
        'is_recommended': false,
        'dosing_shape': 'something_new',
        'frequency_en': 'once',
      });
      final r = DoseCalculator.calculate(
        drug: drug,
        weightKg: 20,
        ageMonths: 60,
      );
      expect(r.isOutOfRange, isTrue);
      expect(r.prescription, isNull);
      expect(r.calculatedMg, isNull);
    });

    test('out-of-range results always carry a message', () {
      for (final drug in pediatric) {
        final r = DoseCalculator.calculate(
          drug: drug,
          weightKg: 999,
          ageMonths: 240,
        );
        if (!r.isOutOfRange) continue;
        expect(r.outOfRangeMessage, isNotNull,
            reason: '${drug.id} referred with no explanation');
        expect(r.outOfRangeMessage!.trim(), isNotEmpty);
      }
    });

    test('calculate never throws for any bundled drug at any of these ages', () {
      const ages = [1, 3, 6, 12, 24, 60, 120, 240];
      const weights = [1.0, 3.0, 5.0, 10.0, 20.0, 30.0, 50.0, 80.0];
      for (final drug in [...pediatric, ...adult]) {
        for (final age in ages) {
          for (final kg in weights) {
            expect(
              () => DoseCalculator.calculate(
                drug: drug,
                weightKg: kg,
                ageMonths: age,
              ),
              returnsNormally,
              reason: '${drug.id} threw at $kg kg / $age months',
            );
          }
        }
      }
    });
  });

  // ── Dataset integrity ─────────────────────────────────────────────────
  group('dataset integrity', () {
    test('every age_band drug declares an age range', () {
      for (final drug in pediatric.where((d) => d.dosingShape == 'age_band')) {
        expect(drug.validAgeRange, isNotNull,
            reason: '${drug.id} is age_band with no valid_age_range');
      }
    });

    test('every weight_band drug declares a weight range', () {
      for (final drug in pediatric.where((d) => d.dosingShape == 'weight_band')) {
        expect(drug.validWeightRange, isNotNull,
            reason: '${drug.id} is weight_band with no valid_weight_range');
      }
    });

    test('the open band of an age_band drug covers its declared max age', () {
      for (final drug in pediatric.where((d) => d.dosingShape == 'age_band')) {
        final maxAge = drug.validAgeRange?.maxMonths;
        if (maxAge == null) continue;
        final r = DoseCalculator.calculate(
          drug: drug,
          weightKg: 10,
          ageMonths: maxAge.toInt(),
        );
        expect(r.isOutOfRange, isFalse,
            reason: '${drug.id} refers at its own maximum valid age');
      }
    });

    test('no drug entry claims clinical sign-off', () {
      // reviewed_by is empty dataset-wide, so no entry may assert otherwise.
      final meta = _readData('meta.json');
      expect(meta['reviewed_by'], isEmpty,
          reason: 'reviewed_by changed — re-verify the whole dataset first');
      expect(meta['dataset_status'], contains('UNVERIFIED'));
    });

    test('WeightBand rejects age keys loudly', () {
      expect(
        () => WeightBand.fromJson({
          'min_months': 6,
          'max_months': 11,
          'dose_display_en': 'x',
        }),
        throwsFormatException,
      );
    });
  });
}