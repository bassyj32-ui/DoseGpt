import 'dart:convert';
import 'dart:io';

import 'package:dose_gpt/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> readDataFile(String name) =>
    jsonDecode(File('lib/data/$name').readAsStringSync())
        as Map<String, dynamic>;

/// Smoke tests for the entry screen and dataset wiring.
///
/// These read the real bundled data rather than a mocked loader, because the
/// failures worth catching here are asset-path and JSON-shape breaks, which
/// a mock would hide.
void main() {
  testWidgets('shows the loading state before data resolves', (tester) async {
    await tester.pumpWidget(const DoseGptApp());
    // The first frame must be the branded loading tile, not a blank screen
    // or a crash from reading assets before the bundle is ready.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('every illness in both datasets resolves to real drugs',
      (tester) async {
    final pediatric = readDataFile('illnesses.json');
    final pediatricDrugs = readDataFile('drugs.json');
    final adult = readDataFile('adult_illnesses.json');
    final adultDrugs = readDataFile('adult_drugs.json');

    final pDrugIds = (pediatricDrugs['drugs'] as List)
        .map((d) => (d as Map)['id'])
        .toSet();
    final aDrugIds = (adultDrugs['drugs'] as List)
        .map((d) => (d as Map)['id'])
        .toSet();

    for (final set in [
      [pediatric, pDrugIds],
      [adult, aDrugIds],
    ]) {
      final illnesses = (set[0] as Map)['illnesses'] as List;
      final known = set[1] as Set;
      for (final raw in illnesses) {
        final illness = raw as Map;
        final ids = (illness['drug_ids'] as List?) ?? const [];
        for (final id in ids) {
          expect(known, contains(id),
              reason: '${illness['id']} references unknown drug "$id"');
        }
      }
    }
  });

  test('meta.json still declares the dataset unverified', () {
    final meta = readDataFile('meta.json');
    expect(meta['reviewed_by'], isEmpty);
    expect(meta['dataset_status'], contains('UNVERIFIED'));
  });

  test('no drug entry asserts clinical sign-off', () {
    for (final file in ['drugs.json', 'adult_drugs.json']) {
      final data = readDataFile(file);
      for (final raw in data['drugs'] as List) {
        final drug = raw as Map;
        expect(drug['verified_by'] ?? '', isEmpty,
            reason: '${drug['id']} claims verified_by '
                '"${drug['verified_by']}" but the dataset is unsigned');
      }
    }
  });
}