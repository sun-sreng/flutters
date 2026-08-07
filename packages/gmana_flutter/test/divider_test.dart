import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  testWidgets('GDivider renders divider with label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GDivider(
            label: 'OR',
          ),
        ),
      ),
    );

    expect(find.text('OR'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
  });
}
