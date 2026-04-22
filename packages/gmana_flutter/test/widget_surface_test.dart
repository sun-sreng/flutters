import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/form/buttons/elevated_button.dart';
import 'package:gmana_flutter/form/fields/email_field.dart';
import 'package:gmana_flutter/form/fields/password_field.dart';
import 'package:gmana_flutter/form/models/field_config.dart';
import 'package:gmana_flutter/form/widgets/configured_text_form_field.dart';
import 'package:gmana_flutter/spinner/g_circular_spinner.dart';
import 'package:gmana_flutter/spinner/g_linear_spinner.dart';
import 'package:gmana_flutter/spinner/g_spinner_wave_dot.dart';
import 'package:gmana_flutter/spinner/g_wave_spinner.dart';
import 'package:gmana_flutter/spinner/spinner_dot.dart';

void main() {
  group('form widgets', () {
    testWidgets('GConfiguredTextFormField wires config into TextFormField', (
      tester,
    ) async {
      final controller = TextEditingController();
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GConfiguredTextFormField(
              config: GFieldConfig(
                controller: controller,
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icons.email,
                onChanged: (value) => changedValue = value,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'user@example.com');

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller, same(controller));
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
      expect(changedValue, 'user@example.com');
    });

    testWidgets('GEmailField uses the default email validator', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: GEmailField(
                controller: controller,
                labelText: 'Email Address',
              ),
            ),
          ),
        ),
      );

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.validator?.call(null), 'Please enter an email address');
      expect(
        field.validator?.call('invalid-email'),
        'Please enter a valid email address',
      );
      expect(field.validator?.call('user@example.com'), isNull);
    });

    testWidgets('GPasswordField composes the obscurable field behavior', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GPasswordField(controller: controller)),
        ),
      );

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
    });
  });

  group('spinner widgets', () {
    testWidgets('canonical spinner widgets render', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                GCircularSpinner(),
                GLinearSpinner(),
                GSpinnerDot(color: Colors.red),
                GSpinnerWaveDot(size: 24, color: Colors.blue),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: GWaveSpinner(color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GCircularSpinner), findsOneWidget);
      expect(find.byType(GLinearSpinner), findsOneWidget);
      expect(find.byType(GSpinnerDot), findsOneWidget);
      expect(find.byType(GSpinnerWaveDot), findsOneWidget);
      expect(find.byType(GWaveSpinner), findsOneWidget);
    });

    testWidgets('GElevatedButton uses GSpinnerWaveDot while loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GElevatedButton(
              isLoading: true,
              onPressed: () {},
              text: 'Submit',
            ),
          ),
        ),
      );

      expect(find.byType(GSpinnerWaveDot), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });
  });
}
