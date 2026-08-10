# gmana_validation

Pure Dart typed validators for common text, numeric, contact, identifier,
network, and date/time inputs. Returns `Either`-based results — no exceptions
thrown for ordinary validation failures, and no stringly-typed errors.

```dart
import 'package:gmana_validation/gmana_validation.dart';
```

---

## Table of contents

- [Core types](#core-types)
- [Validation extensions](#validation-extensions)
- [Email](#email)
- [Password](#password)
- [Text](#text)
- [Number](#number)
- [URL](#url)
- [Phone](#phone)
- [Identifier](#identifier)
- [Network](#network)
- [Date](#date)
- [Custom message resolvers](#custom-message-resolvers)
- [Using with Flutter forms](#using-with-flutter-forms)


---

## Core types

Every validator returns a `ValidationResult`, which is an alias for `Either<TIssue, TValue>` from `gmana_functional`.

```dart
// Aliases
typedef ValidationResult<TIssue extends ValidationIssue, TValue> =
    Either<TIssue, TValue>;
typedef ValidationMessageResolver<TIssue extends ValidationIssue> =
    String Function(TIssue issue);
```

- **`Right(value)`** — validation passed; contains the normalized/parsed value.
- **`Left(issue)`** — validation failed; contains a typed, sealed issue object.

All issue types are `sealed`, so `switch` expressions are exhaustively checked by the compiler.

```dart
final result = EmailValidator().validate('user@example.com');

// fold — handles both sides
result.fold(
  (issue) => print('Error: ${resolveEmailValidationIssue(issue)}'),
  (email) => print('Normalized: $email'),  // 'user@example.com'
);

// switch on the sealed issue for granular handling
result.fold(
  (issue) => switch (issue) {
    EmailEmptyIssue()          => 'Please enter your email',
    EmailInvalidFormatIssue()  => 'That doesn\'t look like an email',
    EmailTooLongIssue(:final maxLength) => 'Max $maxLength characters',
    EmailBlockedDomainIssue()  => 'That domain isn\'t allowed',
    EmailDisposableDomainIssue() => 'Disposable emails aren\'t accepted',
    _                          => resolveEmailValidationIssue(issue),
  },
  (email) => saveEmail(email),
);
```

---

## Validation extensions

The named extensions `GmanaValidationStringX` and
`GmanaValidationResultX` provide concise entry points without changing the
validators or their typed `Either` results.

### Validate strings directly

Every shortcut accepts its validator's config as an optional positional
argument. Omitting it uses the same default config as constructing the
corresponding validator directly.

```dart
final email = ' User@Example.COM '.validateEmail();
// Right('user@example.com')

final port = '443'.validateNetwork(
  const NetworkValidationConfig(requiredType: NetworkAddressType.port),
);

final uuid = input.validateIdentifier(
  const IdentifierValidationConfig(requiredType: IdentifierType.uuid),
);
```

| Method                         | Success value | Behavior |
| ------------------------------ | ------------- | -------- |
| `validateEmail([config])`      | `String`      | Returns the trimmed, lowercased email |
| `validatePassword([config])`   | `String`      | Returns the original password |
| `validateText([config])`       | `String`      | Applies the configured trimming and text rules |
| `validateNumber([config])`     | `num`         | Parses and returns the numeric value |
| `validateUrl([config])`        | `Uri`         | Parses and returns the URL |
| `validatePhone([config])`      | `String`      | Returns the normalized phone number |
| `validateIdentifier([config])` | `String`      | Applies the selected `IdentifierType` |
| `validateNetwork([config])`    | `String`      | Applies the selected `NetworkAddressType` |
| `validateDate([config])`       | `DateTime?`   | Parses a date, or returns `null` for a valid empty/time-only input |

These methods delegate to the existing validators, preserving their
normalization, validation order, and domain-specific issue types. The default
`IdentifierType.any` and `NetworkAddressType.any` configurations only require
a non-empty input; select a concrete type when a particular format must be
checked.

### Inspect validation results

```dart
final result = ''.validateEmail();

print(result.isValid);     // false
print(result.isInvalid);   // true
print(result.issueOrNull?.code); // 'email.empty'
print(result.valueOrNull);       // null
print(result.messageOrNull(resolveEmailValidationIssue));
// 'Please enter an email address'
```

| Member                    | Semantics |
| ------------------------- | --------- |
| `isValid`                 | `true` for `Right`, including `Right(null)` |
| `isInvalid`               | `true` for `Left` |
| `issueOrNull`             | Returns the typed issue for `Left`; otherwise `null` |
| `valueOrNull`             | Returns the success value for `Right`; otherwise `null` |
| `messageOrNull(resolver)` | Lazily resolves the issue for `Left`; otherwise returns `null` |

The inspection members do not alter the result. A successful nullable value,
such as an allowed empty date or a time-only validation, makes `valueOrNull`
indistinguishable from an invalid result; use `isValid` or `isInvalid` when
that distinction matters. `messageOrNull` calls its resolver only for an
invalid result, and an exception thrown by the resolver reaches the caller.

---

## Email

`EmailValidator` trims whitespace, checks format, enforces length limits, and optionally rejects blocked or disposable domains. On success it returns the **normalized** email (`local@domain` lowercased).

### Quick start

```dart
const validator = EmailValidator();

validator.validate('User@Example.COM').fold(
  (issue) => print(resolveEmailValidationIssue(issue)),
  (email) => print(email), // 'user@example.com'
);

validator.validate('').fold(
  (issue) => print(issue.code), // 'email.empty'
  (_) => {},
);
```

### `EmailValidationConfig`

```dart
// Default — permissive, no domain policies
const EmailValidationConfig()

// Strict preset — rejects disposable domains using the built-in list
EmailValidationConfig.strict()

// Custom — block competitor domains and tighten length limits
EmailValidationConfig(
  maxLength: 100,
  blockedDomains: {'competitor.com', 'spam.org'},
  rejectDisposable: true,
  matchSubdomains: true,    // 'mail.competitor.com' also blocked
)
```

| Parameter            | Type          | Default       |
| -------------------- | ------------- | ------------- |
| `maxLength`          | `int`         | `254`         |
| `maxLocalPartLength` | `int`         | `64`          |
| `maxDomainLength`    | `int`         | `253`         |
| `blockedDomains`     | `Set<String>` | `{}`          |
| `rejectDisposable`   | `bool`        | `false`       |
| `disposableDomains`  | `Set<String>` | built-in list |
| `matchSubdomains`    | `bool`        | `true`        |

### Issue types

| Type                         | Code                     | Carries                      |
| ---------------------------- | ------------------------ | ---------------------------- |
| `EmailEmptyIssue`            | `email.empty`            | —                            |
| `EmailInvalidFormatIssue`    | `email.invalidFormat`    | —                            |
| `EmailTooLongIssue`          | `email.tooLong`          | `currentLength`, `maxLength` |
| `EmailLocalPartTooLongIssue` | `email.localPartTooLong` | `currentLength`, `maxLength` |
| `EmailDomainTooLongIssue`    | `email.domainTooLong`    | `currentLength`, `maxLength` |
| `EmailBlockedDomainIssue`    | `email.blockedDomain`    | `domain`                     |
| `EmailDisposableDomainIssue` | `email.disposableDomain` | `domain`                     |

---

## Password

`PasswordValidator` enforces length, character requirements, and pattern-based rejection (common passwords, repeated characters, sequential runs). Returns the original password string on success.

### Quick start

```dart
// Default — strong policy (8+ chars, upper, lower, digit, special)
const validator = PasswordValidator();

validator.validate('MySecure1!').fold(
  (issue) => print(resolvePasswordValidationIssue(issue)),
  (pass)  => print('Valid'),
);
```

### `PasswordValidationConfig`

```dart
// Strong preset (default)
PasswordValidationConfig.strong()
const PasswordValidationConfig()  // equivalent

// Lenient — only minimum length enforced
PasswordValidationConfig.lenient()  // minLength: 4, all checks off

// Custom
PasswordValidationConfig(
  minLength: 12,
  maxLength: 256,
  requireUppercase: true,
  requireLowercase: true,
  requireDigit: true,
  requireSpecialCharacter: false,
  rejectCommonPasswords: true,
  rejectRepeatedCharacters: true,
  rejectSequentialPatterns: true,
  minSequentialRun: 5,                          // e.g. 'abcde' fails
  commonPasswords: {'hunter2', 'letmein123'},   // replace the exact block list
  commonPrefixes: ['password', 'qwerty'],       // replace the prefix block list
)
```

Supplying `commonPasswords` or `commonPrefixes` replaces that built-in list;
include any defaults you still want to reject.

| Parameter                  | Type   | Default |
| -------------------------- | ------ | ------- |
| `minLength`                | `int`  | `8`     |
| `maxLength`                | `int`  | `128`   |
| `requireUppercase`         | `bool` | `true`  |
| `requireLowercase`         | `bool` | `true`  |
| `requireDigit`             | `bool` | `true`  |
| `requireSpecialCharacter`  | `bool` | `true`  |
| `rejectCommonPasswords`    | `bool` | `true`  |
| `rejectRepeatedCharacters` | `bool` | `true`  |
| `rejectSequentialPatterns` | `bool` | `true`  |
| `minSequentialRun`         | `int`  | `4`     |

### Issue types

| Type                                   | Code                                | Carries                      |
| -------------------------------------- | ----------------------------------- | ---------------------------- |
| `PasswordEmptyIssue`                   | `password.empty`                    | —                            |
| `PasswordTooShortIssue`                | `password.tooShort`                 | `currentLength`, `minLength` |
| `PasswordTooLongIssue`                 | `password.tooLong`                  | `currentLength`, `maxLength` |
| `PasswordMissingUppercaseIssue`        | `password.missingUppercase`         | —                            |
| `PasswordMissingLowercaseIssue`        | `password.missingLowercase`         | —                            |
| `PasswordMissingDigitIssue`            | `password.missingDigit`             | —                            |
| `PasswordMissingSpecialCharacterIssue` | `password.missingSpecialCharacter`  | —                            |
| `PasswordTooCommonIssue`               | `password.tooCommon`                | —                            |
| `PasswordRepeatedCharacterIssue`       | `password.repeatedCharacterPattern` | —                            |
| `PasswordSequentialPatternIssue`       | `password.sequentialPattern`        | —                            |

### `PasswordStrength` — live UI feedback

Use `PasswordStrength` to drive a strength meter as the user types, independently of the validator.

```dart
final strength = PasswordStrength.of('MyPass1');
// or against a custom config:
final strength = PasswordStrength.fromConfig('MyPass1', config);

strength.score           // 0–5
strength.isStrong        // true when all five criteria are met
strength.hasMinLength    // true / false
strength.hasUppercase
strength.hasLowercase
strength.hasDigit
strength.hasSpecial
strength.unmetRequirements // ['One special character']
```

```dart
// Strength indicator bar
LinearProgressIndicator(
  value: strength.score / 5,
  color: switch (strength.score) {
    <= 2 => Colors.red,
    <= 3 => Colors.orange,
    _    => Colors.green,
  },
)
```

### Static character helpers

```dart
PasswordValidator.hasUppercase('Hello1!')    // true
PasswordValidator.hasLowercase('Hello1!')    // true
PasswordValidator.hasDigit('Hello1!')        // true
PasswordValidator.hasSpecialCharacter('Hello1!') // true
PasswordValidator.hasOnlyRepeatedCharacters('aaaa') // true
PasswordValidator.hasSequentialRun('abcd', minRun: 4) // true
```

---

## Text

`TextValidator` handles general-purpose text fields: required vs optional, length limits, regex patterns, character allowlists, and word blocklists. Returns the (optionally trimmed) string on success.

### Quick start

```dart
// Optional text — accepts empty input by default
TextValidator().validate('hello').fold(
  (issue) => print(resolveTextValidationIssue(issue)),
  (text)  => print(text),
);
```

### `TextValidationConfig`

```dart
// Required preset — rejects empty and whitespace-only, trims before returning
TextValidationConfig.required()

TextValidationConfig.required(
  minLength: 2,
  maxLength: 50,
)

// Full control
TextValidationConfig(
  allowEmpty: false,
  allowOnlyWhitespace: false,
  trimWhitespace: true,
  minLength: 10,
  maxLength: 500,
  pattern: RegExp(r'^[a-zA-Z\s]+$'),          // letters and spaces only
  allowedCharacters: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ',
  blacklistedWords: {'spam', 'scam'},
  wholeWordBlacklist: true,  // 'scammer' passes; 'scam' fails
)
```

| Parameter             | Type          | Default              |
| --------------------- | ------------- | -------------------- |
| `allowEmpty`          | `bool`        | `true`               |
| `allowOnlyWhitespace` | `bool`        | `true`               |
| `trimWhitespace`      | `bool`        | `false`              |
| `minLength`           | `int?`        | `null`               |
| `maxLength`           | `int?`        | `null`               |
| `pattern`             | `RegExp?`     | `null`               |
| `allowedCharacters`   | `String?`     | `null` (all allowed) |
| `blacklistedWords`    | `Set<String>` | `{}`                 |
| `wholeWordBlacklist`  | `bool`        | `true`               |

### Issue types

| Type                           | Code                     | Carries                      |
| ------------------------------ | ------------------------ | ---------------------------- |
| `TextEmptyIssue`               | `text.empty`             | —                            |
| `TextOnlyWhitespaceIssue`      | `text.onlyWhitespace`    | —                            |
| `TextTooShortIssue`            | `text.tooShort`          | `currentLength`, `minLength` |
| `TextTooLongIssue`             | `text.tooLong`           | `currentLength`, `maxLength` |
| `TextInvalidPatternIssue`      | `text.invalidPattern`    | —                            |
| `TextInvalidCharactersIssue`   | `text.invalidCharacters` | `invalidCharacters`          |
| `TextContainsBlacklistedIssue` | `text.blacklistedWords`  | `foundWords`                 |

---

## Number

`NumberValidator` parses a string to `num`, then enforces sign, integer, range, and decimal-place constraints. Returns the parsed `num` on success.

### Quick start

```dart
const validator = NumberValidator();

validator.validate('42').fold(
  (issue) => print(resolveNumberValidationIssue(issue)),
  (n)     => print(n),  // 42
);
```

### `NumberValidationConfig`

```dart
// Positive integer preset
NumberValidationConfig.positiveInteger()
NumberValidationConfig.positiveInteger(min: 1, max: 100)

// Custom
NumberValidationConfig(
  min: 0,
  max: 9999.99,
  allowNegative: false,
  integerOnly: false,
  maxDecimalPlaces: 2,
)
```

| Parameter          | Type   | Default |
| ------------------ | ------ | ------- |
| `min`              | `num?` | `null`  |
| `max`              | `num?` | `null`  |
| `allowNegative`    | `bool` | `true`  |
| `integerOnly`      | `bool` | `false` |
| `maxDecimalPlaces` | `int?` | `null`  |

### Issue types

| Type                               | Code                           | Carries                      |
| ---------------------------------- | ------------------------------ | ---------------------------- |
| `NumberEmptyIssue`                 | `number.empty`                 | —                            |
| `NumberInvalidFormatIssue`         | `number.invalidFormat`         | —                            |
| `NumberNegativeNotAllowedIssue`    | `number.negativeNotAllowed`    | `currentValue`               |
| `NumberNotIntegerIssue`            | `number.notInteger`            | `currentValue`               |
| `NumberTooSmallIssue`              | `number.tooSmall`              | `currentValue`, `minValue`   |
| `NumberTooLargeIssue`              | `number.tooLarge`              | `currentValue`, `maxValue`   |
| `NumberDecimalPlacesExceededIssue` | `number.decimalPlacesExceeded` | `currentPlaces`, `maxPlaces` |

---

## URL

### Usage

```dart
final validator = UrlValidator();
final result = validator.validate('https://example.com/path');

result.fold(
  (issue) => print(resolveUrlValidationIssue(issue)),
  (uri) => print(uri.host), // 'example.com'
);
```

### Configuration

```dart
const config = UrlValidationConfig(
  allowedSchemes: {'https'}, // only HTTPS
  requireHost: true,
);
const validator = UrlValidator(config);
```

---

## Phone

### Usage

```dart
final validator = PhoneValidator();
final result = validator.validate('+1 (415) 555-2671');

result.fold(
  (issue) => print(resolvePhoneValidationIssue(issue)),
  (phone) => print(phone), // '+14155552671'
);
```

### Configuration

```dart
// Enforce E.164 leading + prefix
final validator = PhoneValidator(PhoneValidationConfig.e164());
```

---

## Identifier

Validates UUID, ULID, IMEI, EAN, Credit Card, MongoId, SemVer, or NanoId formats:

```dart
const uuidValidator = IdentifierValidator(
  IdentifierValidationConfig(requiredType: IdentifierType.uuid),
);

final result = uuidValidator.validate('f47ac10b-58cc-4372-a567-0e02b2c3d479');
```

---

## Network

Validates IP addresses (IPv4, IPv6), CIDR blocks, MAC addresses, network Ports, Data URIs, or Magnet URIs:

```dart
const cidrValidator = NetworkValidator(
  NetworkValidationConfig(requiredType: NetworkAddressType.cidr),
);

final result = cidrValidator.validate('192.168.1.0/24');
```

---

## Date

Validates ISO 8601 dates, 24-hour time format, past/future/today constraints, weekday/weekend restrictions, and date range bounds:

```dart
const pastDateValidator = DateValidator(
  DateValidationConfig(mustBePast: true),
);

final result = pastDateValidator.validate('2000-01-01T00:00:00Z');
```

---

## Custom message resolvers


Each domain ships a default resolver (`resolveEmailValidationIssue`, etc.) that returns English strings. Override per-issue for localization or custom copy.

```dart
String myEmailMessages(EmailValidationIssue issue) => switch (issue) {
  EmailEmptyIssue()           => 'សូមបញ្ចូលអ៊ីម៉ែល',           // Khmer
  EmailInvalidFormatIssue()   => 'អ៊ីម៉ែលមិនត្រឹមត្រូវ',
  EmailBlockedDomainIssue()   => 'Domain មិនត្រូវបានអនុញ្ញាត',
  _                           => resolveEmailValidationIssue(issue), // fallback
};
```

---

## Using with Flutter forms

Wire any validator into a `TextFormField` using the `asFormValidator` adapter from `gmana_form`:

```dart
import 'package:gmana_form/gmana_form.dart';

TextFormField(
  validator: asFormValidator(
    validate: (input) => EmailValidator().validate(input),
    resolve: resolveEmailValidationIssue,
  ),
)

// With a custom resolver
TextFormField(
  validator: asFormValidator(
    validate: (input) => PasswordValidator(
      PasswordValidationConfig.strong(),
    ).validate(input),
    resolve: myPasswordMessages,
  ),
)
```

Or use the pre-wired field widgets from `gmana_form` (`GEmailField`, `GPasswordField`, `GTextField`, `GNumberField`) which handle this internally.
