import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Parses text input into a typed form value.
typedef GFormValueParser = Object? Function(String text);

/// Validator that can inspect both the field value and the whole form.
typedef GTypedFormValidator<T> = String? Function(T? value, GFormValues values);

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
  final Map<String, String? Function(String?)> _textValidators = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, String> _pristineText = {};

  /// Baseline values of typed fields that are not bound to text, used by
  /// [isDirty] and [reset].
  final Map<String, Object?> _pristineValues = {};

  /// Owned controllers, fields, and nodes removed by [unregister]. Their
  /// widget may still hold them until it unmounts, so they are disposed with
  /// this controller rather than at once.
  final List<ChangeNotifier> _retired = [];
  bool _submitting = false;

  /// Creates a controller. Pass an existing [key] to reuse a form key, or
  /// omit it to have one created automatically.
  GFormController({GlobalKey<FormState>? key})
    : key = key ?? GlobalKey<FormState>();

  /// Whether any field currently fails validation.
  bool get hasErrors => errors().isNotEmpty;

  /// Whether any named field differs from its pristine value.
  ///
  /// Covers text fields and typed fields such as checkboxes and dropdowns.
  /// Useful for "discard unsaved changes?" prompts.
  bool get isDirty =>
      _boundTextControllers.keys.any(isFieldDirty) ||
      _fields.keys.any(isFieldDirty);

  /// The current [FormState], or `null` if the form has not been mounted yet.
  FormState? get state => key.currentState;

  /// Whether [submit] is currently in flight.
  bool get submitting => _submitting;

  Iterable<String> get _fieldOrder => {
    ..._fields.keys,
    ..._textValidators.keys,
  };

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
    _pristineText.putIfAbsent(name, () => controller.text);
    controller.addListener(listener);
    fieldController.setValue(parser?.call(controller.text) ?? controller.text);
  }

  /// Records the validator a named text field is using.
  ///
  /// Field widgets call this so the controller can answer [errorOf] and
  /// [focusFirstInvalid] without going through the widget tree. Passing
  /// `null` clears any previously bound validator.
  void bindTextValidator(String name, String? Function(String?)? validator) {
    if (validator == null) {
      _textValidators.remove(name);
      return;
    }
    _textValidators[name] = validator;
  }

  /// Only the text values that changed since the last pristine mark.
  Map<String, String> changedTextValues() => {
    for (final entry in _boundTextControllers.entries)
      if (isFieldDirty(entry.key)) entry.key: entry.value.text,
  };

  /// Clears the text of the field registered under [name].
  void clearText(String name) => setText(name, '');

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
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    for (final retired in _retired) {
      retired.dispose();
    }
    _retired.clear();
    _fields.clear();
    _boundTextControllers.clear();
    _textControllerListeners.clear();
    _textValueParsers.clear();
    _ownedTextControllerNames.clear();
    _textControllers.clear();
    _textValidators.clear();
    _focusNodes.clear();
    _pristineText.clear();
    _pristineValues.clear();
    super.dispose();
  }

  /// The current validation message for [name], or `null` when it passes.
  ///
  /// Unlike [validate] this does not paint error text into the UI, so it is
  /// safe to call from a `build` method or a listener.
  String? errorOf(String name) => _errorOf(name, values());

  /// Every current validation message, keyed by field name.
  ///
  /// Covers the validators this controller knows: typed field validators and
  /// the text validators bound with [bindTextValidator], including those of
  /// fields whose widget is not mounted.
  Map<String, String> errors() {
    final formValues = values();
    final result = <String, String>{};
    for (final name in _fieldOrder) {
      final message = _errorOf(name, formValues);
      if (message != null) result[name] = message;
    }
    return result;
  }

  /// The text validator's message for [name], else the typed validator's.
  ///
  /// Always runs the typed validator, so its [GFormFieldController.errorText]
  /// stays current.
  String? _errorOf(String name, GFormValues formValues) {
    final typedMessage = _fields[name]?._validate(formValues);
    final textValidator = _textValidators[name];
    final textMessage = textValidator?.call(_boundTextControllers[name]?.text);
    return textMessage ?? typedMessage;
  }

  // --- Focus ---

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

  /// Focuses the first field that currently fails validation.
  ///
  /// Returns `false` when everything is valid, or when no invalid field has a
  /// focus node. Fields are visited in registration order, which for fields
  /// built inside a [Form] is top-to-bottom.
  bool focusFirstInvalid() {
    for (final name in _fieldOrder) {
      if (errorOf(name) == null) continue;
      final node = _focusNodes[name];
      if (node != null) {
        node.requestFocus();
        return true;
      }
    }
    return false;
  }

  /// Returns the [FocusNode] registered under [name], creating one if needed.
  ///
  /// Nodes are disposed automatically when this controller is disposed.
  /// Named fields pick their node up from here, so [requestFocus] and
  /// [focusFirstInvalid] work without threading nodes through your widgets.
  FocusNode focusNode(String name) =>
      _focusNodes.putIfAbsent(name, () => FocusNode(debugLabel: name));

  /// Whether [name] differs from the value it was last marked pristine at.
  ///
  /// A text field compares its text; a typed field compares its value with
  /// `==`. Returns `false` for an unknown name.
  bool isFieldDirty(String name) {
    final textController = _boundTextControllers[name];
    if (textController != null) {
      final pristine = _pristineText[name];
      return pristine != null && textController.text != pristine;
    }

    final field = _fields[name];
    return field != null && field.value != _pristineValues[name];
  }

  // --- Errors ---

  /// Treats the current values as the new baseline for [isDirty] and
  /// [reset].
  ///
  /// Call this after a successful save so the form stops reporting unsaved
  /// changes.
  void markPristine() {
    _pristineText
      ..clear()
      ..addAll(textValues());
    for (final entry in _fields.entries) {
      if (_boundTextControllers.containsKey(entry.key)) continue;
      _pristineValues[entry.key] = entry.value.value;
    }
  }

  /// Applies [values] to the matching named fields.
  void patchText(Map<String, String> values) {
    values.forEach(setText);
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
    _pristineValues[field.name] = field.value;
    field.addListener(notifyListeners);
    return field;
  }

  // --- Text mutation ---

  /// Moves focus to the field registered under [name].
  void requestFocus(String name) => focusNode(name).requestFocus();

  /// Resets the form to its pristine baseline.
  ///
  /// Text fields go back to the text they were registered with, or that they
  /// had at the last [markPristine]; typed fields go back to their
  /// registered or last-pristine value. Error text is cleared. Afterwards
  /// [isDirty] is `false`.
  void reset() {
    state?.reset();
    for (final entry in _boundTextControllers.entries) {
      final pristine = _pristineText[entry.key] ?? '';
      if (entry.value.text == pristine) continue;
      entry.value.value = TextEditingValue(
        text: pristine,
        selection: TextSelection.collapsed(offset: pristine.length),
      );
    }
    for (final entry in _fields.entries) {
      entry.value._errorText = null;
      if (_boundTextControllers.containsKey(entry.key)) continue;
      entry.value.setValue(_pristineValues[entry.key]);
    }
  }

  /// Removes the field registered under [name] from this controller.
  ///
  /// Fields stay registered when their widget leaves the tree, so a
  /// multi-step form keeps the values and validators of steps that are not
  /// shown. Call this when a field is gone for good, such as a conditional
  /// field that was hidden, so it stops appearing in [values], [textValues],
  /// [errors], [isDirty], and [validate].
  ///
  /// Call it once the field's widget has left the tree: a field widget that
  /// builds again registers its name again. Controllers and focus nodes this
  /// controller created for [name] are disposed along with this controller,
  /// since the widget may hold them until it unmounts. Does nothing when
  /// [name] is not registered.
  void unregister(String name) {
    var removed = false;

    final bound = _boundTextControllers.remove(name);
    final listener = _textControllerListeners.remove(name);
    if (bound != null) {
      removed = true;
      if (listener != null) bound.removeListener(listener);
    }
    _textValueParsers.remove(name);
    _pristineText.remove(name);

    final owned = _textControllers.remove(name);
    if (owned != null && _ownedTextControllerNames.remove(name)) {
      _retired.add(owned);
    }

    if (_textValidators.remove(name) != null) removed = true;

    final field = _fields.remove(name);
    _pristineValues.remove(name);
    if (field != null) {
      removed = true;
      field.removeListener(notifyListeners);
      _retired.add(field);
    }

    final node = _focusNodes.remove(name);
    if (node != null) _retired.add(node);

    if (removed) notifyListeners();
  }

  /// Calls `onSaved` on every field.
  void save() => state?.save();

  // --- Dirty tracking ---

  /// Replaces the text of the field registered under [name] and parks the
  /// caret at the end.
  ///
  /// Assigning `controller.text` directly resets the caret to offset 0, which
  /// makes the field jump if the user keeps typing.
  void setText(String name, String value) {
    final controller = _boundTextControllers[name] ?? textController(name);
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  /// Updates a typed field value.
  void setValue<T>(String name, T? value) {
    field<T>(name).setValue(value);
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

  /// Current text of the controller registered under [name].
  String text(String name) => textController(name).text;

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

  /// Snapshot of every registered field's current text, keyed by name.
  Map<String, String> textValues() {
    return {
      for (final entry in _boundTextControllers.entries)
        entry.key: entry.value.text,
    };
  }

  /// Drops focus from every field this controller owns.
  void unfocus() {
    for (final node in _focusNodes.values) {
      if (node.hasFocus) node.unfocus();
    }
  }

  /// Runs every validator. Returns `true` if the form is valid.
  ///
  /// Validates the mounted [Form], which paints error text into its fields,
  /// and every validator [errors] covers, including bound text validators of
  /// fields that are not mounted. So a `true` result means [errors] is empty.
  /// Without a mounted form only the controller's own validators run.
  bool validate() {
    final formValid = state?.validate() ?? true;
    return errors().isEmpty && formValid;
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

  /// Reads a typed field value.
  T? value<T>(String name) => values().value<T>(name);

  /// Snapshot of every registered typed value.
  GFormValues values() {
    return GFormValues({
      for (final entry in _fields.entries) entry.key: entry.value.value,
    });
  }

  void _setSubmitting(bool value) {
    if (_submitting == value) {
      return;
    }
    _submitting = value;
    notifyListeners();
  }
}

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

  /// Current validation message, if any.
  String? get errorText => _errorText;

  /// Current typed value.
  T? get value => _value;

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

/// Snapshot of typed form values keyed by field name.
final class GFormValues {
  final Map<String, Object?> _values;

  /// Creates a values snapshot.
  const GFormValues(Map<String, Object?> values) : _values = values;

  /// Convenience reader for string values.
  String? string(String name) => value<String>(name);

  /// Returns an immutable map view of every value.
  Map<String, Object?> toMap() => Map.unmodifiable(_values);

  /// Reads a value as [T], returning `null` when the field is absent or the
  /// stored value is not assignable to [T].
  T? value<T>(String name) {
    final value = _values[name];
    return value is T ? value : null;
  }
}
