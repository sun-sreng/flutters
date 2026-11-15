import 'package:flutter_test/flutter_test.dart';
import 'package:gmana/validation.dart';
import 'package:gmana_flutter/form.dart';
import 'package:material_ui/material_ui.dart';

/// Pumps a number field and returns a function that types a text into it
/// (replacing the whole value, as a paste does) and reports what it shows.
Future<Future<String> Function(String text)> pumpNumberField(
  WidgetTester tester,
  NumberValidationConfig config,
) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GNumberField(controller: controller, validationConfig: config),
      ),
    ),
  );

  return (String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
    return controller.text;
  };
}

void main() {
  group('number input keeps the field when an edit is not a number', () {
    testWidgets('decimal with negatives', (tester) async {
      final type = await pumpNumberField(
        tester,
        const NumberValidationConfig(),
      );

      expect(await type('-1.2'), '-1.2');
      expect(await type('-1.2.'), '-1.2', reason: 'a second point');
      expect(await type('-1.2-'), '-1.2', reason: 'a second minus');
      expect(await type('1,234'), '-1.2', reason: 'a pasted comma');
      expect(await type('-'), '-', reason: 'a lone minus is a start');
      expect(await type(''), '', reason: 'clearing is allowed');
    });

    testWidgets('decimal without negatives', (tester) async {
      final type = await pumpNumberField(
        tester,
        const NumberValidationConfig(allowNegative: false),
      );

      expect(await type('3.5'), '3.5');
      expect(await type('-3.5'), '3.5');
      expect(await type('.'), '.');
    });

    testWidgets('integer with negatives', (tester) async {
      final type = await pumpNumberField(
        tester,
        const NumberValidationConfig(integerOnly: true),
      );

      expect(await type('-12'), '-12');
      expect(await type('-12-'), '-12');
      expect(await type('-1.2'), '-12');
    });

    testWidgets('integer without negatives', (tester) async {
      final type = await pumpNumberField(
        tester,
        const NumberValidationConfig(integerOnly: true, allowNegative: false),
      );

      expect(await type('42'), '42');
      expect(await type('4a2'), '42');
      expect(await type('-42'), '42');
    });
  });
}
