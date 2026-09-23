import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('Gmana Flutter Umbrella Re-exports', () {
    testWidgets(
      'exports spinners, form fields, and presentation widgets together',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Presentation widget from gmana_flutter
                    const GTextField(label: 'Presentation TextField'),
                    // Form field from gmana_form
                    GTextFormField.text(label: 'Form TextFormField'),
                    GEmailField(label: 'Email Field'),
                    // Spinner from gmana_spinner
                    const GCircularSpinner(),
                    // Button using spinner
                    GButton(label: 'Submit', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Presentation TextField'), findsOneWidget);
        expect(find.text('Form TextFormField'), findsOneWidget);
        expect(find.text('Email Field'), findsOneWidget);
        expect(find.byType(GCircularSpinner), findsOneWidget);
        expect(find.byType(GButton), findsOneWidget);
      },
    );
  });
}
