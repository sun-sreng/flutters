# gmana_value_objects

Production-ready domain value objects with configurable validation for contact,
text, numeric, money, identifier, network, URL, and date-range data.

`gmana_value_objects` is pure Dart and framework independent. Use it in CLI
apps, Dart servers, Flutter apps, or shared domain packages when you want typed
values, `Either`-based validation, and rich error models.

The package depends on `gmana_functional` and re-exports `Either`, `Left`, and
`Right` for composing validation results. It can be imported directly or
through the `gmana` umbrella package.

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart';
```

---

## Table of contents

- [Installation](#installation)
- [Features](#features)
- [Always valid by construction](#always-valid-by-construction)
- [Validation result extensions](#validation-result-extensions)
- [Updating validation configs](#updating-validation-configs)
- [Email](#email)
- [Password](#password)
- [Text](#text)
- [Number](#number)
- [Money](#money)
- [URL](#url)
- [Phone](#phone)
- [Identifier](#identifier)
- [Network address](#network-address)
- [Date range](#date-range)
- [Default messages](#default-messages)
- [Composing with gmana_functional](#composing-with-gmana_functional)

## Installation

```yaml
dependencies:
  gmana_value_objects: ^0.1.0
```

Or install it from the command line:

```bash
dart pub add gmana_value_objects
```

## Features

- Typed value objects for `Email`, `Password`, `TextValue`, `NumberValue`,
  `Money`, `UrlValue`, `PhoneValue`, `IdentifierValue`,
  `NetworkAddressValue`, and `DateRangeValue`.

- Pure validators for each type when you want `Either<ValidationError, T>`
  without constructing a value object.
- Sealed error hierarchies for exhaustive `switch` handling.
- Machine-readable `ValidationError.code` values for logs, analytics, and UI
  keys, with explicit overrides available when codes must survive obfuscation.
- Configurable validation presets for common application constraints.
- Default English validation messages with a small interface for i18n.
- Currency-aware money stored as exact integer minor units.

## Always valid by construction

Value objects in this package are **always valid**: if you are holding an
`Email`, it has already passed validation. This makes illegal states
unrepresentable — a function that takes an `Email` can never receive an invalid
one. There is no "invalid value object" to guard against.

Most single-value families provide two construction paths:

- `T.tryParse(input)` — validates untrusted input and returns
  `Either<Error, T>`. Use this for user input, API payloads, and forms.
- `T(input)` — builds from a trusted literal and **throws**
  `ValueObjectException` if the input is invalid. Use this for hard-coded,
  known-good values.

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart';

// Untrusted input → Either<EmailError, Email>.
Email.tryParse('user@example.com').fold(
  (error) => print('Invalid: ${error.code}'),
  (email) => print(email.value), // user@example.com
);

// Trusted literal → throws if invalid.
final email = Email('user@example.com');
print(email.value); // user@example.com
```

Types that extend `ValueObject<T>` expose:

| API               | Meaning                                                      |
| ----------------- | ------------------------------------------------------------ |
| `T.tryParse(...)` | Validate untrusted input, returning `Either<Error, T>`.      |
| `T(input)`        | Build from a trusted literal; throws `ValueObjectException`. |
| `value`           | The validated underlying value (always present).             |
| `isSensitive`     | `true` for sensitive objects such as `Password`.             |
| `==` / `hashCode` | Structural equality by concrete type and `value`.            |

`Money` is a standalone composite value object with amount-and-currency
constructors and `MoneyValidator` for untrusted text. Its dedicated section
below covers that API.

## Validation result extensions

Every smart constructor returns an `Either<E, T>` where `E` extends
`ValidationError`. `GmanaValueObjectResultX` makes the common inspection path
concise without throwing or eagerly formatting an error:

```dart
final result = Email.tryParse('not-an-email');

print(result.isValid); // false
print(result.isInvalid); // true
print(result.valueOrNull); // null
print(result.errorOrNull?.code); // email_invalid_format
print(result.messageOrNull()); // Invalid email format
```

`isValid` and `valueOrNull` inspect the success branch; `isInvalid`,
`errorOrNull`, and `messageOrNull()` inspect the failure branch.
`messageOrNull()` returns `null` for a valid result and uses
`DefaultValidationErrorMessages` by default. Pass your own
`ValidationErrorMessages` implementation to localize the failure:

```dart
final class AppValidationErrorMessages implements ValidationErrorMessages {
  const AppValidationErrorMessages();

  @override
  String getMessage(ValidationError error) => 'Invalid: ${error.code}';
}

final message = Email.tryParse('bad').messageOrNull(
  const AppValidationErrorMessages(),
);
```

These helpers inspect the validation result. They do not add an invalid state
to the value object itself: an `Email` obtained from `valueOrNull` is still
always valid.

## Updating validation configs

Every validation config supports copy-style `copyWith` updates. In addition to
the existing email, password, text, number, and money methods, extensions add
`copyWith` to phone, URL, identifier, and network configs.
`GmanaPhoneValidationConfigX`, `GmanaUrlValidationConfigX`,
`GmanaIdentifierValidationConfigX`, and `GmanaNetworkValidationConfigX` provide
these additions:

