import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/form.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('GNetworkField renders label and accepts input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: GNetworkField(label: 'IP Field'))),
    );

    expect(find.text('IP Field'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '192.168.1.1');
    await tester.pump();

    expect(find.text('192.168.1.1'), findsOneWidget);
  });
}
