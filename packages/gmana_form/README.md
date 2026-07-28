# gmana_form

Production-ready Flutter form building blocks for the Gmana ecosystem.

```dart
import 'package:gmana_form/gmana_form.dart';
```

## What You Get

- One generic text-field surface: `GTextField` + `GTextFieldConfig`.
- Friendly presets for common inputs: text, email, number, password, confirm password, URL, and phone.
- Named fields expose both text values and typed values.
- Typed validation powered by `gmana_validation`.
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

The preset widgets `GEmailField`, `GNumberField`, `GPasswordField`, and
`GConfirmPasswordField` are still exported for discoverability. They delegate to
the same `GTextField` preset constructors.

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
