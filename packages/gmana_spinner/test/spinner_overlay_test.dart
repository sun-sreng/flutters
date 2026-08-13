import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_spinner/gmana_spinner.dart';

void main() {
  /// A button behind the overlay, plus a tap counter to prove whether the
  /// scrim actually blocked the gesture.
  Future<int Function()> pumpOverlay(
    WidgetTester tester, {
    required bool isLoading,
    bool blockInteraction = true,
    Widget? spinner,
    Widget? message,
    String? semanticsLabel,
    GSpinnerTheme? spinnerTheme,
  }) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: spinnerTheme == null ? const [] : [spinnerTheme],
        ),
        home: Scaffold(
          body: GSpinnerOverlay(
            isLoading: isLoading,
            blockInteraction: blockInteraction,
            spinner: spinner,
            message: message,
            semanticsLabel: semanticsLabel,
            // A bare GestureDetector rather than an ElevatedButton: the
            // subject here is pointer routing, and Material's ink splash
            // pulls in a shader asset that has nothing to do with it.
            child: Center(
              child: GestureDetector(
                onTap: () => taps++,
                child: const Text('Submit'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    return () => taps;
  }

  group('GSpinnerOverlay visibility', () {
    testWidgets('shows nothing extra when idle', (tester) async {
      await pumpOverlay(tester, isLoading: false);

      expect(find.byType(GCircularSpinner), findsNothing);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows a spinner while loading', (tester) async {
      await pumpOverlay(tester, isLoading: true);

      expect(find.byType(GCircularSpinner), findsOneWidget);
    });

    testWidgets('keeps the child laid out while loading', (tester) async {
      await pumpOverlay(tester, isLoading: true);

      // The content must not be swapped out, or the screen reflows when
      // loading ends.
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('accepts a custom spinner', (tester) async {
      await pumpOverlay(
        tester,
        isLoading: true,
        spinner: const GRingSpinner(size: 20),
      );

      expect(find.byType(GRingSpinner), findsOneWidget);
      expect(find.byType(GCircularSpinner), findsNothing);
    });

    testWidgets('shows an optional message under the spinner', (tester) async {
      await pumpOverlay(
        tester,
        isLoading: true,
        message: const Text('Saving your changes'),
      );

      expect(find.text('Saving your changes'), findsOneWidget);
    });

    testWidgets('removes the overlay when loading ends', (tester) async {
      await pumpOverlay(tester, isLoading: true);
      expect(find.byType(GCircularSpinner), findsOneWidget);

      await pumpOverlay(tester, isLoading: false);
      await tester.pumpAndSettle();

      expect(find.byType(GCircularSpinner), findsNothing);
    });
  });

  group('GSpinnerOverlay input blocking', () {
    testWidgets('the button behind is tappable when idle', (tester) async {
      final taps = await pumpOverlay(tester, isLoading: false);

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(taps(), 1);
    });

    testWidgets('the scrim swallows taps while loading', (tester) async {
      final taps = await pumpOverlay(tester, isLoading: true);

      await tester.tap(find.text('Submit'), warnIfMissed: false);
      await tester.pump();

      expect(taps(), 0, reason: 'the scrim must prevent a double submission');
    });

    testWidgets('blockInteraction false lets taps through', (tester) async {
      final taps = await pumpOverlay(
        tester,
        isLoading: true,
        blockInteraction: false,
      );

      await tester.tap(find.text('Submit'), warnIfMissed: false);
      await tester.pump();

      expect(taps(), 1);
    });

    testWidgets('taps work again once loading ends', (tester) async {
      await pumpOverlay(tester, isLoading: true);
      final taps = await pumpOverlay(tester, isLoading: false);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(taps(), 1);
    });
  });

  group('GSpinnerOverlay semantics', () {
    testWidgets('announces its label while loading', (tester) async {
      final handle = tester.ensureSemantics();

      await pumpOverlay(tester, isLoading: true, semanticsLabel: 'Saving');

      expect(find.bySemanticsLabel('Saving'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('the label is a live region', (tester) async {
      final handle = tester.ensureSemantics();

      await pumpOverlay(tester, isLoading: true, semanticsLabel: 'Saving');
      final node = tester.getSemantics(find.bySemanticsLabel('Saving'));

      expect(node.flagsCollection.isLiveRegion, isTrue);

      handle.dispose();
    });

    testWidgets('falls back to the theme label', (tester) async {
      final handle = tester.ensureSemantics();

      await pumpOverlay(
        tester,
        isLoading: true,
        spinnerTheme: const GSpinnerTheme(semanticsLabel: 'Please wait'),
      );

      expect(find.bySemanticsLabel('Please wait'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('announces the label once, not once per nested spinner', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      // The overlay labels itself and its default spinner would otherwise
      // pick up the same theme label, announcing it twice.
      await pumpOverlay(
        tester,
        isLoading: true,
        spinnerTheme: const GSpinnerTheme(semanticsLabel: 'Please wait'),
      );

      expect(find.bySemanticsLabel('Please wait'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('hides the blocked content from screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await pumpOverlay(tester, isLoading: true, semanticsLabel: 'Saving');

      // The button is still laid out, but must not be reachable — it cannot
      // be activated behind the scrim.
      expect(find.text('Submit'), findsOneWidget);
      expect(find.bySemanticsLabel('Submit'), findsNothing);

      handle.dispose();
    });

    testWidgets('restores the content to screen readers when idle', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await pumpOverlay(tester, isLoading: false);

      expect(find.bySemanticsLabel('Submit'), findsOneWidget);

      handle.dispose();
    });
  });
}
