import 'dart:async';

import 'package:flutter/material.dart';

/// Coordinates a Flutter [Form] and named text controllers.
///
/// This is intentionally small: it handles the repetitive form key,
/// validate/save/reset flow, and controller disposal for forms that do not need
/// a larger state-management solution.
final class GFormController extends ChangeNotifier {
  /// The [GlobalKey] attached to the underlying Flutter [Form].
  final GlobalKey<FormState> key;
  final Map<String, TextEditingController> _textControllers = {};
  bool _submitting = false;

  /// Creates a controller. Pass an existing [key] to reuse a form key, or
  /// omit it to have one created automatically.
  GFormController({GlobalKey<FormState>? key})
    : key = key ?? GlobalKey<FormState>();

  /// The current [FormState], or `null` if the form has not been mounted yet.
  FormState? get state => key.currentState;

  /// Whether [submit] is currently in flight.
  bool get submitting => _submitting;

  /// Returns the [TextEditingController] registered under [name], creating
  /// one with [text] as its initial value if it doesn't exist yet.
  ///
  /// Controllers are disposed automatically when this controller is disposed.
  TextEditingController textController(String name, {String? text}) {
    return _textControllers.putIfAbsent(
      name,
      () => TextEditingController(text: text),
    );
  }

  /// Current text of the controller registered under [name].
  String text(String name) => textController(name).text;

  /// Snapshot of every registered field's current text, keyed by name.
  Map<String, String> textValues() {
    return {
      for (final entry in _textControllers.entries) entry.key: entry.value.text,
    };
  }

  /// Runs every registered validator. Returns `true` if the form is valid.
  bool validate() => state?.validate() ?? false;

  /// Calls `onSaved` on every field.
  void save() => state?.save();

  /// Resets the form and clears every registered text controller.
  void reset() {
    state?.reset();
    for (final controller in _textControllers.values) {
      controller.clear();
    }
  }

  /// Validates the form and, if valid, calls [save]. Returns whether the
  /// form was valid.
  bool validateAndSave() {
    if (!validate()) {
      return false;
    }
    save();
    return true;
  }

  /// Validates, saves, and runs [onSubmit] with the current text values.
  ///
  /// Sets [submitting] to `true` for the duration of [onSubmit] and guards
  /// against concurrent submissions. If [resetOnSuccess] is `true`, the form
  /// is reset after [onSubmit] completes successfully. Returns `false` if
  /// the form failed validation or a submission was already in progress.
  Future<bool> submit(
    FutureOr<void> Function(Map<String, String> values) onSubmit, {
    bool resetOnSuccess = false,
  }) async {
    if (_submitting || !validateAndSave()) {
      return false;
    }

    _setSubmitting(true);
    try {
      await onSubmit(textValues());
      if (resetOnSuccess) {
        reset();
      }
      return true;
    } finally {
      _setSubmitting(false);
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    super.dispose();
  }

  void _setSubmitting(bool value) {
    if (_submitting == value) {
      return;
    }
    _submitting = value;
    notifyListeners();
  }
}
