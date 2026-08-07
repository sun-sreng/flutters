import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

void main() {
  testWidgets('ValueNotifierX update and ListenableX build', (tester) async {
    final notifier = ValueNotifier<int>(10);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: notifier.build((context) => Text('Count: ${notifier.value}')),
        ),
      ),
    );

    expect(find.text('Count: 10'), findsOneWidget);

    notifier.update((c) => c + 5);
    await tester.pump();

    expect(find.text('Count: 15'), findsOneWidget);
    notifier.dispose();
  });
}
