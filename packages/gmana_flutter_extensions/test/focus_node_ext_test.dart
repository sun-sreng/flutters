import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

void main() {
  testWidgets('FocusNodeX toggleFocus and selectAll', (tester) async {
    final focusNode = FocusNode();
    final controller = TextEditingController(text: 'Hello World');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            focusNode: focusNode,
            controller: controller,
          ),
        ),
      ),
    );

    expect(focusNode.hasFocus, isFalse);

    focusNode.toggleFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    focusNode.selectAll(controller);
    await tester.pump();
    expect(controller.selection.baseOffset, equals(0));
    expect(controller.selection.extentOffset, equals(11));

    focusNode.dispose();
    controller.dispose();
  });
}
