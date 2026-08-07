import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

TextEditingController controllerWith(String text) {
  final controller = TextEditingController(text: text);
  addTearDown(controller.dispose);
  return controller;
}

void main() {
  group('TextEditingControllerX inspection', () {
    test('isBlank treats whitespace as empty', () {
      expect(controllerWith('').isBlank, isTrue);
      expect(controllerWith('   ').isBlank, isTrue);
      expect(controllerWith('\n\t').isBlank, isTrue);
      expect(controllerWith('a').isBlank, isFalse);
      expect(controllerWith('a').isNotBlank, isTrue);
    });

    test('trimmedText strips the edges', () {
      expect(controllerWith('  hello  ').trimmedText, 'hello');
      expect(controllerWith('   ').trimmedText, '');
    });

    test('trimmedTextOrNull separates blank from provided', () {
      expect(controllerWith('   ').trimmedTextOrNull, isNull);
      expect(controllerWith('').trimmedTextOrNull, isNull);
      expect(controllerWith('  hi  ').trimmedTextOrNull, 'hi');
    });
  });

  group('TextEditingControllerX cursor management', () {
    test('setTextAndCursorToEnd parks the caret at the end', () {
      final controller = controllerWith('old');
      controller.setTextAndCursorToEnd('brand new');

      expect(controller.text, 'brand new');
      expect(controller.selection.baseOffset, 'brand new'.length);
      expect(controller.selection.isCollapsed, isTrue);
    });

    test('moveCursorToEnd leaves the text alone', () {
      final controller = controllerWith('hello');
      controller.selection = const TextSelection.collapsed(offset: 0);

      controller.moveCursorToEnd();

      expect(controller.text, 'hello');
      expect(controller.selection.baseOffset, 5);
    });

    test('selectAll spans the whole value', () {
      final controller = controllerWith('hello');
      controller.selectAll();

      expect(controller.selection.baseOffset, 0);
      expect(controller.selection.extentOffset, 5);
    });

    test('clearAndReset empties the text and the selection', () {
      final controller = controllerWith('hello')..selectAll();
      controller.clearAndReset();

      expect(controller.text, isEmpty);
      expect(controller.selection, TextEditingValue.empty.selection);
    });
  });

  group('TextEditingControllerX.insertAtCursor', () {
    test('inserts at a collapsed cursor', () {
      final controller = controllerWith('hello');
      controller.selection = const TextSelection.collapsed(offset: 2);

      controller.insertAtCursor('XX');

      expect(controller.text, 'heXXllo');
      expect(controller.selection.baseOffset, 4);
    });

    test('replaces an active selection', () {
      final controller = controllerWith('hello');
      controller.selection = const TextSelection(
        baseOffset: 2,
        extentOffset: 4,
      );

      controller.insertAtCursor('Z');

      expect(controller.text, 'heZo');
      expect(controller.selection.baseOffset, 3);
    });

    test('appends when the selection is not established yet', () {
      // A freshly constructed controller has an invalid (-1) selection.
      final controller = controllerWith('ab');
      expect(controller.selection.isValid, isFalse);

      controller.insertAtCursor('cd');

      expect(controller.text, 'abcd');
      expect(controller.selection.baseOffset, 4);
    });

    test('inserting at the start keeps the rest intact', () {
      final controller = controllerWith('world');
      controller.selection = const TextSelection.collapsed(offset: 0);

      controller.insertAtCursor('hello ');

      expect(controller.text, 'hello world');
      expect(controller.selection.baseOffset, 6);
    });
  });

  group('TextEditingControllerX in a live field', () {
    testWidgets('setTextAndCursorToEnd survives further typing', (
      tester,
    ) async {
      final controller = controllerWith('');

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: TextField(controller: controller))),
      );

      controller.setTextAndCursorToEnd('abc');
      await tester.pump();

      expect(controller.text, 'abc');
      expect(controller.selection.baseOffset, 3);
    });
  });
}
