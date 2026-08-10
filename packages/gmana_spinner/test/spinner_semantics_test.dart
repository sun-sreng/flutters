import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_spinner/gmana_spinner.dart';

Widget host(Widget child, {GSpinnerTheme? spinnerTheme}) => MaterialApp(
  theme: ThemeData(
    extensions: spinnerTheme == null ? const [] : [spinnerTheme],
  ),
  home: Scaffold(body: child),
);

/// Every spinner, built with the label under test.
List<Widget> allSpinners(String? label) => [
  GCircularSpinner(semanticsLabel: label),
  GLinearSpinner(semanticsLabel: label),
  GDotSpinner(semanticsLabel: label),
  GWaveDotSpinner(size: 24, semanticsLabel: label),
  GBarWaveSpinner(semanticsLabel: label),
  GPulseSpinner(semanticsLabel: label),
  GRingSpinner(semanticsLabel: label),
  GDualRingSpinner(semanticsLabel: label),
  GChasingDotsSpinner(semanticsLabel: label),
  GFadingCubeSpinner(semanticsLabel: label),
  GRippleSpinner(semanticsLabel: label),
  GOrbitSpinner(semanticsLabel: label),
  SizedBox(
    width: 48,
    height: 48,
    child: GWaveSpinner(color: Colors.green, semanticsLabel: label),
  ),
];

void main() {
  group('semanticsLabel', () {
    testWidgets('every spinner announces an explicit label', (tester) async {
      final handle = tester.ensureSemantics();

      for (final spinner in allSpinners('Loading')) {
        await tester.pumpWidget(host(Center(child: spinner)));
        await tester.pump(const Duration(milliseconds: 50));

        expect(
          find.bySemanticsLabel('Loading'),
          findsOneWidget,
          reason: '${spinner.runtimeType} should announce its label',
        );
      }

      handle.dispose();
    });

    testWidgets('a spinner without a label adds no semantics node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(host(const Center(child: GCircularSpinner())));

      expect(find.bySemanticsLabel('Loading'), findsNothing);

      handle.dispose();
    });

    testWidgets('the theme supplies a label to an unlabelled spinner', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const Center(child: GDotSpinner()),
          spinnerTheme: const GSpinnerTheme(semanticsLabel: 'Please wait'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.bySemanticsLabel('Please wait'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('an explicit label beats the theme label', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(
          const Center(child: GDotSpinner(semanticsLabel: 'Saving')),
          spinnerTheme: const GSpinnerTheme(semanticsLabel: 'Please wait'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.bySemanticsLabel('Saving'), findsOneWidget);
      expect(find.bySemanticsLabel('Please wait'), findsNothing);

      handle.dispose();
    });

    testWidgets('the label is a live region so changes are announced', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(const Center(child: GCircularSpinner(semanticsLabel: 'Loading'))),
      );

      final node = tester.getSemantics(find.bySemanticsLabel('Loading'));

      expect(node.flagsCollection.isLiveRegion, isTrue);

      handle.dispose();
    });

    testWidgets('the inner indicator does not add a second node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(const Center(child: GCircularSpinner(semanticsLabel: 'Loading'))),
      );

      // One labelled container, not a label plus a bare progress node.
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);

      handle.dispose();
    });
  });
}
