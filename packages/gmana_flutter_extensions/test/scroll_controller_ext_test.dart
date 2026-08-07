import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

/// Pumps a list tall enough to scroll and returns its attached controller.
Future<ScrollController> pumpScrollable(
  WidgetTester tester, {
  int itemCount = 40,
}) async {
  final controller = ScrollController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          controller: controller,
          itemCount: itemCount,
          itemExtent: 50,
          itemBuilder: (_, i) => Text('item $i'),
        ),
      ),
    ),
  );

  return controller;
}

void main() {
  group('ScrollControllerX without clients', () {
    test('reads degrade to safe defaults instead of throwing', () {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      expect(controller.hasClients, isFalse);
      expect(controller.offsetOrZero, 0);
      expect(controller.maxScroll, 0);
      expect(controller.minScroll, 0);
      expect(controller.progress, 0);
      expect(controller.isAtTop, isFalse);
      expect(controller.isAtBottom, isFalse);
      expect(controller.isScrollable, isFalse);
      expect(controller.isScrollingUp, isFalse);
      expect(controller.isScrollingDown, isFalse);
      expect(controller.isNearTop(), isFalse);
      expect(controller.isNearBottom(), isFalse);
    });

    test('writes are no-ops instead of throwing', () async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      expect(controller.jumpToTop, returnsNormally);
      expect(controller.jumpToBottom, returnsNormally);
      expect(() => controller.jumpToClamped(100), returnsNormally);
      await expectLater(controller.animateToTop(), completes);
      await expectLater(controller.animateToBottom(), completes);
    });
  });

  group('ScrollControllerX position queries', () {
    testWidgets('starts at the top', (tester) async {
      final controller = await pumpScrollable(tester);

      expect(controller.isAtTop, isTrue);
      expect(controller.isAtBottom, isFalse);
      expect(controller.isScrollable, isTrue);
      expect(controller.progress, 0);
      expect(controller.offsetOrZero, 0);
      expect(controller.maxScroll, greaterThan(0));
    });

    testWidgets('reports the bottom after jumping there', (tester) async {
      final controller = await pumpScrollable(tester);

      controller.jumpToBottom();
      await tester.pump();

      expect(controller.isAtBottom, isTrue);
      expect(controller.isAtTop, isFalse);
      expect(controller.progress, 1.0);
    });

    testWidgets('progress is proportional in the middle', (tester) async {
      final controller = await pumpScrollable(tester);

      controller.jumpTo(controller.maxScroll / 2);
      await tester.pump();

      expect(controller.progress, closeTo(0.5, 0.001));
    });

    testWidgets('a non-scrollable list reports zero progress', (tester) async {
      final controller = await pumpScrollable(tester, itemCount: 1);

      expect(controller.isScrollable, isFalse);
      expect(controller.progress, 0);
      expect(controller.isAtTop, isTrue);
      expect(controller.isAtBottom, isTrue);
    });
  });

  group('ScrollControllerX proximity', () {
    testWidgets('isNearBottom fires before the true end', (tester) async {
      final controller = await pumpScrollable(tester);

      expect(controller.isNearBottom(), isFalse);

      controller.jumpTo(controller.maxScroll - 100);
      await tester.pump();

      expect(controller.isNearBottom(), isTrue);
      expect(controller.isAtBottom, isFalse);
    });

    testWidgets('isNearTop fires before the true start', (tester) async {
      final controller = await pumpScrollable(tester);

      controller.jumpTo(100);
      await tester.pump();

      expect(controller.isNearTop(), isTrue);
      expect(controller.isAtTop, isFalse);
      expect(controller.isNearTop(tolerance: 50), isFalse);
    });

    testWidgets('proximity rejects a negative tolerance', (tester) async {
      final controller = await pumpScrollable(tester);

      expect(() => controller.isNearTop(tolerance: -1), throwsArgumentError);
      expect(() => controller.isNearBottom(tolerance: -1), throwsArgumentError);
    });
  });

  group('ScrollControllerX movement', () {
    testWidgets('animateToBottom then animateToTop', (tester) async {
      final controller = await pumpScrollable(tester);

      // The animation future only completes once the tester advances time, so
      // it must be started before pumping and awaited after.
      var pending = controller.animateToBottom(
        duration: const Duration(milliseconds: 50),
      );
      await tester.pumpAndSettle();
      await pending;
      expect(controller.isAtBottom, isTrue);

      pending = controller.animateToTop(
        duration: const Duration(milliseconds: 50),
      );
      await tester.pumpAndSettle();
      await pending;
      expect(controller.isAtTop, isTrue);
    });

    testWidgets('jumpToClamped stays inside the scroll range', (tester) async {
      final controller = await pumpScrollable(tester);

      controller.jumpToClamped(999999);
      await tester.pump();
      expect(controller.offset, controller.maxScroll);

      controller.jumpToClamped(-999999);
      await tester.pump();
      expect(controller.offset, controller.minScroll);
    });
  });
}
