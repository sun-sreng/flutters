import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_spinner/gmana_spinner.dart';

Widget host(Widget child, {GSpinnerTheme? spinnerTheme}) => MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
    extensions: spinnerTheme == null ? const [] : [spinnerTheme],
  ),
  home: Scaffold(body: child),
);

/// The color a [CircularProgressIndicator] is actually painting with.
Color? indicatorColor(WidgetTester tester) {
  final indicator = tester.widget<CircularProgressIndicator>(
    find.byType(CircularProgressIndicator),
  );
  return indicator.valueColor!.value;
}

/// The fill color of the first dot a [GDotSpinner] paints.
Color? dotColor(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(GDotSpinner),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return (box.decoration as BoxDecoration).color;
}

void main() {
  group('GSpinnerTheme value semantics', () {
    test('equal field sets compare equal and hash alike', () {
      const a = GSpinnerTheme(color: Color(0xFF00FF00), semanticsLabel: 'L');
      const b = GSpinnerTheme(color: Color(0xFF00FF00), semanticsLabel: 'L');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differing fields compare unequal', () {
      const base = GSpinnerTheme(color: Color(0xFF00FF00));

      expect(base, isNot(const GSpinnerTheme(color: Color(0xFFFF0000))));
      expect(base, isNot(const GSpinnerTheme()));
    });

    test('copyWith replaces only what is passed', () {
      const original = GSpinnerTheme(
        color: Color(0xFF00FF00),
        secondaryColor: Color(0xFF0000FF),
        semanticsLabel: 'Loading',
      );

      final changed = original.copyWith(semanticsLabel: 'Saving');

      expect(changed.semanticsLabel, 'Saving');
      expect(changed.color, const Color(0xFF00FF00));
      expect(changed.secondaryColor, const Color(0xFF0000FF));
    });

    test('toString names every field', () {
      const theme = GSpinnerTheme(
        color: Color(0xFF00FF00),
        semanticsLabel: 'Loading',
      );

      expect(theme.toString(), contains('semanticsLabel: Loading'));
      expect(theme.toString(), contains('color:'));
    });
  });

  group('GSpinnerTheme.lerp', () {
    test('interpolates both colors', () {
      const from = GSpinnerTheme(
        color: Color(0xFF000000),
        secondaryColor: Color(0xFF000000),
      );
      const to = GSpinnerTheme(
        color: Color(0xFFFFFFFF),
        secondaryColor: Color(0xFFFFFFFF),
      );

      final mid = from.lerp(to, 0.5);

      expect(mid.color, Color.lerp(from.color, to.color, 0.5));
      expect(
        mid.secondaryColor,
        Color.lerp(from.secondaryColor, to.secondaryColor, 0.5),
      );
    });

    test('returns this when the other side is null', () {
      const from = GSpinnerTheme(color: Color(0xFF000000));

      expect(from.lerp(null, 0.5), same(from));
    });

    test('switches the label at the midpoint rather than interpolating', () {
      const from = GSpinnerTheme(semanticsLabel: 'a');
      const to = GSpinnerTheme(semanticsLabel: 'b');

      expect(from.lerp(to, 0.2).semanticsLabel, 'a');
      expect(from.lerp(to, 0.8).semanticsLabel, 'b');
    });

    test('handles a null color on one side without throwing', () {
      const from = GSpinnerTheme();
      const to = GSpinnerTheme(color: Color(0xFFFFFFFF));

      expect(from.lerp(to, 0.5).color, Color.lerp(null, to.color, 0.5));
    });
  });

  group('GSpinnerTheme lookup', () {
    testWidgets('maybeOf is null when no extension is installed', (
      tester,
    ) async {
      GSpinnerTheme? found;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              found = GSpinnerTheme.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(found, isNull);
    });

    testWidgets('of falls back to an empty theme', (tester) async {
      late GSpinnerTheme found;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              found = GSpinnerTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(found, const GSpinnerTheme());
      expect(found.color, isNull);
    });

    testWidgets('maybeOf finds an installed extension', (tester) async {
      GSpinnerTheme? found;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              found = GSpinnerTheme.maybeOf(context);
              return const SizedBox();
            },
          ),
          spinnerTheme: const GSpinnerTheme(secondaryColor: Color(0xFF123456)),
        ),
      );

      expect(found?.secondaryColor, const Color(0xFF123456));
    });
  });

  group('color resolution order', () {
    testWidgets('an explicit color wins over the theme', (tester) async {
      await tester.pumpWidget(
        host(
          const GCircularSpinner(color: Color(0xFFFF0000)),
          spinnerTheme: const GSpinnerTheme(color: Color(0xFF00FF00)),
        ),
      );

      expect(indicatorColor(tester), const Color(0xFFFF0000));
    });

    testWidgets('the theme wins over the widget default', (tester) async {
      await tester.pumpWidget(
        host(
          const GCircularSpinner(),
          spinnerTheme: const GSpinnerTheme(color: Color(0xFF00FF00)),
        ),
      );

      expect(indicatorColor(tester), const Color(0xFF00FF00));
    });

    testWidgets('GCircularSpinner keeps its legacy purple with no theme', (
      tester,
    ) async {
      await tester.pumpWidget(host(const GCircularSpinner()));

      expect(indicatorColor(tester), Colors.purple);
    });

    testWidgets('GLinearSpinner keeps its legacy purple with no theme', (
      tester,
    ) async {
      await tester.pumpWidget(host(const GLinearSpinner()));

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(indicator.valueColor!.value, Colors.purple);
    });

    testWidgets('GLinearSpinner follows the theme when one is installed', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const GLinearSpinner(),
          spinnerTheme: const GSpinnerTheme(color: Color(0xFF00FF00)),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(indicator.valueColor!.value, const Color(0xFF00FF00));
    });

    testWidgets('an animated spinner falls back to ColorScheme.primary', (
      tester,
    ) async {
      late Color primary;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              primary = Theme.of(context).colorScheme.primary;
              return const GDotSpinner();
            },
          ),
        ),
      );

      expect(dotColor(tester), primary);
    });

    testWidgets('an animated spinner follows the theme', (tester) async {
      await tester.pumpWidget(
        host(
          const GDotSpinner(),
          spinnerTheme: const GSpinnerTheme(color: Color(0xFF00FF00)),
        ),
      );

      expect(dotColor(tester), const Color(0xFF00FF00));
    });

    testWidgets('an explicit color beats the theme on an animated spinner', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const GDotSpinner(color: Color(0xFFFF0000)),
          spinnerTheme: const GSpinnerTheme(color: Color(0xFF00FF00)),
        ),
      );

      expect(dotColor(tester), const Color(0xFFFF0000));
    });
  });
}
