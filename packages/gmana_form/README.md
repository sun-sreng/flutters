# gmana_form

Production-ready Flutter form building blocks for the Gmana ecosystem.

```dart
import 'package:gmana_form/gmana_form.dart';
```

## What You Get

- One generic text-field surface: `GTextField` + `GTextFieldConfig`.
- Friendly presets for common inputs: text, multiline, email, number, password, confirm password, URL, and phone.
- Non-text fields that validate too: checkbox, switch, dropdown, and date.
- Named fields expose both text values and typed values.
- Typed validation powered by `gmana_validation`, plus composable `GValidators`.
- Focus management, dirty tracking, and UI-free error reporting on the controller.
- A loading submit button that accepts either plain text or any custom child.

## Quick Start

```dart
final form = GFormController();

GForm(
  controller: form,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: Column(
    children: [
      GTextField.email(name: 'email'),
      const SizedBox(height: 12),
      GTextField.password(
        name: 'password',
        validationConfig: PasswordValidationConfig.strong(),
      ),
      const SizedBox(height: 20),
      GSubmitButton.text(
        label: 'Sign in',
        loading: isSubmitting,
        onPressed: () {
          if (form.validateAndSave()) {
            submit(form.textValues());
          }
        },
      ),
    ],
  ),
)
```

Or let the package handle validate/save/loading:

```dart
GFormSubmitButton.text(
  label: 'Sign in',
  onSubmit: (values) async {
    await auth.signIn(
      email: values['email']!,
      password: values['password']!,
    );
  },
)
```

Dispose the controller from your `State`:

```dart
@override
void dispose() {
  form.dispose();
  super.dispose();
}
```

## Form Controller

`GFormController` owns a `GlobalKey<FormState>` and lazily creates named text
controllers.

```dart
final form = GFormController();

GForm(
  controller: form,
  child: GTextField.email(name: 'email'),
);

if (form.validateAndSave()) {
  await repository.save(form.textValues());
}

final email = form.values().string('email');

form.reset();
form.dispose();
```

You can still request a controller directly when another widget needs it:

```dart
final password = form.textController('password');

GTextField.password(controller: password)
```

`textValues()` keeps the original `Map<String, String>` behavior. Use
`values()` when you want parsed values:

```dart
final values = form.values();

final email = values.string('email');
final age = values.value<int>('age');
```

For typed submissions, call `submitValues`:

```dart
await form.submitValues((values) async {
  await repository.saveProfile(
    email: values.string('email')!,
    age: values.value<int>('age'),
  );
});
```

### Reading and writing text

```dart
form.setText('email', 'ada@example.com');   // caret parks at the end
form.patchText({'first': 'Ada', 'last': 'Lovelace'});
form.clearText('note');
```

### Errors without repainting

`validate()` paints error text into the UI. When you only want to *know* —
from a `build` method, a listener, or a "can I enable submit?" check — use:

```dart
form.errorOf('email');   // String? for one field
form.errors();           // {'email': 'Enter a valid email', ...}
form.hasErrors;          // bool
```

Named `GTextField`s register their validator automatically, so this works
without wiring anything up.

### Focus

Named fields adopt the controller's focus node, and the nodes are disposed
along with the controller:

```dart
form.requestFocus('password');
form.unfocus();

// Jump the user to the first problem instead of leaving them to hunt for it
if (!form.validate()) form.focusFirstInvalid();
```

### Unsaved changes

```dart
form.isDirty;                 // any field differs from its baseline
form.isFieldDirty('email');
form.changedTextValues();     // only what moved

await repository.save(form.textValues());
form.markPristine();          // new baseline after a successful save
```

## Fields

Use `GTextFieldConfig` for anything custom:

```dart
GTextField(
  config: GTextFieldConfig(
    controller: notesController,
    label: 'Notes',
    hint: 'Optional',
    minLines: 3,
    maxLines: 6,
    textCapitalization: TextCapitalization.sentences,
    prefixIcon: Icons.notes,
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Required' : null,
  ),
)
```

Use preset constructors when the intent is common:

```dart
GTextField.text(
  name: 'name',
  label: 'Full name',
  validationConfig: const TextValidationConfig(minLength: 2),
)

GTextField.email(
  name: 'email',
  validationConfig: EmailValidationConfig.strict(),
)

GTextField.number(
  name: 'age',
  label: 'Age',
  validationConfig: NumberValidationConfig.positiveInteger(min: 13, max: 120),
)

// Integer number fields expose `int?`; decimal configs expose `double?`.
final age = form.value<int>('age');

GTextField.number(
  name: 'price',
  valueParser: (text) => num.tryParse(text),
)

GTextField.password(
  name: 'password',
  textInputAction: TextInputAction.next,
)

GTextField.confirmPassword(
  name: 'confirmPassword',
  passwordName: 'password',
)
```

Multi-line text has its own preset, because every other one pins
`maxLines: 1`:

```dart
GTextField.multiline(
  name: 'bio',
  label: 'About you',
  minLines: 3,
  maxLines: 8,
)
```

