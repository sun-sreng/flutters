import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_form/gmana_form.dart';

void main() {
  testWidgets('GSearchField debounces input and clears text', (tester) async {
    String? searchQuery;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GSearchField(
            debounceDelay: const Duration(milliseconds: 100),
            onSearchChanged: (query) {
              searchQuery = query;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'flutter');
    expect(searchQuery, isNull);

    await tester.pump(const Duration(milliseconds: 150));
    expect(searchQuery, equals('flutter'));

    // Clear icon appears
    expect(find.byIcon(Icons.clear), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.text('flutter'), findsNothing);
  });
}
