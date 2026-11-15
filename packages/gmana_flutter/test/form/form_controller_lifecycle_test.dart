import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/form.dart';
import 'package:material_ui/material_ui.dart';

GFormController newController() {
  final controller = GFormController();
  addTearDown(controller.dispose);
  return controller;
}

String? required(String? value) =>
    value == null || value.isEmpty ? 'Required' : null;

void main() {
  group('validate agrees with errors', () {
    test('passes without a mounted form when every validator passes', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..bindTextValidator('name', required)
        ..field<int>('age', initialValue: 30, validator: (v, _) => null);

      expect(controller.errors(), isEmpty);
      expect(controller.validate(), isTrue);
    });

    test('runs bound text validators without a mounted form', () {
      final controller = newController();
      controller
        ..textController('name')
        ..bindTextValidator('name', required);

      expect(controller.errors(), {'name': 'Required'});
      expect(controller.validate(), isFalse);
    });

    test('runs typed validators without a mounted form', () {
      final controller = newController();
      controller.field<int>(
        'age',
        validator: (v, _) => v == null ? 'Enter an age' : null,
      );

      expect(controller.validate(), isFalse);
      expect(controller.field<int>('age').errorText, 'Enter an age');
    });

    testWidgets('fails for a bound validator whose widget is not mounted', (
      tester,
    ) async {
      final controller = newController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GForm(
              controller: controller,
              child: GTextFormField.text(name: 'name', initialValue: 'Ada'),
            ),
          ),
        ),
      );
      // A field from an earlier step stays registered after its widget goes.
      controller
        ..textController('company')
        ..bindTextValidator('company', required);

      expect(controller.hasErrors, isTrue);
      expect(controller.validate(), isFalse);
    });
  });

  group('unregister', () {
    test('forgets every trace of a text field', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..textController('company')
        ..bindTextValidator('company', required)
        ..setText('company', 'Acme');

      controller.unregister('company');

      expect(controller.errors(), isEmpty);
      expect(controller.textValues(), {'name': 'Ada'});
      expect(controller.values().toMap(), {'name': 'Ada'});
      expect(controller.isDirty, isFalse);
      expect(controller.validate(), isTrue);
    });

    test('forgets a typed field and its validator', () {
      final controller = newController();
      controller.field<bool>(
        'terms',
        initialValue: false,
        validator: (v, _) => v ?? false ? null : 'Accept the terms',
      );
      expect(controller.validate(), isFalse);

      controller.unregister('terms');

      expect(controller.values().toMap(), isEmpty);
      expect(controller.validate(), isTrue);
    });

    test('notifies listeners, and ignores an unknown name', () {
      final controller = newController()..textController('name');
      var notified = 0;
      controller.addListener(() => notified++);

      controller.unregister('missing');
      expect(notified, 0);

      controller.unregister('name');
      expect(notified, 1);
    });

    test('the name can be registered again afterwards', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..unregister('name');

      expect(controller.text('name'), isEmpty);
      expect(controller.textValues(), {'name': ''});
    });

    testWidgets('a conditional field removed from the tree stops counting', (
      tester,
    ) async {
      final controller = newController();
      var showCompany = true;
      late StateSetter setOuterState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setOuterState = setState;
                return GForm(
                  controller: controller,
                  child: Column(
                    children: [
                      GTextFormField.text(name: 'name', initialValue: 'Ada'),
                      if (showCompany)
                        GTextFormField.text(
                          name: 'company',
                          validator: required,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      expect(controller.validate(), isFalse);

      setOuterState(() => showCompany = false);
      await tester.pump();
      controller.unregister('company');

      expect(controller.errors(), isEmpty);
      expect(controller.textValues(), {'name': 'Ada'});
      expect(controller.validate(), isTrue);
    });
  });

  group('reset restores the pristine baseline', () {
    test('owned text goes back to its initial text', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..setText('name', 'Grace')
        ..reset();

      expect(controller.text('name'), 'Ada');
      expect(controller.isDirty, isFalse);
    });

    test('a bound external controller goes back too', () {
      final controller = newController();
      final external = TextEditingController(text: 'a');
      addTearDown(external.dispose);
      controller
        ..bindTextController('x', external)
        ..setText('x', 'b')
        ..reset();

      expect(external.text, 'a');
      expect(controller.value<String>('x'), 'a');
    });

    test('markPristine moves the baseline reset returns to', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..field<bool>('terms', initialValue: false)
        ..setText('name', 'Grace')
        ..setValue<bool>('terms', true)
        ..markPristine()
        ..setText('name', 'Alan')
        ..setValue<bool>('terms', false)
        ..reset();

      expect(controller.text('name'), 'Grace');
      expect(controller.value<bool>('terms'), isTrue);
      expect(controller.isDirty, isFalse);
    });

    test('clears typed field error text', () {
      final controller = newController();
      final age = controller.field<int>(
        'age',
        validator: (v, _) => v == null ? 'Enter an age' : null,
      );
      controller.validate();
      expect(age.errorText, 'Enter an age');

      controller.reset();
      expect(age.errorText, isNull);
    });

    testWidgets('a mounted text field shows its initial text again', (
      tester,
    ) async {
      final controller = newController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GForm(
              controller: controller,
              child: GTextFormField.text(name: 'name', initialValue: 'Ada'),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Grace');
      await tester.pump();
      expect(controller.isDirty, isTrue);

      controller.reset();
      await tester.pump();

      expect(find.text('Ada'), findsOneWidget);
      expect(controller.isDirty, isFalse);
    });
  });

  group('isDirty covers typed fields', () {
    test('a changed typed value makes the form dirty', () {
      final controller =
          newController()..field<bool>('terms', initialValue: false);
      expect(controller.isDirty, isFalse);

      controller.setValue<bool>('terms', true);
      expect(controller.isDirty, isTrue);
      expect(controller.isFieldDirty('terms'), isTrue);

      controller.setValue<bool>('terms', false);
      expect(controller.isDirty, isFalse);
    });

    test('markPristine rebaselines typed fields', () {
      final controller =
          newController()
            ..field<int>('count', initialValue: 1)
            ..setValue<int>('count', 2)
            ..markPristine();

      expect(controller.isDirty, isFalse);
      expect(controller.isFieldDirty('count'), isFalse);
    });
  });
}
