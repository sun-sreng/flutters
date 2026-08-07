import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_form/gmana_form.dart';

void main() {
  testWidgets('GPinCodeField renders correct number of digit boxes and triggers onCompleted', (tester) async {
    String? completedPin;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GPinCodeField(
            length: 4,
            onCompleted: (pin) {
              completedPin = pin;
            },
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(4));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1');
    await tester.enterText(fields.at(1), '2');
    await tester.enterText(fields.at(2), '3');
    await tester.enterText(fields.at(3), '4');
    await tester.pump();

    expect(completedPin, equals('1234'));
  });
}