The preset widgets `GEmailField`, `GNumberField`, `GPasswordField`, and
`GConfirmPasswordField` are still exported for discoverability. They delegate to
the same `GTextField` preset constructors.

## Non-text Fields

These are real `FormField`s, so `Form.validate()` covers them, and a `name`
puts their typed value into `form.values()`.

### Checkbox and switch

A bare `Checkbox` cannot express "you must accept the terms" — these can:

```dart
GCheckboxField(
  name: 'terms',
  title: const Text('I accept the terms'),
  validator: (value) => value == true ? null : 'You must accept the terms',
)

GSwitchField(
  name: 'notifications',
  initialValue: true,
  title: const Text('Email notifications'),
)

final accepted = form.value<bool>('terms');
```

### Dropdown

```dart
GDropdownField<String>(
  name: 'country',
  label: 'Country',
  items: const [
    DropdownMenuItem(value: 'kh', child: Text('Cambodia')),
    DropdownMenuItem(value: 'us', child: Text('United States')),
  ],
  validator: (value) => value == null ? 'Pick a country' : null,
)
```

Skip the `DropdownMenuItem` boilerplate when you already have the values:

```dart
GDropdownField.fromValues<Role>(
  name: 'role',
  values: Role.values,
  labelBuilder: (role) => role.name,
)
```

### Date

The value is a real `DateTime`, so validation and `form.values()` work on
dates rather than on strings. Formatting defaults to `yyyy-MM-dd` so the
package stays free of an `intl` dependency:

```dart
GDateField(
  name: 'birthday',
  label: 'Date of birth',
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  clearable: true,
  format: (date) => '${date.day}/${date.month}/${date.year}',
  validator: (value) => value == null ? 'Pick a date' : null,
)

final birthday = form.value<DateTime>('birthday');
```

## Validators

`GValidators` covers the rules that do not warrant a typed validator, and
`combineValidators` layers them:

```dart
GTextField.text(
  name: 'username',
  validator: combineValidators([
    GValidators.required(),
    GValidators.minLength(3),
    GValidators.maxLength(20),
    GValidators.pattern(RegExp(r'^[a-z0-9_]+$'),
        message: 'Lowercase letters, digits, and underscores only'),
  ]),
)
```

Available rules:

| Validator | Fails when |
| --- | --- |
| `required()` | null, empty, or whitespace-only |
| `minLength(n)` / `maxLength(n)` | outside the length bounds |
| `pattern(regExp, message:)` | the expression does not match |
| `matches(() => other.text)` | the value differs from the callback's result |
| `oneOf([...])` | not in the allowed set |
| `numeric()` | does not parse as a number |
| `range(min:, max:)` | numeric value outside the bounds |
| `satisfies(predicate, message:)` | the predicate returns false |

**Only `required` objects to an empty value.** Every other rule lets an empty
input through, so they layer onto optional fields without silently making them
mandatory. Put `required()` first when you do want it enforced.

`matches` takes a callback rather than a value so it reads the *current*
contents of the other field:

```dart
GValidators.matches(() => passwordController.text)
```

## Advanced Customization

Every preset accepts a `configure` hook so teams can keep the built-in defaults
and still modify config that is not exposed as a top-level constructor argument:

```dart
GTextField.email(
  controller: email,
  configure: (config) => config.copyWith(
    suffixIcon: IconButton(
      icon: const Icon(Icons.clear),
      onPressed: email.clear,
    ),
  ),
)
```

For custom validation, pass `validator`. It runs after the package validator:

```dart
GTextField.email(
  controller: email,
  validator: (value) {
    final domainAllowed = value?.endsWith('@company.com') ?? false;
    return domainAllowed ? null : 'Use your company email';
  },
)
```

## Submit Button

Use `GFormSubmitButton` inside a `GForm` when you want validation, saving,
loading state, and duplicate-submit protection handled for you:

```dart
GFormSubmitButton.text(
  label: 'Create account',
  onSubmit: (values) async {
    await repository.createAccount(values);
  },
)
```

For manual loading state, use `GSubmitButton`:

```dart
GSubmitButton.text(
  label: 'Create account',
  loading: isSubmitting,
  onPressed: isSubmitting ? null : submit,
)
```

For richer button content:

```dart
GSubmitButton(
  loading: isUploading,
  onPressed: upload,
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.cloud_upload),
      SizedBox(width: 8),
      Text('Upload'),
    ],
  ),
)
```

`GElevatedButton` remains available as a compatibility wrapper.

## Validator Adapter

`asFormValidator` adapts any `gmana_validation` validator to Flutter's
`FormField.validator` signature:

```dart
final validator = asFormValidator(
  validate: const EmailValidator().validate,
  resolve: resolveEmailValidationIssue,
);

TextFormField(validator: validator)
```

## Breaking Changes In This Refactor

- `GFieldConfig` has been replaced by `GTextFieldConfig`.
- Field labels use `label` and hints use `hint`.
- `validatorOverride` has been renamed to `validator`.
- `GTextField.text`, `.email`, `.number`, `.password`, and `.confirmPassword`
  are now the preferred high-level API.
- `GSubmitButton` is the preferred submit button API.
