import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/form.dart';
import 'package:material_ui/material_ui.dart';

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

  testWidgets('GSearchField with a zero delay reports every change at once', (
    tester,
  ) async {
    final queries = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GSearchField(
            debounceDelay: Duration.zero,
            onSearchChanged: queries.add,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'a');
    await tester.enterText(find.byType(TextFormField), 'ab');

    expect(queries, ['a', 'ab']);
  });

  testWidgets('GSearchField cancels a pending search when disposed', (
    tester,
  ) async {
    String? searchQuery;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GSearchField(
            debounceDelay: const Duration(milliseconds: 100),
            onSearchChanged: (query) => searchQuery = query,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'flutter');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 150));

    expect(searchQuery, isNull);
  });
}
