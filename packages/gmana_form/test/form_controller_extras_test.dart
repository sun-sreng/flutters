import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_form/gmana_form.dart';

GFormController newController() {
  final controller = GFormController();
  addTearDown(controller.dispose);
  return controller;
}

Widget hostForm(GFormController controller, List<Widget> children) {
  return MaterialApp(
    home: Scaffold(
      body: GForm(controller: controller, child: Column(children: children)),
    ),
  );
}

void main() {
  group('GFormController text mutation', () {
    test('setText replaces the value and parks the caret at the end', () {
      final controller = newController();
      controller.textController('email', text: 'old@x.com');

      controller.setText('email', 'new@example.com');

      expect(controller.text('email'), 'new@example.com');
      expect(
        controller.textController('email').selection.baseOffset,
        'new@example.com'.length,
      );
    });

    test('setText creates the field when it does not exist yet', () {
      final controller = newController();
      controller.setText('fresh', 'value');

      expect(controller.text('fresh'), 'value');
    });

    test('patchText applies several fields at once', () {
      final controller = newController();
      controller
        ..textController('first')
        ..textController('last')
        ..patchText({'first': 'Ada', 'last': 'Lovelace'});

      expect(controller.textValues(), {'first': 'Ada', 'last': 'Lovelace'});
    });

    test('clearText empties one field', () {
      final controller = newController();
      controller
        ..textController('note', text: 'draft')
        ..clearText('note');

      expect(controller.text('note'), isEmpty);
    });
  });

  group('GFormController errors', () {
    test('errorOf runs the bound validator without touching the UI', () {
      final controller = newController();
      controller
        ..textController('email')
        ..bindTextValidator('email', GValidators.required());

      expect(controller.errorOf('email'), 'This field is required');

      controller.setText('email', 'a@b.com');
      expect(controller.errorOf('email'), isNull);
    });

    test('errorOf returns null for an unknown field', () {
      expect(newController().errorOf('nope'), isNull);
    });

    test('errors collects every failing field', () {
      final controller = newController();
      controller
        ..textController('a')
        ..textController('b')
        ..textController('c')
        ..bindTextValidator('a', GValidators.required())
        ..bindTextValidator('b', GValidators.minLength(5))
        ..bindTextValidator('c', GValidators.required())
        ..setText('b', 'xy')
        ..setText('c', 'filled');

      expect(controller.errors(), {
        'a': 'This field is required',
        'b': 'Must be at least 5 characters',
      });
      expect(controller.hasErrors, isTrue);
    });

    test('hasErrors is false once everything passes', () {
      final controller = newController();
      controller
        ..textController('a')
        ..bindTextValidator('a', GValidators.required())
        ..setText('a', 'ok');

      expect(controller.hasErrors, isFalse);
      expect(controller.errors(), isEmpty);
    });

    test('passing null to bindTextValidator clears it', () {
      final controller = newController();
      controller
        ..textController('a')
        ..bindTextValidator('a', GValidators.required());
      expect(controller.hasErrors, isTrue);

      controller.bindTextValidator('a', null);
      expect(controller.hasErrors, isFalse);
    });
  });

  group('GFormController dirty tracking', () {
    test('a freshly bound field is pristine', () {
      final controller = newController();
      controller.textController('name', text: 'Ada');

      expect(controller.isDirty, isFalse);
      expect(controller.isFieldDirty('name'), isFalse);
      expect(controller.changedTextValues(), isEmpty);
    });

    test('editing marks the field and the form dirty', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..setText('name', 'Grace');

      expect(controller.isFieldDirty('name'), isTrue);
      expect(controller.isDirty, isTrue);
      expect(controller.changedTextValues(), {'name': 'Grace'});
    });

    test('returning to the original value clears the dirty flag', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..setText('name', 'Grace')
        ..setText('name', 'Ada');

      expect(controller.isDirty, isFalse);
    });

    test('markPristine rebaselines', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..setText('name', 'Grace');
      expect(controller.isDirty, isTrue);

      controller.markPristine();
      expect(controller.isDirty, isFalse);
      expect(controller.isFieldDirty('name'), isFalse);

      controller.setText('name', 'Alan');
      expect(controller.isDirty, isTrue);
    });

    test('only the changed fields are reported', () {
      final controller = newController();
      controller
        ..textController('a', text: '1')
        ..textController('b', text: '2')
        ..setText('b', '22');

      expect(controller.changedTextValues(), {'b': '22'});
    });
  });

  group('GFormController reset', () {
    test('restores non-text fields to their registered initial value', () {
      final controller = newController();
      controller.field<bool>('terms', initialValue: true);

      controller.setValue<bool>('terms', false);
      expect(controller.value<bool>('terms'), isFalse);

      controller.reset();
      expect(controller.value<bool>('terms'), isTrue);
    });

    test('a field registered without an initial value resets to null', () {
      final controller = newController();
      controller
        ..field<int>('count')
        ..setValue<int>('count', 5);

      controller.reset();
      expect(controller.value<int>('count'), isNull);
    });

    test('text fields still clear', () {
      final controller = newController();
      controller
        ..textController('name', text: 'Ada')
        ..reset();

      expect(controller.text('name'), isEmpty);
    });
  });

  group('GFormController focus', () {
    test('focusNode returns the same node for a name', () {
      final controller = newController();

      expect(controller.focusNode('a'), same(controller.focusNode('a')));
      expect(controller.focusNode('a'), isNot(same(controller.focusNode('b'))));
    });

    testWidgets('named text fields adopt the controller focus node', (
      tester,
    ) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GTextField.text(name: 'first'),
          GTextField.text(name: 'second'),
        ]),
      );

      controller.requestFocus('second');
      await tester.pump();

      expect(controller.focusNode('second').hasFocus, isTrue);
      expect(controller.focusNode('first').hasFocus, isFalse);
    });

    testWidgets('unfocus drops focus from every owned node', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [GTextField.text(name: 'only')]),
      );

      controller.requestFocus('only');
      await tester.pump();
      expect(controller.focusNode('only').hasFocus, isTrue);

      controller.unfocus();
      await tester.pump();
      expect(controller.focusNode('only').hasFocus, isFalse);
    });

    testWidgets('focusFirstInvalid lands on the first failing field', (
      tester,
    ) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GTextField.text(name: 'first', validator: (_) => null),
          GTextField.email(name: 'second'),
          GTextField.email(name: 'third'),
        ]),
      );

      // 'first' passes, 'second' and 'third' are empty emails.
      controller.setText('first', 'ok');
      await tester.pump();

      expect(controller.focusFirstInvalid(), isTrue);
      await tester.pump();
      expect(controller.focusNode('second').hasFocus, isTrue);
    });

    testWidgets('focusFirstInvalid returns false when the form is valid', (
      tester,
    ) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [GTextField.email(name: 'email')]),
      );

      controller.setText('email', 'a@b.com');
      await tester.pump();

      expect(controller.focusFirstInvalid(), isFalse);
    });
  });
}