```dart
final phoneRules = const PhoneValidationConfig().copyWith(
  requirePlusPrefix: true,
  minDigits: 10,
);

final urlRules = const UrlValidationConfig().copyWith(
  allowedSchemes: {'https'},
);

final uuidV4Rules = const IdentifierValidationConfig().copyWith(
  requiredType: IdentifierType.uuid,
  uuidVersion: '4',
);

final ipv4CidrRules = const NetworkValidationConfig().copyWith(
  requiredType: NetworkAddressType.cidr,
  ipVersion: 4,
);
```

For `IdentifierValidationConfig.uuidVersion`,
`IdentifierValidationConfig.eanVersion`, and
`NetworkValidationConfig.ipVersion`, omitting the argument preserves the old
value while passing `null` clears it:

```dart
final anyUuidVersion = uuidV4Rules.copyWith(uuidVersion: null);
final anyIpVersion = ipv4CidrRules.copyWith(ipVersion: null);
```

Each `copyWith` call returns a new config instance. Collection-valued fields
retain the supplied `Set` or `List` rather than defensively copying it, so avoid
mutating those collections after construction. Most config types implement
structural equality; `IdentifierValidationConfig` and
`NetworkValidationConfig` currently retain identity equality.

## Email

```dart
Email.tryParse('USER@Example.COM').fold(
  (error) => print(error.code),
  (email) => print(email.value), // user@example.com
);

Email.tryParse(
  'user@tempmail.com',
  config: EmailValidationConfig.strict(),
).fold(
  (error) => switch (error) {
    EmailDisposableDomain(:final domain) => print('Disposable domain: $domain'),
    _ => print('Invalid email: ${error.code}'),
  },
  (email) => print('Valid email: ${email.value}'),
);
```

Email validation supports format checks, max lengths, disposable domains, and
custom blocked domains.

## Password

```dart
final password = Password(
  'MyP@ssw0rd!2026',
  config: PasswordValidationConfig.strict(),
);

print(password.isSensitive); // true
print(password.toString()); // Password(***) — value is masked
print(password.value); // MyP@ssw0rd!2026
```

Password validation supports min/max length, ASCII-only rules, common password
checks, predictable sequence checks, and complexity scoring.

## Text

```dart
final username = TextValue(
  'john_doe',
  config: TextValidationConfig.username(),
);

final title = TextValue(
  'Hello World',
  config: TextValidationConfig(
    minLength: 5,
    maxLength: 50,
    pattern: r'^[a-zA-Z\s]+$',
    blacklistedWords: {'spam', 'banned'},
  ),
);
```

Text validation supports trimming, empty/whitespace rules, length bounds,
regular expressions, allowed characters, blacklisted words, and common presets.

## Number

```dart
final age = NumberValue('25', config: NumberValidationConfig.age());
final price = NumberValue('19.99', config: NumberValidationConfig.price());
final quantity = NumberValue.fromNum(
  10,
  config: NumberValidationConfig.positiveInteger(),
);
```

Number validation supports min/max bounds, integer-only mode, negative controls,
decimal-place limits, finite number checks, and presets for age, rating,
percentage, prices, and integer values.

## Money

`Money` stores exact integer minor units with currency metadata, so arithmetic
does not depend on floating-point decimal storage.

```dart
final unitPrice = Money.fromDecimalString('19.99', Currency.usd);
final shipping = Money.fromDecimalString('5.00', Currency.usd);
final total = unitPrice * 2 + shipping;
final discounted = total.applyDiscountPercent(10);

print(unitPrice.minorUnits); // 1999
print(discounted.formatted); // $40.48
```

Money supports:

- exact minor-unit storage, such as cents for USD
- zero, exact minor-unit, major/minor, decimal-string, and numeric constructors
- same-currency arithmetic and comparison
- half-up rounding for multiplication and percentages
- proportional allocation without losing remainders
- deterministic display strings and API decimal strings
- `MoneyValidator` for `Either`-based form and pipeline validation

```dart
final result = MoneyValidator(MoneyValidationConfig.ecommerce())
    .validate('1,234.56', currency: 'USD');

result.fold(
  (error) => print(DefaultValidationErrorMessages().getMessage(error)),
  (amount) => print(amount.formattedWithCode), // USD 1234.56
);
```

Collections of money can be totaled without inventing an empty currency:

```dart
final cart = [
  Money.fromDecimalString('19.99', Currency.usd),
  Money.fromDecimalString('5.00', Currency.usd),
];

print(cart.sumOrNull()?.formatted); // $24.99
print(<Money>[].sumOrNull()); // null
```

`sumOrNull()` throws `ArgumentError` if currencies are mixed. When a collection
legitimately contains several currencies, `sumByCurrency()` returns a fresh,
insertion-ordered map with an independent total for each currency. An empty
collection produces an empty map.

