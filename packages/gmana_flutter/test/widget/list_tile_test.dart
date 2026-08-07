import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('GListTile Widget', () {
    testWidgets('renders icon, title, label and triggers onTap', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GListTile(
              icon: Icons.settings,
              title: 'Settings',
              label: 'General',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);

      await tester.tap(find.byType(GListTile));
      expect(tapped, isTrue);
    });
  });
}
