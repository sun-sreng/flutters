import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

Widget host(Widget child) =>
    MaterialApp(theme: GColors.lightTheme, home: Scaffold(body: child));

void main() {
  group('GEmptyState', () {
    testWidgets('renders the title and the default icon', (tester) async {
      await tester.pumpWidget(host(const GEmptyState(title: 'No messages')));

      expect(find.text('No messages'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders the optional message', (tester) async {
      await tester.pumpWidget(
        host(
          const GEmptyState(
            title: 'No results',
            message: 'Try a different search term.',
          ),
        ),
      );

      expect(find.text('Try a different search term.'), findsOneWidget);
    });

    testWidgets('omits the message row when none is given', (tester) async {
      await tester.pumpWidget(host(const GEmptyState(title: 'Only a title')));
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders a custom icon', (tester) async {
      await tester.pumpWidget(
        host(const GEmptyState(title: 'Offline', icon: Icons.wifi_off)),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('an illustration replaces the icon entirely', (tester) async {
      await tester.pumpWidget(
        host(
          const GEmptyState(
            title: 'Custom art',
            illustration: SizedBox(key: Key('art'), width: 40, height: 40),
          ),
        ),
      );

      expect(find.byKey(const Key('art')), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('renders the action and forwards taps', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        host(
          GEmptyState(
            title: 'Nothing here',
            action: GButton(label: 'Refresh', onPressed: () => pressed = true),
          ),
        ),
      );

      await tester.tap(find.text('Refresh'));
      expect(pressed, isTrue);
    });

    testWidgets('compact shrinks the icon', (tester) async {
      await tester.pumpWidget(host(const GEmptyState(title: 'Empty')));
      final normalSize =
          tester.widget<Icon>(find.byIcon(Icons.inbox_outlined)).size;

      await tester.pumpWidget(
        host(const GEmptyState(title: 'Empty', compact: true)),
      );
      final compactSize =
          tester.widget<Icon>(find.byIcon(Icons.inbox_outlined)).size;

      expect(compactSize, lessThan(normalSize!));
    });

    testWidgets('merges title and message into one semantics label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const GEmptyState(title: 'No messages', message: 'Nothing yet.')),
      );

      expect(
        find.bySemanticsLabel('No messages. Nothing yet.'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
