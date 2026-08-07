import 'package:flutter/material.dart';

/// Text inspection and cursor management on [TextEditingController].
extension TextEditingControllerX on TextEditingController {
  /// Whether the field is empty or contains only whitespace.
  bool get isBlank => text.trim().isEmpty;

  /// Whether the field contains at least one non-whitespace character.
  bool get isNotBlank => !isBlank;

  /// The text with leading and trailing whitespace removed.
  String get trimmedText => text.trim();

  /// The trimmed text, or `null` when blank.
  ///
  /// Pairs well with optional model fields, where `''` and "not provided"
  /// should not be the same thing.
  String? get trimmedTextOrNull => isBlank ? null : trimmedText;

  /// Replaces the content and parks the cursor at the end.
  ///
  /// Plain `controller.text = value` resets the selection to offset 0, which
  /// makes the caret jump to the start when the user keeps typing.
  void setTextAndCursorToEnd(String newText) {
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  /// Moves the cursor to the end without changing the text.
  void moveCursorToEnd() {
    selection = TextSelection.collapsed(offset: text.length);
  }

  /// Selects the entire content.
  void selectAll() {
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }

  /// Inserts [insertion] at the cursor, replacing the selection if there is
  /// one, and leaves the cursor after the inserted text.
  ///
  /// Falls back to appending when the selection is not valid yet.
  void insertAtCursor(String insertion) {
    final current = value;
    if (!current.selection.isValid) {
      setTextAndCursorToEnd(current.text + insertion);
      return;
    }

    final replaced = current.selection.textInside(current.text);
    final start = current.selection.start;
    final newText = current.text.replaceRange(
      start,
      start + replaced.length,
      insertion,
    );

    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
  }

  /// Clears the text and collapses the selection.
  void clearAndReset() {
    value = TextEditingValue.empty;
  }
}
