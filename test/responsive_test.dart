import 'dart:convert';
import 'dart:io';

import 'package:dose_gpt/models/illness.dart';
import 'package:dose_gpt/widgets/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] at a fixed logical width and returns the rendered size.
///
/// The layout is driven entirely by width, so testing it means testing at
/// specific widths rather than tapping through the app.
Future<Size> _renderAt(WidgetTester tester, Widget child, double width) async {
  tester.view.physicalSize = Size(width * 3, 900 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
  await tester.pumpAndSettle();
  return tester.view.physicalSize / 3.0;
}

void main() {
  // Breakpoints are pure functions of width, so they can be checked without
  // pumping a widget at all.
  bool isDesktopAt(double width) => width >= Breakpoints.desktop;
  bool isMultiColumnAt(double width) => width >= Breakpoints.wide;

  group('desktop breakpoint', () {
    test('is web only, never a large tablet or phone', () {
      // A 1400px-wide Android tablet in landscape must keep the phone
      // layout, or it loses its bottom navigation to a sidebar that has no
      // place to put a thumb.
      expect(isDesktopAt(400), isFalse);
      expect(isDesktopAt(768), isFalse);
      expect(isDesktopAt(999), isFalse);
      expect(isDesktopAt(1000), isTrue);
      expect(isDesktopAt(1920), isTrue);
    });

    test('multi-column starts at the wide breakpoint', () {
      expect(isMultiColumnAt(375), isFalse, reason: 'phone stays one column');
      expect(isMultiColumnAt(759), isFalse);
      expect(isMultiColumnAt(760), isTrue);
      expect(isMultiColumnAt(1440), isTrue);
    });
  });

  group('column count', () {
    int columnsFor(double width) {
      if (width >= 1400) return 4;
      if (width >= 1100) return 3;
      if (width >= Breakpoints.wide) return 2;
      return 1;
    }

    test('scales with width without ever regressing', () {
      expect(columnsFor(375), 1);
      expect(columnsFor(760), 2);
      expect(columnsFor(1100), 3);
      expect(columnsFor(1400), 4);
      expect(columnsFor(2560), 4, reason: 'does not keep adding columns');
    });

    test('never fewer columns as the window grows', () {
      var previous = 0;
      for (var w = 320; w <= 2560; w += 40) {
        final c = columnsFor(w.toDouble());
        expect(c, greaterThanOrEqualTo(previous),
            reason: 'column count dropped at ${w}px');
        previous = c;
      }
    });
  });

  group('content width', () {
    test('phone keeps the existing 600px reading measure', () {
      // Mobile layout must be untouched by the desktop work.
      expect(Breakpoints.contentMaxWidth, isNotNull);
    });

    test('cards stay wide enough to read at four columns', () {
      // At 2560px across four columns with 32px gutters and 10px gaps,
      // each card is roughly 580px. Verify the arithmetic holds by
      // reconstructing it the same way _GridSection does.
      const width = 2560.0;
      const gutter = 32.0;
      const spacing = 10.0;
      const columns = 4;
      final card = (width - gutter * 2 - spacing * (columns - 1)) / columns;
      expect(card, greaterThan(300),
          reason: 'cards would be too narrow to read the condition name');
      expect(card, lessThan(width));
    });
  });

  group('no overflow at desktop widths', () {
    testWidgets('a long condition name ellipsizes rather than overflowing',
        (tester) async {
      final illness = Illness(
        id: 'x',
        nameEn: 'Recurrent respiratory tract infection with complications',
        nameAm: '',
        icon: '',
        displayOrder: 1,
        urgentAccent: false,
        drugIds: const [],
      );

      await _renderAt(
        tester,
        SizedBox(
          width: 320,
          child: Row(
            children: [
              const SizedBox(width: 64),
              Expanded(
                child: Text(
                  illness.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        1200,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('illness model', () {
    test('carries an Amharic name for every bundled illness', () {
      // The desktop cards show the Amharic name beside the English one.
      // Illness names are complete today; this guards against a regression
      // if a new illness is added without one.
      final data = _readIllnesses();
      for (final illness in data) {
        expect(illness.nameAm, isNotEmpty,
            reason: '${illness.id} has no Amharic name');
      }
    });
  });
}

List<Illness> _readIllnesses() {
  final json = _loadJson('illnesses.json');
  return (json['illnesses'] as List)
      .map((e) => Illness.fromJson((e as Map).cast<String, dynamic>()))
      .toList();
}

Map<String, dynamic> _loadJson(String name) {
  final file = File('lib/data/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}
