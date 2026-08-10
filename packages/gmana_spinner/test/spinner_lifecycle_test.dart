import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_spinner/gmana_spinner.dart';

Widget host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('owned controller', () {
    testWidgets('animates on its own and disposes cleanly', (tester) async {
      await tester.pumpWidget(host(const GDotSpinner()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(GDotSpinner), findsOneWidget);

      // Replacing the tree disposes the state; a leaked ticker fails the test.
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pump();

      expect(find.byType(GDotSpinner), findsNothing);
    });

    testWidgets('picks up a changed duration without restarting', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const GDotSpinner(duration: Duration(milliseconds: 1000))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(
        host(const GDotSpinner(duration: Duration(milliseconds: 400))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('stops when TickerMode is disabled and resumes after', (
      tester,
    ) async {
      Widget build({required bool enabled}) =>
          host(TickerMode(enabled: enabled, child: const GDotSpinner()));

      await tester.pumpWidget(build(enabled: true));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(build(enabled: false));
      await tester.pump(const Duration(milliseconds: 100));

      // A still-running ticker would make pumpAndSettle time out here.
      await tester.pumpAndSettle();

      await tester.pumpWidget(build(enabled: true));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.byType(GDotSpinner), findsOneWidget);
    });
  });

  group('external controller', () {
    testWidgets('is used as-is and is not disposed by the widget', (
      tester,
    ) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 500),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(host(GDotSpinner(controller: controller)));
      await tester.pump(const Duration(milliseconds: 50));

      // The widget must not start playback on a controller it does not own.
      expect(controller.isAnimating, isFalse);

      await tester.pumpWidget(host(const SizedBox()));
      await tester.pump();

      // Still usable after the widget is gone — proof it was not disposed.
      expect(() => controller.value = 0.5, returnsNormally);
      expect(controller.value, 0.5);
    });

    testWidgets('the caller drives the animation', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 500),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(host(GDotSpinner(controller: controller)));

      controller.value = 0.25;
      await tester.pump();

      expect(controller.value, 0.25);
      expect(tester.takeException(), isNull);
    });

    testWidgets('swapping from an owned to an external controller is safe', (
      tester,
    ) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 500),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(host(const GDotSpinner()));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(host(GDotSpinner(controller: controller)));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.byType(GDotSpinner), findsOneWidget);
    });

    testWidgets(
      'swapping from an external back to an owned controller is safe',
      (tester) async {
        final controller = AnimationController(
          vsync: const TestVSync(),
          duration: const Duration(milliseconds: 500),
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(host(GDotSpinner(controller: controller)));
        await tester.pump(const Duration(milliseconds: 50));

        await tester.pumpWidget(host(const GDotSpinner()));
        await tester.pump(const Duration(milliseconds: 50));

        expect(tester.takeException(), isNull);
        // The external controller survived the swap.
        expect(() => controller.value = 0.1, returnsNormally);
      },
    );
  });

  group('constructor assertions', () {
    test('reject non-positive sizes and counts', () {
      expect(() => GDotSpinner(size: 0), throwsAssertionError);
      expect(() => GDotSpinner(size: -1), throwsAssertionError);
      expect(() => GDotSpinner(dotCount: 0), throwsAssertionError);
      expect(() => GCircularSpinner(strokeWidth: 0), throwsAssertionError);
      expect(() => GLinearSpinner(minHeight: 0), throwsAssertionError);
    });

    test('accept valid values', () {
      expect(() => const GDotSpinner(size: 1, dotCount: 1), returnsNormally);
      expect(() => const GCircularSpinner(strokeWidth: 0.5), returnsNormally);
    });
  });

  group('itemBuilder', () {
    testWidgets('replaces the default dot and silently ignores color', (
      tester,
    ) async {
      // The README used to claim passing both throws; it does not. The
      // builder simply wins and `color` goes unused.
      await tester.pumpWidget(
        host(
          GDotSpinner(
            color: Colors.red,
            dotCount: 2,
            itemBuilder: (context, index) => const Text('dot'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('dot'), findsNWidgets(2));
      expect(find.byType(DecoratedBox), findsNothing);
    });

    testWidgets('receives the dot index', (tester) async {
      await tester.pumpWidget(
        host(
          GDotSpinner(
            dotCount: 3,
            itemBuilder: (context, index) => Text('dot$index'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('dot0'), findsOneWidget);
      expect(find.text('dot1'), findsOneWidget);
      expect(find.text('dot2'), findsOneWidget);
    });
  });

  group('every animated spinner survives a full cycle', () {
    final builders = <String, Widget Function()>{
      'GDotSpinner': GDotSpinner.new,
      'GWaveDotSpinner': () => const GWaveDotSpinner(size: 24),
      'GBarWaveSpinner': GBarWaveSpinner.new,
      'GPulseSpinner': GPulseSpinner.new,
      'GRingSpinner': GRingSpinner.new,
      'GDualRingSpinner': GDualRingSpinner.new,
      'GChasingDotsSpinner': GChasingDotsSpinner.new,
      'GFadingCubeSpinner': GFadingCubeSpinner.new,
      'GRippleSpinner': GRippleSpinner.new,
      'GOrbitSpinner': GOrbitSpinner.new,
      'GWaveSpinner':
          () => const SizedBox(
            width: 48,
            height: 48,
            child: GWaveSpinner(color: Colors.green),
          ),
    };

    for (final entry in builders.entries) {
      testWidgets('${entry.key} animates and tears down', (tester) async {
        await tester.pumpWidget(host(entry.value()));

        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }

        expect(tester.takeException(), isNull);

        await tester.pumpWidget(host(const SizedBox()));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
