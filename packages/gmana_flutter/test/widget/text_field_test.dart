import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('GTextField Widget', () {
    testWidgets('enters text and triggers onChanged', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GTextField(
              label: 'Username',
              onChanged: (val) => changedValue = val,
            ),
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'john');
      expect(changedValue, equals('john'));
    });

    testWidgets(
      'renders clear button when enableClearButton is true and text entered',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: GTextField(enableClearButton: true)),
          ),
        );

        await tester.enterText(find.byType(TextField), 'hello');
        await tester.pump();

        expect(find.byIcon(Icons.clear), findsOneWidget);
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals(''));
      },
    );

    testWidgets('toggles visibility icon when enablePasswordToggle is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GTextField(enablePasswordToggle: true)),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
