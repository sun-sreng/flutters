import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

Widget host(Widget child) =>
    MaterialApp(theme: GColors.lightTheme, home: Scaffold(body: child));

/// A 1x1 transparent PNG, enough to exercise the image branch.
final _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

void main() {
  group('GAvatar initials', () {
    testWidgets('derives initials from a name', (tester) async {
      await tester.pumpWidget(host(const GAvatar(name: 'Ada Lovelace')));
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('honours maxInitials', (tester) async {
      await tester.pumpWidget(
        host(const GAvatar(name: 'Grace Brewster Hopper', maxInitials: 3)),
      );

      expect(find.text('GBH'), findsOneWidget);
    });

    testWidgets('falls back to the icon without a name', (tester) async {
      await tester.pumpWidget(host(const GAvatar()));

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('falls back to the icon for a blank name', (tester) async {
      await tester.pumpWidget(host(const GAvatar(name: '   ')));
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });

  group('GAvatar.tintFor', () {
    test('is stable for the same seed', () {
      expect(GAvatar.tintFor('Ada'), GAvatar.tintFor('Ada'));
    });

    test('ignores case and surrounding whitespace', () {
      expect(GAvatar.tintFor('  ADA  '), GAvatar.tintFor('ada'));
    });

    test('spreads different seeds across the palette', () {
      final tints = {
        for (final name in [
          'Ada',
          'Grace',
          'Alan',
          'Barbara',
          'Katherine',
          'Margaret',
        ])
          GAvatar.tintFor(name),
      };

      expect(tints.length, greaterThan(1));
    });

    test('handles a null or empty seed', () {
      expect(GAvatar.tintFor(null), isA<Color>());
      expect(GAvatar.tintFor(''), GAvatar.tintFor(null));
    });
  });

  group('GAvatar rendering', () {
    testWidgets('sizes itself to the requested diameter', (tester) async {
      await tester.pumpWidget(host(const GAvatar(name: 'Ada', size: 56)));

      expect(tester.getSize(find.byType(GAvatar)), const Size(56, 56));
    });

    testWidgets('renders an Image when one is supplied', (tester) async {
      await tester.pumpWidget(
        host(GAvatar(image: MemoryImage(_pixel), name: 'Ada')),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('is circular by default and square on request', (tester) async {
      await tester.pumpWidget(host(const GAvatar(name: 'Ada')));
      var material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(GAvatar),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.shape, isA<CircleBorder>());

      await tester.pumpWidget(host(const GAvatar(name: 'Ada', square: true)));
      material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(GAvatar),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('invokes onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(GAvatar(name: 'Ada', onTap: () => taps++)));

      await tester.tap(find.byType(GAvatar));
      expect(taps, 1);
    });

    testWidgets('renders a badge in the trailing corner', (tester) async {
      await tester.pumpWidget(
        host(
          const GAvatar(
            name: 'Ada',
            badge: Icon(Icons.circle, size: 10, color: Colors.green),
          ),
        ),
      );

      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('exposes the name to semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const GAvatar(name: 'Ada Lovelace')));

      expect(find.bySemanticsLabel('Ada Lovelace'), findsOneWidget);
      handle.dispose();
    });
  });
}
