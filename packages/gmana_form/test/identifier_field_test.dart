import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_form/gmana_form.dart';

void main() {
  testWidgets('GIdentifierField renders label and accepts input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GIdentifierField(
            label: 'UUID Field',
          ),
        ),
      ),
    );

    expect(find.text('UUID Field'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'f47ac10b-58cc-4372-a567-0e02b2c3d479');
    await tester.pump();

    expect(find.text('f47ac10b-58cc-4372-a567-0e02b2c3d479'), findsOneWidget);
  });
}
