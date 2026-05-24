import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_form/gmana_form.dart';
import 'package:gmana_validation/gmana_validation.dart';

void main() {
  group('form widgets', () {
    testWidgets('canonical form widgets render', (tester) async {
      final emailController = TextEditingController();
      final textController = TextEditingController();
      final numberController = TextEditingController();
      final passwordController = TextEditingController(text: 'password123');
      final confirmPasswordController = TextEditingController();

      addTearDown(emailController.dispose);
      addTearDown(textController.dispose);
      addTearDown(numberController.dispose);
      addTearDown(passwordController.dispose);
      addTearDown(confirmPasswordController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: Column(
                children: [
                  GEmailField(controller: emailController, label: 'Email'),
                  GTextField.text(controller: textController, label: 'Name'),
                  GNumberField(controller: numberController, label: 'Age'),
                  GPasswordField(controller: passwordController),
                  GConfirmPasswordField(
                    controller: confirmPasswordController,
                    passwordController: passwordController,
                  ),
                  GElevatedButton(
                    isLoading: false,
                    onPressed: () {},
                    text: 'Submit',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GEmailField), findsOneWidget);
      expect(find.byType(GTextField), findsNWidgets(5));
      expect(find.byType(GNumberField), findsOneWidget);
      expect(find.byType(GPasswordField), findsOneWidget);
      expect(find.byType(GConfirmPasswordField), findsOneWidget);
      expect(find.byType(GElevatedButton), findsOneWidget);
    });

    test('asFormValidator maps validation issues into form messages', () {
      final validator = asFormValidator(
        validate: const EmailValidator().validate,
        resolve: resolveEmailValidationIssue,
      );

      expect(validator(''), 'Please enter an email address');
      expect(validator('user@example.com'), isNull);
    });

    test('confirm password validator reports mismatches', () {
      final message = const ConfirmPasswordValidator()
          .validate(password: 'secret', confirmation: 'different')
          .fold(resolveConfirmPasswordValidationIssue, (_) => null);

      expect(message, 'Passwords do not match');
    });

    test('confirm password validator allows empty optional confirmation', () {
      final result = const ConfirmPasswordValidator(
        ConfirmPasswordValidationConfig(requireConfirmation: false),
      ).validate(password: 'secret', confirmation: '');

      expect(result.fold((_) => false, (_) => true), isTrue);
    });

    test('text field exposes low-level field configuration options', () {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      void onChanged(String value) {}
      void onSubmitted(String value) {}
      void onSaved(String? value) {}

      final field = GTextField.text(
        controller: controller,
        label: 'Notes',
        hint: 'Optional',
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        onSaved: onSaved,
        prefixIcon: Icons.notes,
        focusNode: focusNode,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        enabled: false,
        readOnly: true,
        minLines: 2,
        maxLines: 4,
        maxLength: 120,
        textCapitalization: TextCapitalization.sentences,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
        decoration: const InputDecoration(helperText: 'Help'),
      );

      expect(field.config.controller, same(controller));
      expect(field.config.label, 'Notes');
      expect(field.config.hint, 'Optional');
      expect(field.config.keyboardType, TextInputType.multiline);
      expect(field.config.textInputAction, TextInputAction.newline);
      expect(field.config.onChanged, same(onChanged));
      expect(field.config.onFieldSubmitted, same(onSubmitted));
      expect(field.config.onSaved, same(onSaved));
      expect(field.config.prefixIcon, Icons.notes);
      expect(field.config.focusNode, same(focusNode));
      expect(field.config.autovalidateMode, AutovalidateMode.onUserInteraction);
      expect(field.config.enabled, isFalse);
      expect(field.config.readOnly, isTrue);
      expect(field.config.minLines, 2);
      expect(field.config.maxLines, 4);
      expect(field.config.maxLength, 120);
      expect(field.config.textCapitalization, TextCapitalization.sentences);
      expect(field.config.textAlign, TextAlign.center);
      expect(field.config.style?.fontSize, 18);
      expect(field.config.decoration?.helperText, 'Help');
    });

    test('password field allows presentation overrides', () {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      final field = GPasswordField(
        controller: controller,
        prefixIcon: Icons.key,
        enabled: false,
        readOnly: true,
        maxLength: 64,
        textAlign: TextAlign.end,
        decoration: const InputDecoration(labelText: 'Secret'),
      );

      expect(field.config.prefixIcon, Icons.key);
      expect(field.config.enabled, isFalse);
      expect(field.config.readOnly, isTrue);
      expect(field.config.maxLength, 64);
      expect(field.config.textAlign, TextAlign.end);
      expect(field.config.decoration?.labelText, 'Secret');
    });

    test(
      'generic text field config supports initialValue without controller',
      () {
        const config = GTextFieldConfig(
          initialValue: 'Draft',
          label: 'Display name',
          prefixIcon: Icons.person,
        );

        expect(config.controller, isNull);
        expect(config.initialValue, 'Draft');
        expect(config.label, 'Display name');
      },
    );

    testWidgets('GFormController validates, saves, reads, and resets text', (
      tester,
    ) async {
      final controller = GFormController();
      addTearDown(controller.dispose);

      var savedValue = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GForm(
              controller: controller,
              child: Column(
                children: [
                  GTextField(
                    config: GTextFieldConfig(
                      controller: controller.textController('username'),
                      label: 'Username',
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                      onSaved: (value) => savedValue = value ?? '',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(controller.validateAndSave(), isFalse);

      await tester.enterText(find.byType(TextFormField), 'sreng');
      expect(controller.validateAndSave(), isTrue);
      expect(savedValue, 'sreng');
      expect(controller.text('username'), 'sreng');
      expect(controller.textValues(), {'username': 'sreng'});

      controller.reset();
      expect(controller.text('username'), isEmpty);
    });

    testWidgets('named fields resolve their controller from GForm', (
      tester,
    ) async {
      final controller = GFormController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GForm(
              controller: controller,
              child: GTextField.email(
                name: 'email',
                initialValue: 'draft@example.com',
              ),
            ),
          ),
        ),
      );

      expect(controller.text('email'), 'draft@example.com');

      await tester.enterText(find.byType(TextFormField), 'user@example.com');

      expect(controller.text('email'), 'user@example.com');
      expect(controller.textValues(), {'email': 'user@example.com'});
    });

    testWidgets('confirm password can validate against passwordName', (
      tester,
    ) async {
      final controller = GFormController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GForm(
              controller: controller,
              child: Column(
                children: [
                  GPasswordField(name: 'password'),
                  GConfirmPasswordField(
                    name: 'confirmPassword',
                    passwordName: 'password',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Password123!');
      await tester.enterText(find.byType(TextFormField).last, 'different');

      expect(controller.validate(), isFalse);
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets(
      'GFormController submit manages loading and prevents duplicates',
      (tester) async {
        final controller = GFormController();
        addTearDown(controller.dispose);

        var submitCount = 0;
        var completer = Completer<void>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GForm(
                controller: controller,
                child: Column(
                  children: [
                    const GTextField(
                      config: GTextFieldConfig(
                        name: 'username',
                        label: 'Username',
                      ),
                    ),
                    GFormSubmitButton.text(
                      label: 'Save',
                      onSubmit: (values) {
                        submitCount++;
                        expect(values, {'username': 'sreng'});
                        return Future<void>(
                          () {},
                        ).then((_) => Future<void>.delayed(Duration.zero));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'sreng');

        final firstSubmit = controller.submit((_) {
          submitCount++;
          return completer.future;
        });
        final duplicateSubmit = controller.submit((_) {
          submitCount++;
        });

        expect(controller.submitting, isTrue);
        expect(await duplicateSubmit, isFalse);
        completer.complete();
        expect(await firstSubmit, isTrue);
        expect(controller.submitting, isFalse);
        expect(submitCount, 1);

        completer = Completer<void>();
      },
    );

    testWidgets('GFormSubmitButton submits named form values', (tester) async {
      final controller = GFormController();
      addTearDown(controller.dispose);

      Map<String, String>? submittedValues;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GForm(
              controller: controller,
              child: Column(
                children: [
                  const GTextField(
                    config: GTextFieldConfig(
                      name: 'username',
                      label: 'Username',
                    ),
                  ),
                  GFormSubmitButton.text(
                    label: 'Save',
                    onSubmit: (values) {
                      submittedValues = values;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'sreng');
      await tester.tap(find.byType(GFormSubmitButton));
      await tester.pump();

      expect(submittedValues, {'username': 'sreng'});
    });
  });
}
