import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

Widget host(Widget child) =>
    MaterialApp(theme: GColors.lightTheme, home: Scaffold(body: child));

BoxDecoration bannerDecoration(WidgetTester tester) =>
    tester
            .widget<Container>(
              find
                  .descendant(
                    of: find.byType(GBanner),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  group('GBanner content', () {
    testWidgets('renders the message', (tester) async {
      await tester.pumpWidget(host(const GBanner(message: 'Heads up')));
      expect(find.text('Heads up'), findsOneWidget);
    });

    testWidgets('renders an optional title above the message', (tester) async {
      await tester.pumpWidget(
        host(const GBanner(title: 'Overdue', message: 'Update your card.')),
      );

      expect(find.text('Overdue'), findsOneWidget);
      expect(find.text('Update your card.'), findsOneWidget);
    });

    testWidgets('shows the tone icon by default', (tester) async {
      await tester.pumpWidget(
        host(const GBanner(message: 'Saved', tone: GTone.success)),
      );

      expect(find.byIcon(GTone.success.icon), findsOneWidget);
    });

    testWidgets('honours a custom icon', (tester) async {
      await tester.pumpWidget(
        host(const GBanner(message: 'Custom', icon: Icons.rocket_launch)),
      );

      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
    });

    testWidgets('hides the icon when showIcon is false', (tester) async {
      await tester.pumpWidget(
        host(const GBanner(message: 'Quiet', showIcon: false)),
      );

      expect(find.byType(Icon), findsNothing);
    });
  });

  group('GBanner tone', () {
    testWidgets('uses the container color and an outline when not filled', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const GBanner(message: 'Note', tone: GTone.warning)),
      );

      final decoration = bannerDecoration(tester);
      expect(decoration.color, GColors.warningContainer);
      expect(decoration.border, isNotNull);
    });

    testWidgets('uses the accent color and no outline when filled', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const GBanner(message: 'Note', tone: GTone.warning, filled: true)),
      );

      final decoration = bannerDecoration(tester);
      expect(decoration.color, GColors.warning);
      expect(decoration.border, isNull);
    });
  });

  group('GBanner actions', () {
    testWidgets('has no close button without onDismiss', (tester) async {
      await tester.pumpWidget(host(const GBanner(message: 'Sticky')));
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('invokes onDismiss from the close button', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        host(GBanner(message: 'Dismiss me', onDismiss: () => dismissed = true)),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('renders trailing actions', (tester) async {
      await tester.pumpWidget(
        host(
          GBanner(
            message: 'Retry?',
            actions: [
              GButton(
                label: 'Retry',
                size: GButtonSize.small,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
    });
  });

  testWidgets('GBanner announces itself as a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(const GBanner(title: 'Saved', message: 'All good.')),
    );

    expect(find.bySemanticsLabel('Saved. All good.'), findsOneWidget);
    handle.dispose();
  });
}
