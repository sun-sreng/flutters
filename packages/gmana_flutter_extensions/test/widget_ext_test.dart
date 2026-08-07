import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

const _child = Text('child');

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('WidgetX existing wrappers', () {
    testWidgets('padding helpers', (tester) async {
      await tester.pumpWidget(host(_child.paddingAll(8)));
      expect(
        tester.widget<Padding>(find.byType(Padding).first).padding,
        const EdgeInsets.all(8),
      );

      await tester.pumpWidget(host(_child.paddingSymmetric(horizontal: 4)));
      expect(
        tester.widget<Padding>(find.byType(Padding).first).padding,
        const EdgeInsets.symmetric(horizontal: 4),
      );

      await tester.pumpWidget(host(_child.paddingOnly(top: 2, bottom: 3)));
      expect(
        tester.widget<Padding>(find.byType(Padding).first).padding,
        const EdgeInsets.only(top: 2, bottom: 3),
      );
    });

    testWidgets('centered, expanded, flexible, fitted, clipped', (
      tester,
    ) async {
      await tester.pumpWidget(host(_child.centered));
      expect(find.byType(Center), findsOneWidget);

      await tester.pumpWidget(host(Row(children: [_child.expanded(2)])));
      expect(tester.widget<Expanded>(find.byType(Expanded)).flex, 2);

      await tester.pumpWidget(host(Row(children: [_child.flexible(3)])));
      expect(tester.widget<Flexible>(find.byType(Flexible)).flex, 3);

      await tester.pumpWidget(host(_child.fitted(BoxFit.fill)));
      expect(tester.widget<FittedBox>(find.byType(FittedBox)).fit, BoxFit.fill);

      await tester.pumpWidget(host(_child.clipped(BorderRadius.circular(4))));
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('onTap forwards the callback', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(_child.onTap(() => taps++)));

      await tester.tap(find.text('child'));
      expect(taps, 1);
    });
  });

  group('WidgetX sizing', () {
    testWidgets('sized and squared', (tester) async {
      await tester.pumpWidget(host(_child.sized(width: 30, height: 20)));
      expect(tester.getSize(find.byType(SizedBox).first), const Size(30, 20));

      await tester.pumpWidget(host(_child.squared(25)));
      expect(tester.getSize(find.byType(SizedBox).first), const Size(25, 25));
    });

    testWidgets('constrained applies the bounds', (tester) async {
      await tester.pumpWidget(host(_child.constrained(maxWidth: 40)));

      final box = tester.widget<ConstrainedBox>(
        find
            .ancestor(
              of: find.text('child'),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(box.constraints.maxWidth, 40);
    });

    testWidgets('aspectRatio wraps in AspectRatio', (tester) async {
      await tester.pumpWidget(host(_child.aspectRatio(2)));
      expect(
        tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
        2,
      );
    });
  });

  group('WidgetX positioning', () {
    testWidgets('aligned defaults to center', (tester) async {
      await tester.pumpWidget(host(_child.aligned()));
      expect(
        tester.widget<Align>(find.byType(Align).first).alignment,
        Alignment.center,
      );

      await tester.pumpWidget(host(_child.aligned(Alignment.topRight)));
      expect(
        tester.widget<Align>(find.byType(Align).first).alignment,
        Alignment.topRight,
      );
    });

    testWidgets('positioned works inside a Stack', (tester) async {
      await tester.pumpWidget(
        host(Stack(children: [_child.positioned(left: 5, top: 7)])),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, 5);
      expect(positioned.top, 7);
    });

    testWidgets('safeArea wraps in SafeArea', (tester) async {
      await tester.pumpWidget(host(_child.safeArea));
      expect(find.byType(SafeArea), findsWidgets);
    });
  });

  group('WidgetX painting', () {
    testWidgets('opacity applies and validates', (tester) async {
      await tester.pumpWidget(host(_child.opacity(0.5)));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.5);

      expect(() => _child.opacity(1.5), throwsArgumentError);
      expect(() => _child.opacity(-0.1), throwsArgumentError);
      expect(() => _child.opacity(double.nan), throwsArgumentError);
    });

    testWidgets('decorated and background', (tester) async {
      // Scope to our own wrapper — the Scaffold contributes its own
      // DecoratedBox/ColoredBox higher in the tree.
      const decoration = BoxDecoration(color: Color(0xFF00FF00));
      await tester.pumpWidget(host(_child.decorated(decoration)));
      expect(
        tester
            .widget<DecoratedBox>(
              find
                  .ancestor(
                    of: find.text('child'),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration,
        decoration,
      );

      await tester.pumpWidget(host(_child.background(const Color(0xFF0000FF))));
      expect(
        tester
            .widget<ColoredBox>(
              find
                  .ancestor(
                    of: find.text('child'),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .color,
        const Color(0xFF0000FF),
      );
    });

    testWidgets('rotated and scaled', (tester) async {
      await tester.pumpWidget(host(_child.rotated(1)));
      expect(
        tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns,
        1,
      );

      await tester.pumpWidget(host(_child.scaled(2)));
      expect(find.byType(Transform), findsWidgets);
    });
  });

  group('WidgetX visibility and input', () {
    testWidgets('visible swaps in a zero-size replacement', (tester) async {
      await tester.pumpWidget(host(_child.visible(true)));
      expect(find.text('child'), findsOneWidget);

      await tester.pumpWidget(host(_child.visible(false)));
      expect(find.text('child'), findsNothing);
    });

    testWidgets('visible accepts a custom replacement', (tester) async {
      await tester.pumpWidget(
        host(_child.visible(false, replacement: const Text('fallback'))),
      );

      expect(find.text('fallback'), findsOneWidget);
    });

    testWidgets('ignorePointer blocks taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(_child.onTap(() => taps++).ignorePointer()));

      await tester.tap(find.text('child'), warnIfMissed: false);
      expect(taps, 0);

      await tester.pumpWidget(
        host(_child.onTap(() => taps++).ignorePointer(ignoring: false)),
      );
      await tester.tap(find.text('child'));
      expect(taps, 1);
    });

    testWidgets('absorbPointer swallows taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(_child.onTap(() => taps++).absorbPointer()));

      await tester.tap(find.text('child'), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('inkWell responds to tap and long press', (tester) async {
      var taps = 0;
      var longPresses = 0;

      await tester.pumpWidget(
        host(
          Material(
            child: _child.inkWell(
              onTap: () => taps++,
              onLongPress: () => longPresses++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('child'));
      await tester.longPress(find.text('child'));

      expect(taps, 1);
      expect(longPresses, 1);
    });

    testWidgets('tooltip and hero wrap correctly', (tester) async {
      await tester.pumpWidget(host(_child.tooltip('hint')));
      expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, 'hint');

      await tester.pumpWidget(host(_child.hero('tag')));
      expect(tester.widget<Hero>(find.byType(Hero)).tag, 'tag');
    });
  });

  testWidgets('WidgetX.sliverBox works in a CustomScrollView', (tester) async {
    await tester.pumpWidget(
      host(CustomScrollView(slivers: [_child.sliverBox])),
    );

    expect(find.byType(SliverToBoxAdapter), findsOneWidget);
    expect(find.text('child'), findsOneWidget);
  });
}
