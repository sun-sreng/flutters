import 'dart:async';

import 'package:flutter/material.dart';

/// Snapshot of typed form values keyed by field name.
final class GFormValues {
  final Map<String, Object?> _values;

  /// Creates a values snapshot.
  const GFormValues(Map<String, Object?> values) : _values = values;

  /// Returns an immutable map view of every value.
  Map<String, Object?> toMap() => Map.unmodifiable(_values);

  /// Reads a value as [T], returning `null` when the field is absent or the
  /// stored value is not assignable to [T].
  T? value<T>(String name) {
    final value = _values[name];
    return value is T ? value : null;
  }

  /// Convenience reader for string values.
  String? string(String name) => value<String>(name);
}

/// Validator that can inspect both the field value and the whole form.
typedef GTypedFormValidator<T> = String? Function(T? value, GFormValues values);

/// Parses text input into a typed form value.
typedef GFormValueParser = Object? Function(String text);

/// Controller for a single typed field value.
final class GFormFieldController<T> extends ChangeNotifier {
  /// Stable field name used in [GFormController.values].
  final String name;

  /// Optional validator for this field.
  final GTypedFormValidator<T>? validator;

  T? _value;
  String? _errorText;

  /// Creates a typed field controller.
  GFormFieldController({required this.name, T? initialValue, this.validator})
    : _value = initialValue;

  /// Current typed value.
  T? get value => _value;

  /// Current validation message, if any.
  String? get errorText => _errorText;

  /// Updates the field value.
  void setValue(T? value) {
    if (_value == value) {
      return;
    }
    _value = value;
    notifyListeners();
  }

  String? _validate(GFormValues values) {
    _errorText = validator?.call(_value, values);
    return _errorText;
  }
}

/// Coordinates a Flutter [Form] and named text controllers.
///
/// This is intentionally small: it handles the repetitive form key,
/// validate/save/reset flow, and controller disposal for forms that do not need
/// a larger state-management solution.
final class GFormController extends ChangeNotifier {
  /// The [GlobalKey] attached to the underlying Flutter [Form].
  final GlobalKey<FormState> key;
  final Map<String, GFormFieldController<dynamic>> _fields = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _boundTextControllers = {};
  final Map<String, VoidCallback> _textControllerListeners = {};
  final Map<String, GFormValueParser?> _textValueParsers = {};
  final Set<String> _ownedTextControllerNames = {};
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
    return _textControllers.putIfAbsent(name, () {
      final controller = TextEditingController(text: text);
      _ownedTextControllerNames.add(name);
      bindTextController(name, controller);
      return controller;
    });
  }

  /// Current text of the controller registered under [name].
  String text(String name) => textController(name).text;

  /// Snapshot of every registered field's current text, keyed by name.
  Map<String, String> textValues() {
    return {
      for (final entry in _boundTextControllers.entries)
        entry.key: entry.value.text,
    };
  }

  /// Registers a typed field controller.
  ///
  /// If a field with the same name already exists, it is returned as [T] when
  /// possible. A mismatched type throws a [StateError] to catch accidental
  /// duplicate names early.
  GFormFieldController<T> registerField<T>(GFormFieldController<T> field) {
    final existing = _fields[field.name];
    if (existing != null) {
      if (existing is GFormFieldController<T>) {
        return existing;
      }
      throw StateError(
        'Field "${field.name}" is already registered with another type.',
      );
    }

    _fields[field.name] = field;
    field.addListener(notifyListeners);
    return field;
  }

  /// Creates or returns a typed field controller for [name].
  GFormFieldController<T> field<T>(
    String name, {
    T? initialValue,
    GTypedFormValidator<T>? validator,
  }) {
    return registerField(
      GFormFieldController<T>(
        name: name,
        initialValue: initialValue,
        validator: validator,
      ),
    );
  }

  /// Updates a typed field value.
  void setValue<T>(String name, T? value) {
    field<T>(name).setValue(value);
  }

  /// Reads a typed field value.
  T? value<T>(String name) => values().value<T>(name);

  /// Snapshot of every registered typed value.
  GFormValues values() {
    return GFormValues({
      for (final entry in _fields.entries) entry.key: entry.value.value,
    });
  }

  /// Attaches an existing text controller to a named form field.
  ///
  /// This lets text widgets participate in the typed value API without forcing
  /// callers to let [GFormController] own their controller.
  void bindTextController(
    String name,
    TextEditingController controller, {
    GFormValueParser? parser,
  }) {
    if (_boundTextControllers[name] == controller &&
        _textValueParsers[name] == parser) {
      return;
    }

    final previous = _boundTextControllers[name];
    final previousListener = _textControllerListeners[name];
    if (previous != null && previousListener != null) {
      previous.removeListener(previousListener);
    }

    final fieldController = field<Object?>(
      name,
      initialValue: parser?.call(controller.text) ?? controller.text,
    );
    void listener() {
      fieldController.setValue(
        parser?.call(controller.text) ?? controller.text,
      );
    }

    _boundTextControllers[name] = controller;
    _textValueParsers[name] = parser;
    _textControllerListeners[name] = listener;
    controller.addListener(listener);
    fieldController.setValue(parser?.call(controller.text) ?? controller.text);
  }

  /// Runs every registered validator. Returns `true` if the form is valid.
  bool validate() {
    final formValid = state?.validate() ?? false;
    final formValues = values();
    final typedValid = _fields.values
        .map((field) => field._validate(formValues))
        .every((message) => message == null);
    return formValid && typedValid;
  }

  /// Calls `onSaved` on every field.
  void save() => state?.save();

  /// Resets the form and clears every registered text controller.
  void reset() {
    state?.reset();
    for (final controller in _textControllers.values) {
      controller.clear();
    }
    for (final entry in _fields.entries) {
      if (_boundTextControllers.containsKey(entry.key)) {
        continue;
      }
      entry.value.setValue(null);
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

  /// Validates, saves, and runs [onSubmit] with typed form values.
  Future<bool> submitValues(
    FutureOr<void> Function(GFormValues values) onSubmit, {
    bool resetOnSuccess = false,
  }) async {
    if (_submitting || !validateAndSave()) {
      return false;
    }

    _setSubmitting(true);
    try {
      await onSubmit(values());
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
    for (final entry in _boundTextControllers.entries) {
      final listener = _textControllerListeners[entry.key];
      if (listener != null) {
        entry.value.removeListener(listener);
      }
    }
    for (final entry in _textControllers.entries) {
      if (!_ownedTextControllerNames.contains(entry.key)) {
        continue;
      }
      final controller = entry.value;
      controller.dispose();
    }
    for (final field in _fields.values) {
      field.removeListener(notifyListeners);
      field.dispose();
    }
    _fields.clear();
    _boundTextControllers.clear();
    _textControllerListeners.clear();
    _textValueParsers.clear();
    _ownedTextControllerNames.clear();
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
