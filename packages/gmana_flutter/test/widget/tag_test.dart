import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

Widget host(Widget child) =>
    MaterialApp(theme: GColors.lightTheme, home: Scaffold(body: child));

Material tagMaterial(WidgetTester tester) => tester.widget<Material>(
  find.descendant(of: find.byType(GTag), matching: find.byType(Material)).first,
);

void main() {
  group('GTag', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(host(const GTag(label: 'Active')));
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders an optional leading icon', (tester) async {
      await tester.pumpWidget(
        host(const GTag(label: 'Verified', icon: Icons.check)),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('omits the icon slot when none is given', (tester) async {
      await tester.pumpWidget(host(const GTag(label: 'Plain')));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('uses the tone container when not filled', (tester) async {
      await tester.pumpWidget(
        host(const GTag(label: 'Done', tone: GTone.success)),
      );

      expect(tagMaterial(tester).color, GColors.successContainer);
    });

    testWidgets('uses the tone accent when filled', (tester) async {
      await tester.pumpWidget(
        host(const GTag(label: 'Failed', tone: GTone.error, filled: true)),
      );

      expect(tagMaterial(tester).color, GColors.error);
    });

    testWidgets('is not tappable by default', (tester) async {
      await tester.pumpWidget(host(const GTag(label: 'Static')));

      expect(
        find.descendant(of: find.byType(GTag), matching: find.byType(InkWell)),
        findsNothing,
      );
    });

    testWidgets('invokes onTap when provided', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(GTag(label: 'Filter', onTap: () => taps++)));

      await tester.tap(find.byType(GTag));
      expect(taps, 1);
    });

    testWidgets('compact still renders the label', (tester) async {
      await tester.pumpWidget(host(const GTag(label: 'New', compact: true)));

      expect(find.text('New'), findsOneWidget);
      expect(tester.widget<Text>(find.text('New')).style?.fontSize, 11);
    });

    testWidgets('exposes the label to semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const GTag(label: 'Archived')));

      expect(find.bySemanticsLabel('Archived'), findsOneWidget);
      handle.dispose();
    });
  });
}
