# gmana_value_objects — Package Structure

Production-ready, framework-agnostic value objects for Email, Password, Text,
Number, and Money, with configurable validation and sealed error hierarchies.

- Pure Dart — works in CLI apps, Dart servers, and Flutter.
- Value objects are **always valid by construction**.
- `Either`-based smart constructors (`tryParse`) for untrusted input; throwing
  constructors for trusted literals.
- Structural equality (`==` / `hashCode`) on every value object and config.

## File structure

```text
gmana_value_objects/
├── lib/
│   ├── gmana_value_objects.dart                  # Public barrel export
│   └── src/
│       ├── core/
│       │   ├── validation_error.dart             # ValidationError base + code
│       │   ├── value_object.dart                 # Always-valid ValueObject<T>
│       │   ├── value_object_exception.dart       # Thrown by throwing constructors
│       │   └── collection_equality.dart          # Internal set/list equality helpers
│       ├── email/                                # email.dart + errors/config/validator
│       ├── password/                             # password.dart + errors/config/validator
│       ├── text/                                 # text_value.dart + errors/config/validator
│       ├── number/                               # number_value.dart + errors/config/validator
│       ├── money/
│       │   ├── currency.dart                     # Currency enum (ISO metadata)
│       │   ├── money.dart                        # Money value object + arithmetic
│       │   ├── money_errors.dart
│       │   ├── money_validation_config.dart
│       │   └── money_validator.dart              # Either<MoneyError, Money>
│       └── presentation/
│           └── validation_error_messages.dart    # Default English messages + i18n hook
├── example/main.dart
├── test/
├── doc/                                          # Per-type API guides
├── README.md
├── QUICK_START.md
└── CHANGELOG.md
```

## Layers

| Layer        | Responsibility                                                      |
| ------------ | ------------------------------------------------------------------- |
| Validator    | Pure function: input → `Either<Error, primitive>`. No object state. |
| Value object | Always-valid wrapper built from a validated primitive.              |
| Errors       | Sealed hierarchy per type, for exhaustive `switch` handling.        |
| Config       | Immutable, value-equal rules with named presets.                    |
| Presentation | Maps `ValidationError` → display strings (override for i18n).       |

## Usage patterns

### Untrusted input

```dart
final result = Email.tryParse(controller.text); // Either<EmailError, Email>
```

### Trusted literal

```dart
final email = Email('support@example.com'); // throws if invalid
```

### Wrapping in your own failure type

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart' as vo;

vo.Either<MyFailure, vo.Email> parseEmail(String input) {
  return vo.Email.tryParse(input).mapLeft(MyFailure.validation);
}
```

### Money

```dart
// Untrusted text:
MoneyValidator(MoneyValidationConfig.ecommerce()).validate('1,234.56', currency: 'USD');

// Trusted amounts:
final total = Money.fromDecimalString('19.99', Currency.usd) * 2;
```

## Features by type

- **Email** — RFC-style format check, total/local/domain length limits,
  disposable-domain and blocked-domain rules. Normalizes to trimmed lowercase.
- **Password** — min/max length, ASCII-only, complexity scoring, common-password
  and predictable-sequence detection; `lenient()` / `strict()` presets.
- **Text** — trimming, empty/whitespace rules, length bounds, regex pattern,
  allowed characters, blocked words; presets (username, name, short/medium/long).
- **Number** — finite check, min/max, integer-only, negative control,
  decimal-place limits; presets (age, rating, percentage, price, etc.).
- **Money** — exact integer minor units + `Currency`, same-currency arithmetic,
  half-up rounding, lossless allocation, deterministic formatting.

## Testing

Validators are pure, and value objects expose their validated `value` and
structural equality, so assertions are direct:

```dart
test('parses and normalizes', () {
  Email.tryParse('USER@Example.com').fold(
    (_) => fail('should be valid'),
    (email) => expect(email.value, 'user@example.com'),
  );
});

test('equality', () {
  expect(Email('a@b.com'), Email('a@b.com'));
});
```
