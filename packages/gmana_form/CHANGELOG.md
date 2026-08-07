## Unreleased

- Breaking: replaced `GFieldConfig` with `GTextFieldConfig`.
- Breaking: renamed field constructor labels from `labelText`/`hintText` to
  `label`/`hint`.
- Breaking: renamed field-level custom validation from `validatorOverride` to
  `validator`.
- Added `GTextField` preset constructors for text, email, number, password, and
  confirm-password fields.
- Added `GSubmitButton` with custom child support and a text convenience
  factory.
- Added `GFormController` and `GForm` for simpler form lifecycle, validation,
  save, reset, and named text-controller management.
- Added `GFormController.submit` with loading state and duplicate-submit
  protection.
- Added `GFormSubmitButton` for controller-aware async submit flows.
- Added named field binding through `GTextFieldConfig.name` and preset `name`
  parameters. Fields inside `GForm` can now resolve their controller
  automatically.
- Added `passwordName` to confirm-password fields so named forms can validate
  password confirmation without manually requesting the password controller.
- Added optional controller support via `initialValue` for simpler forms.
- Added autofill, obscure-text, autocorrect, suggestions, prefix, suffix, and
  suffix-icon configuration to `GTextFieldConfig`.
- Removed unused `InputFormatterProvider`.
- Simplified field widgets to use `StatelessWidget` directly instead of a package-specific base class.
- Added common `TextFormField` passthrough options to the named field widgets.
- Added `GValidators` (`required`, `minLength`, `maxLength`, `pattern`,
  `matches`, `oneOf`, `numeric`, `range`, `satisfies`) and `combineValidators`
  for layering rules. Only `required` objects to an empty value, so the rest
  compose onto optional fields.
- Added non-text field widgets that participate in `Form.validate` and, when
  named, report into `GFormController.values`: `GCheckboxField`,
  `GSwitchField`, `GDropdownField<T>` (plus `GDropdownField.fromValues`), and
  `GDateField` (with `formatIsoDate` as the dependency-free default format).
- Added `GTextField.multiline` for notes and descriptions — every other preset
  pins `maxLines: 1`.
- Added focus management to `GFormController`: `focusNode`, `requestFocus`,
  `unfocus`, and `focusFirstInvalid`. Named text fields now adopt the
  controller's focus node automatically, and the nodes are disposed with the
  controller.
- Added `GFormController.errorOf`, `errors`, and `hasErrors`, which report
  validation messages without painting error text into the UI. Named text
  fields register their validator via the new `bindTextValidator`.
- Added `GFormController.setText`, `patchText`, and `clearText`. `setText`
  parks the caret at the end, which assigning `controller.text` does not.
- Added dirty tracking to `GFormController`: `isDirty`, `isFieldDirty`,
  `changedTextValues`, and `markPristine`.
- Added `autofocus`, `onTap`, and `onEditingComplete` to `GTextFieldConfig`.
- Changed: `GFormController.reset` now restores non-text fields to the value
  they were registered with instead of setting them to `null`, matching
  `FormState.reset`. Text fields still clear.

## 0.0.1

- Extracted form widgets, fields, and validators from `gmana_flutter`.
