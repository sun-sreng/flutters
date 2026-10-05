## Unreleased

### Removed

- **Breaking:** removed the deprecated `GElevatedButton` (use
  `GSubmitButton.text`) and the `GTextField` alias (use `GTextFormField`).

### Added

- `GTextFormField` preset constructors for text, email, number, password, and
  confirm-password fields, plus `GTextFormField.multiline` for notes and
  descriptions — every other preset pins `maxLines: 1`.
- `GSubmitButton` with custom child support and a text convenience factory.
- `GFormController` and `GForm` for simpler form lifecycle, validation, save,
  reset, and named text-controller management.
- `GFormController.submit` with loading state and duplicate-submit protection.
- `GFormSubmitButton` for controller-aware async submit flows.
- Named field binding through `GTextFieldConfig.name` and preset `name`
  parameters. Fields inside `GForm` can now resolve their controller
  automatically.
- `passwordName` on confirm-password fields so named forms can validate
  password confirmation without manually requesting the password controller.
- Optional controller support via `initialValue` for simpler forms.
- Autofill, obscure-text, autocorrect, suggestions, prefix, suffix, and
  suffix-icon configuration on `GTextFieldConfig`, and `autofocus`, `onTap`,
  and `onEditingComplete`.
- Common `TextFormField` passthrough options on the named field widgets.
- `GValidators` (`required`, `minLength`, `maxLength`, `pattern`, `matches`,
  `oneOf`, `numeric`, `range`, `satisfies`) and `combineValidators` for
  layering rules. Only `required` objects to an empty value, so the rest
  compose onto optional fields.
- Non-text field widgets that participate in `Form.validate` and, when named,
  report into `GFormController.values`: `GCheckboxField`, `GSwitchField`,
  `GDropdownField<T>` (plus `GDropdownField.fromValues`), and `GDateField`
  (with `formatIsoDate` as the dependency-free default format).
- Focus management on `GFormController`: `focusNode`, `requestFocus`,
  `unfocus`, and `focusFirstInvalid`. Named text fields now adopt the
  controller's focus node automatically, and the nodes are disposed with the
  controller.
- `GFormController.errorOf`, `errors`, and `hasErrors`, which report
  validation messages without painting error text into the UI. Named text
  fields register their validator via the new `bindTextValidator`.
- `GFormController.setText`, `patchText`, and `clearText`. `setText` parks the
  caret at the end, which assigning `controller.text` does not.
- Dirty tracking on `GFormController`: `isDirty`, `isFieldDirty`,
  `changedTextValues`, and `markPristine`.

### Changed

- **Source files moved under `lib/src`.** Import `package:gmana_form/gmana_form.dart`.
  The old library paths (`package:gmana_form/fields/text_field.dart` and the rest) still resolve but are deprecated.
- **Breaking:** replaced `GFieldConfig` with `GTextFieldConfig`.
- **Breaking:** renamed field constructor labels from `labelText`/`hintText`
  to `label`/`hint`.
- **Breaking:** renamed field-level custom validation from `validatorOverride`
  to `validator`.
- Renamed the form field `GTextField` to `GTextFormField`, the name it already
  had as an alias. `GTextField` remains as a deprecated alias; it clashed with
  the plain-input `GTextField` in `gmana_flutter`.
- `GFormController.reset` now restores non-text fields to the value they were
  registered with instead of setting them to `null`, matching
  `FormState.reset`. Text fields still clear.
- Field widgets use `StatelessWidget` directly instead of a package-specific
  base class.

### Deprecated

- `GElevatedButton`; use `GSubmitButton.text`.

### Removed

- The unused `InputFormatterProvider`.
- The unused `gmana_functional` dependency.

## 0.0.1

- Extracted form widgets, fields, and validators from `gmana_flutter`.
