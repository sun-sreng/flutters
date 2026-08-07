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
  group('GTextField.multiline', () {
    test('defaults to a growing multi-line box', () {
      final field = GTextField.multiline();

      expect(field.config.keyboardType, TextInputType.multiline);
      expect(field.config.textInputAction, TextInputAction.newline);
      expect(field.config.minLines, 3);
      expect(field.config.maxLines, 6);
      expect(field.config.textCapitalization, TextCapitalization.sentences);
      expect(field.config.label, 'Notes');
    });

    test('has no prefix icon unless one is asked for', () {
      expect(GTextField.multiline().config.prefixIcon, isNull);
      expect(
        GTextField.multiline(prefixIcon: Icons.notes).config.prefixIcon,
        Icons.notes,
      );
    });

    test('line bounds are configurable', () {
      final field = GTextField.multiline(minLines: 1, maxLines: 20);

      expect(field.config.minLines, 1);
      expect(field.config.maxLines, 20);
    });

    testWidgets('renders as a multi-line TextFormField', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [GTextField.multiline(name: 'bio')]),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, 6);
      expect(field.minLines, 3);
      expect(field.keyboardType, TextInputType.multiline);
    });

    testWidgets('accepts newlines and reports them to the controller', (
      tester,
    ) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [GTextField.multiline(name: 'bio')]),
      );

      await tester.enterText(find.byType(TextField), 'line one\nline two');

      expect(controller.text('bio'), 'line one\nline two');
    });

    testWidgets('a custom validator still runs', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GTextField.multiline(
            name: 'bio',
            validator: GValidators.minLength(10),
          ),
        ]),
      );

      controller.setText('bio', 'short');
      expect(controller.validate(), isFalse);
      await tester.pump();

      expect(find.text('Must be at least 10 characters'), findsOneWidget);
    });
  });

  group('GTextFieldConfig additions', () {
    test('defaults', () {
      const config = GTextFieldConfig();

      expect(config.autofocus, isFalse);
      expect(config.onTap, isNull);
      expect(config.onEditingComplete, isNull);
    });

    test('copyWith carries the new options', () {
      void noop() {}
      const base = GTextFieldConfig();

      final next = base.copyWith(
        autofocus: true,
        onTap: noop,
        onEditingComplete: noop,
      );

      expect(next.autofocus, isTrue);
      expect(next.onTap, same(noop));
      expect(next.onEditingComplete, same(noop));
    });

    testWidgets('onTap fires when the field is tapped', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: GTextField(
                config: GTextFieldConfig(
                  label: 'Pick something',
                  readOnly: true,
                  onTap: () => taps++,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('autofocus grabs focus on first build', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Form(
              child: GTextField(
                config: GTextFieldConfig(label: 'A', autofocus: true),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).autofocus,
        isTrue,
      );
    });
  });

  group('validators wired into named fields', () {
    testWidgets('the controller can report errors without validate()', (
      tester,
    ) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GTextField.text(
            name: 'nickname',
            validator: GValidators.minLength(3),
          ),
        ]),
      );

      controller.setText('nickname', 'ab');
      await tester.pump();

      // No error text painted yet, but the controller already knows.
      expect(find.text('Must be at least 3 characters'), findsNothing);
      expect(controller.errorOf('nickname'), isNotNull);

      controller.setText('nickname', 'abc');
      await tester.pump();
      expect(controller.errorOf('nickname'), isNull);
    });
  });
}
