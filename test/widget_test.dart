import 'package:flutter_test/flutter_test.dart';
import 'package:dose_gpt/main.dart';

void main() {
  testWidgets('App loads and shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(const DoseGptApp());

    // Should show the DoseGPT loading screen initially
    expect(find.text('DoseGPT'), findsOneWidget);
  });
}