```dart
final totals = [
  Money.fromDecimalString('10.00', Currency.usd),
  Money.fromDecimalString('8.00', Currency.eur),
  Money.fromDecimalString('2.50', Currency.usd),
].sumByCurrency();

print(totals[Currency.usd]?.decimalString); // 12.50
print(totals[Currency.eur]?.decimalString); // 8.00
```

## URL

`UrlValue` wraps a parsed `Uri`. By default, only HTTP and HTTPS URLs with a
host are accepted; customize schemes and host requirements with
`UrlValidationConfig`.

```dart
final docs = UrlValue('https://dart.dev/guides');

final ftpResult = UrlValue.tryParse(
  'ftp://files.example.com/archive.zip',
  const UrlValidationConfig(allowedSchemes: {'ftp'}),
);

print(docs.value.host); // dart.dev
print(ftpResult.isValid); // true
```

## Phone

`PhoneValue` holds a normalized validated phone string. The E.164 preset
requires a leading `+` and between 7 and 15 digits.

```dart
final result = PhoneValue.tryParse(
  '+14155552671',
  PhoneValidationConfig.e164(),
);

print(result.valueOrNull?.value); // +14155552671
```

## Identifier

`IdentifierValue` supports general non-empty identifiers as well as UUID,
ULID, IMEI, EAN-8/EAN-13, credit-card Luhn, MongoDB ObjectId, semantic version,
and Nano ID formats.

```dart
final release = IdentifierValue.tryParse(
  '1.4.0-beta.1',
  config: const IdentifierValidationConfig(
    requiredType: IdentifierType.semVer,
  ),
);

print(release.isValid); // true
```

Select a UUID version with `uuidVersion`, an EAN length with `eanVersion`, or a
Nano ID length with `nanoIdLength`.

## Network address

`NetworkAddressValue` validates IPv4, IPv6, generic IP, CIDR, MAC-address, and
port strings.

```dart
final subnet = NetworkAddressValue(
  '192.168.10.0/24',
  config: const NetworkValidationConfig(
    requiredType: NetworkAddressType.cidr,
    ipVersion: 4,
  ),
);

print(subnet.value); // 192.168.10.0/24
```

Use an explicit `requiredType` when the input must represent one particular
kind of network value.

## Date range

`DateRangeValue` validates that the start is not after the end and normalizes
both endpoints to UTC. The underlying `DateRange` supports inclusive temporal
relationships through `GmanaDateRangeX`.

The public `DateRange` constructor normalizes dates but expects callers to
provide ordered endpoints. Use `DateRangeValue.tryParse` for untrusted dates
before applying these operations.

```dart
final booking = DateRangeValue(
  DateTime.utc(2026, 8, 10, 9),
  DateTime.utc(2026, 8, 10, 11),
).value;
final followUp = DateRangeValue(
  DateTime.utc(2026, 8, 10, 11),
  DateTime.utc(2026, 8, 10, 12),
).value;

print(booking.contains(DateTime.utc(2026, 8, 10, 10))); // true
print(booking.overlaps(followUp)); // true: endpoints are inclusive
print(booking.intersection(followUp)?.duration); // 0:00:00.000000
print(booking.span(followUp).duration); // 3:00:00.000000
```

`containsRange(other)` returns `true` when both endpoints of `other` are inside
the receiver. `intersection(other)` returns `null` only when the ranges are
disjoint; ranges that touch at one endpoint intersect in a zero-duration
range. `span(other)` returns the smallest range containing both inputs.

## Default Messages

```dart
final messages = DefaultValidationErrorMessages();

Email.tryParse('invalid').fold(
  (error) => print(messages.getMessage(error)), // Invalid email format
  (email) => print(email.value),
);
```

For app-specific localization, switch on `ValidationError` subclasses directly:

```dart
String localize(ValidationError error) {
  return switch (error) {
    EmailEmpty() => 'Email is required',
    EmailInvalidFormat() => 'Enter a valid email',
    PasswordTooShort(:final minLength) =>
      'Use at least $minLength characters',
    _ => DefaultValidationErrorMessages().getMessage(error),
  };
}
```

The default `ValidationError.code` is derived from the concrete error class
name. It is convenient for ordinary logs, analytics, and UI keys, but
`runtimeType` names can change in obfuscated builds. Override `code` with an
explicit literal on custom errors when the value is persisted or exposed as a
long-lived API contract.

## Composing with gmana_functional

This package re-exports `Either`, `Left`, and `Right` from
`gmana_functional`, so value-object validation can compose with your own domain
failures without a second import.

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart' as vo;

sealed class Failure {}

final class ValidationFailure extends Failure {
  ValidationFailure(this.error);

  final vo.ValidationError error;
}

final class AppEmail {
  const AppEmail._(this.email);

  final vo.Email email;

  /// Maps the value-object error into your own domain failure type.
  static vo.Either<Failure, AppEmail> tryParse(String input) {
    return vo.Email.tryParse(input).bimap(ValidationFailure.new, AppEmail._);
  }
}
```
