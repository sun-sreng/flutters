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

Widget hostBare(Widget child) =>
    MaterialApp(home: Scaffold(body: Form(child: child)));

void main() {
  group('GCheckboxField', () {
    testWidgets('renders its title and starts from initialValue', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostBare(
          GCheckboxField(
            initialValue: true,
            title: const Text('I accept the terms'),
          ),
        ),
      );

      expect(find.text('I accept the terms'), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    });

    testWidgets('tapping toggles the value and fires onChanged', (
      tester,
    ) async {
      final changes = <bool>[];

      await tester.pumpWidget(
        hostBare(
          GCheckboxField(title: const Text('Accept'), onChanged: changes.add),
        ),
      );

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      expect(changes, [true]);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    });

    testWidgets('shows the validator message after validate', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GCheckboxField(
            title: const Text('Accept'),
            validator:
                (value) => value == true ? null : 'You must accept the terms',
          ),
        ]),
      );

      expect(find.text('You must accept the terms'), findsNothing);

      controller.validate();
      await tester.pump();

      expect(find.text('You must accept the terms'), findsOneWidget);
    });

    testWidgets('a named field reports into the controller values', (
      tester,
    ) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GCheckboxField(name: 'terms', title: const Text('Accept')),
        ]),
      );

      expect(controller.value<bool>('terms'), isFalse);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      expect(controller.value<bool>('terms'), isTrue);
      expect(controller.values().toMap(), containsPair('terms', true));
    });

    testWidgets('a named field seeds the controller with initialValue', (
      tester,
    ) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GCheckboxField(
            name: 'newsletter',
            initialValue: true,
            title: const Text('Subscribe'),
          ),
        ]),
      );

      expect(controller.value<bool>('newsletter'), isTrue);
    });

    testWidgets('disabled ignores taps', (tester) async {
      var changed = false;

      await tester.pumpWidget(
        hostBare(
          GCheckboxField(
            title: const Text('Accept'),
            enabled: false,
            onChanged: (_) => changed = true,
          ),
        ),
      );

      await tester.tap(find.byType(CheckboxListTile), warnIfMissed: false);
      await tester.pump();

      expect(changed, isFalse);
    });

    testWidgets('works standalone with no GForm above it', (tester) async {
      await tester.pumpWidget(
        hostBare(GCheckboxField(name: 'terms', title: const Text('Accept'))),
      );

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    });
  });

  group('GSwitchField', () {
    testWidgets('toggles and reports to a named controller', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GSwitchField(name: 'notifications', title: const Text('Notify me')),
        ]),
      );

      expect(controller.value<bool>('notifications'), isFalse);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      expect(controller.value<bool>('notifications'), isTrue);
    });

    testWidgets('shows its validator message', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GSwitchField(
            title: const Text('Enable'),
            validator: (value) => value == true ? null : 'Turn this on',
          ),
        ]),
      );

      controller.validate();
      await tester.pump();

      expect(find.text('Turn this on'), findsOneWidget);
    });
  });

  group('GDropdownField', () {
    List<DropdownMenuItem<String>> countryItems() => const [
      DropdownMenuItem(value: 'kh', child: Text('Cambodia')),
      DropdownMenuItem(value: 'us', child: Text('United States')),
    ];

    testWidgets('renders its label and hint', (tester) async {
      await tester.pumpWidget(
        hostBare(
          GDropdownField<String>(
            label: 'Country',
            hint: 'Pick one',
            items: countryItems(),
          ),
        ),
      );

      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Pick one'), findsWidgets);
    });

    testWidgets('shows the initial value', (tester) async {
      await tester.pumpWidget(
        hostBare(
          GDropdownField<String>(
            initialValue: 'us',
            label: 'Country',
            items: countryItems(),
          ),
        ),
      );

      expect(find.text('United States'), findsOneWidget);
    });

    testWidgets('selecting an item updates value and controller', (
      tester,
    ) async {
      final controller = newController();
      String? changed;

      await tester.pumpWidget(
        hostForm(controller, [
          GDropdownField<String>(
            name: 'country',
            label: 'Country',
            items: countryItems(),
            onChanged: (value) => changed = value,
          ),
        ]),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cambodia').last);
      await tester.pumpAndSettle();

      expect(changed, 'kh');
      expect(controller.value<String>('country'), 'kh');
    });

    testWidgets('shows the validator message after validate', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GDropdownField<String>(
            label: 'Country',
            items: countryItems(),
            validator: (value) => value == null ? 'Pick a country' : null,
          ),
        ]),
      );

      controller.validate();
      await tester.pump();

      expect(find.text('Pick a country'), findsOneWidget);
    });

    testWidgets('fromValues builds items from plain values', (tester) async {
      await tester.pumpWidget(
        hostBare(
          GDropdownField.fromValues<int>(
            initialValue: 2,
            values: const [1, 2, 3],
            labelBuilder: (value) => 'Level $value',
            label: 'Level',
          ),
        ),
      );

      expect(find.text('Level 2'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();

      expect(find.text('Level 1'), findsWidgets);
      expect(find.text('Level 3'), findsWidgets);
    });

    testWidgets('disabled does not open the menu', (tester) async {
      await tester.pumpWidget(
        hostBare(
          GDropdownField<String>(
            label: 'Country',
            enabled: false,
            items: countryItems(),
          ),
        ),
      );

      expect(
        tester
            .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
            .onChanged,
        isNull,
      );
    });
  });

  group('GDateField', () {
    final first = DateTime(2020);
    final last = DateTime(2030, 12, 31);

    testWidgets('renders the label and stays empty without a value', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostBare(
          GDateField(label: 'Start date', firstDate: first, lastDate: last),
        ),
      );

      expect(find.text('Start date'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('formats the initial value', (tester) async {
      await tester.pumpWidget(
        hostBare(
          GDateField(
            initialValue: DateTime(2024, 3, 5),
            firstDate: first,
            lastDate: last,
          ),
        ),
      );

      expect(find.text('2024-03-05'), findsOneWidget);
    });

    testWidgets('honours a custom formatter', (tester) async {
      await tester.pumpWidget(
        hostBare(
          GDateField(
            initialValue: DateTime(2024, 3, 5),
            firstDate: first,
            lastDate: last,
            format: (date) => '${date.day}/${date.month}/${date.year}',
          ),
        ),
      );

      expect(find.text('5/3/2024'), findsOneWidget);
    });

    testWidgets('opens the picker on tap', (tester) async {
      await tester.pumpWidget(
        hostBare(GDateField(firstDate: first, lastDate: last)),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
    });

    testWidgets('picking a date reports to a named controller', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GDateField(
            name: 'start',
            initialValue: DateTime(2024, 3, 5),
            firstDate: first,
            lastDate: last,
          ),
        ]),
      );

      expect(controller.value<DateTime>('start'), DateTime(2024, 3, 5));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(controller.value<DateTime>('start'), DateTime(2024, 3, 15));
      expect(find.text('2024-03-15'), findsOneWidget);
    });

    testWidgets('clearable resets the value to null', (tester) async {
      await tester.pumpWidget(
        hostBare(
          GDateField(
            initialValue: DateTime(2024, 3, 5),
            firstDate: first,
            lastDate: last,
            clearable: true,
          ),
        ),
      );

      expect(find.text('2024-03-05'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(find.text('2024-03-05'), findsNothing);
    });

    testWidgets('shows the validator message after validate', (tester) async {
      final controller = newController();

      await tester.pumpWidget(
        hostForm(controller, [
          GDateField(
            firstDate: first,
            lastDate: last,
            validator: (value) => value == null ? 'Pick a date' : null,
          ),
        ]),
      );

      controller.validate();
      await tester.pump();

      expect(find.text('Pick a date'), findsOneWidget);
    });

    testWidgets('disabled does not open the picker', (tester) async {
      await tester.pumpWidget(
        hostBare(GDateField(firstDate: first, lastDate: last, enabled: false)),
      );

      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
    });

    test('rejects an inverted date range', () {
      expect(
        () => GDateField(firstDate: DateTime(2030), lastDate: DateTime(2020)),
        throwsAssertionError,
      );
    });
  });

  group('formatIsoDate', () {
    test('zero-pads every component', () {
      expect(formatIsoDate(DateTime(2024, 3, 5)), '2024-03-05');
      expect(formatIsoDate(DateTime(2024, 12, 31)), '2024-12-31');
      expect(formatIsoDate(DateTime(999, 1, 2)), '0999-01-02');
    });
  });
}
