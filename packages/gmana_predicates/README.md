# gmana_predicates

Pure Dart boolean predicate functions and fluent extensions for string classification and validation.

```dart
import 'package:gmana_predicates/gmana_predicates.dart';

// Standalone functions
if (isEmail(userInput)) { ... }

// Fluent extension syntax
if (userInput.isEmail) { ... }
```

All functions are top-level and pure — no classes, no state, no side effects. Functions marked `@experimental` are subject to change or removal.

---

## Table of contents

- [Composing predicates](#composing-predicates)
- [Fluent Extensions](#fluent-extensions)
- [String](#string)
- [Date](#date)
- [Network](#network)
- [Identifiers](#identifiers)
- [Numeric](#numeric)

---

## Composing predicates

Every predicate here is a `bool Function(String)`, which is exactly
`Predicate<String>`. That makes them composable without any wrapping.

```dart
final username = Predicates.all<String>([
  isNotBlank,
  (value) => value.isLength(3, 16),
  isAlphaNumeric.or(isSnakeCase),
]);

username('sun_sreng');   // true
username('ab');          // false — too short
username('has spaces');  // false
```

### The combinators

```dart
Predicates.all([a, b])      // every one passes; short-circuits, empty = true
Predicates.any([a, b])      // at least one passes; short-circuits, empty = false
Predicates.none([a, b])     // no one passes
Predicates.not(a)           // negation
Predicates.alwaysTrue()     // identity element for `all`
Predicates.alwaysFalse()
Predicates.equalTo('draft')
Predicates.oneOf(['draft', 'review'])          // set membership
Predicates.nullable(isEmail, whenNull: true)   // lift to Predicate<String?>
```

They are static members rather than top-level functions so that names as
common as `all`, `any` and `not` stay out of your global namespace — and so
they do not clash with the matchers of the same name in `package:test`.

### The fluent form

```dart
isEmail.and(isNotBlank)      // right side skipped when the left fails
isEmail.or(isUrl)            // right side skipped when the left passes
isNumeric.xor(isAlpha)       // both sides always run
isEmail.negated

isNumeric.everyIn(['1', '2'])  // true
isNumeric.anyIn(['1', 'x'])    // true
```

`on` retargets a `Predicate<String>` at a field of a larger object, so the
same rules work on records and models:

```dart
final hasValidEmail = isEmail.on((User user) => user.email);
final invalid = users.where(hasValidEmail.negated);
```

---

## Fluent Extensions

All predicates are also available as fluent getters and methods on `String?`, `String`, and `DateTime`:

```dart
'user@example.com'.isEmail         // true
'192.168.1.1'.isIpv4               // true
'42'.isEven                        // true
'7'.isPrimeString                  // true
'01ARZ3NDEKTSV4RRFFQ69G5FAV'.isULID // true

String? name;
name.isBlank                       // true
name.isNotBlank                    // false

DateTime.now().isWeekend           // true/false
```

> **Using this through `package:gmana`?** `gmana_extensions` declares some of
> the same names on `String` — `isAlpha`, `isEmail`, `isNumeric`, `isUrl`,
> `containsIgnoreCase`, and the date predicates `isDate`, `isAfter`,
> `isBefore`, `isBetween`, `isToday`, `isPast`, `isFuture`, `isWeekday`,
> `isWeekend`, `isLeapYear`. When both libraries are in scope Dart reports
> those calls as ambiguous. Use the top-level function form
> (`isEmail(value)`), which is never ambiguous, or an explicit extension
> override: `GmanaStringPredicatesExt(value).isEmail`.

---

## String

### Character set & case

```dart
isAlpha('Hello')        // true  — ASCII letters only (a–z, A–Z)
isAlphaNumeric('A1b2')  // true  — ASCII letters and digits only
isAscii('hello')        // true  — printable ASCII (U+0000–U+007F)
isNumeric('42')         // true  — digits only (optionally negative)
isInt('42')             // true
isFloat('3.14')         // true
isBase64('SGVsbG8=')    // true
isHexadecimal('FF5500') // true
isHexColor('#FF5500')   // true

isLowerCase('hello')    // true
isUpperCase('HELLO')    // true
isCapitalized('Hello')  // true  — starts with uppercase letter
```

### Case & naming conventions

```dart
isCamelCase('camelCaseStr')         // true
isPascalCase('PascalCaseStr')       // true
isSnakeCase('snake_case_str')       // true
isKebabCase('kebab-case-str')       // true
isScreamingSnakeCase('FOO_BAR')     // true
isTitleCase('Foo Bar Baz')          // true  — rejects `Foo BAR`
```

### Number bases & encodings

```dart
isBinary('01101')     // true
isOctal('0755')       // true
isBase32('MZXW6YTB')  // true  — RFC 4648, uppercase alphabet
isDecimal('12.50', places: 2)  // true  — exactly two decimal places
isDecimal('12.5', places: 2)   // false
```

### Colors & coordinates

```dart
isRgbColor('rgb(255, 0, 128)')     // true  — channels must be 0–255
isHslColor('hsl(210, 50%, 40%)')   // true  — percentages must be 0–100
isLatitude('11.55')                // true  — -90..90
isLongitude('104.91')              // true  — -180..180
isLatLong('11.55,104.91')          // true
```

### Passwords

```dart
isStrongPassword(r'Tr0ub4dor&3')   // true

// Every rule can be switched off independently
isStrongPassword(
  candidate,
  minLength: 12,
  requireSpecial: false,
  allowWhitespace: true,   // passphrases
);
```

### Text shape

```dart
isPrintable('Hello!')                    // true  — printable ASCII + \t \n \r
hasWhitespace('a b')                     // true
startsWithIgnoreCase('HelloWorld', 'hello') // true
endsWithIgnoreCase('HelloWorld', 'WORLD')   // true
isAnagram('Dormitory', 'Dirty Room')     // true  — ignores case/punctuation
```

### Format & validation

```dart
isEmail('user@example.com')   // true
isSlug('my-blog-post')        // true
isJson('{"a":1}')             // true
isJwt('eyJhbGci...')          // true  — JSON Web Token structure
isMimeType('application/json')// true  — RFC 2045 MIME type
isHash('5d41402...', 'md5')   // true  — md5, sha1, sha256, sha512
isPalindrome('racecar')       // true  — ignores non-alphanumeric/case by default
```

### Null & whitespace checks

```dart
isNullOrEmpty(null)   // true
isBlank('   \t')      // true  — null, empty, or whitespace-only
isNotBlank('hello')   // true  — not null and contains non-whitespace
```

### Experimental

```dart
isFullWidth('Ａ')     // true  — full-width Unicode
isHalfWidth('A')      // true  — half-width Unicode
isMultiByte('héllo')  // true  — contains non-ASCII
isSurrogatePair('𝄞')  // true  — contains surrogate pairs
isVariableWidth('Aａ') // true  — mixed half and full-width
```

---

## Date

```dart
isDate('2024-06-15')                 // true
isTime('14:30:00')                   // true  — 24-hour time format
isToday('2024-06-15')                // true/false depending on today UTC
isPast('2020-01-01')                 // true
isFuture('2099-12-31')               // true

isAfter('2024-12-31', '2024-01-01')   // true
isBefore('2020-01-01', '2021-01-01')  // true
isBetween('2024-06-15', '2024-01-01', '2024-12-31') // true

isWeekend('2024-01-13')              // true
isWeekday('2024-01-15')              // true
isLeapYear('2024-02-01')             // true

isSameDay('2026-08-07T10:00Z', '2026-08-07T18:00Z') // true
isSameMonth('2026-08-01', '2026-08-31')             // true
isSameYear('2026-01-01', '2026-12-31')              // true
isSameWeek('2024-06-10', '2024-06-16')              // true — Monday-start week
```

### Relative to now

```dart
isYesterday('2026-08-06')                        // true/false vs today UTC
isTomorrow('2026-08-08')
isWithinLast(signupDate, const Duration(days: 30))
isWithinNext(dueDate, const Duration(days: 7))
isAgeAtLeast('2000-01-01', 18)   // true — the birthday itself counts
```

### Boundaries & strictness

```dart
isStartOfMonth('2024-06-01')  // true
isEndOfMonth('2024-02-29')    // true — leap-year aware

// isBetween is exclusive; isBetweenInclusive admits the bounds
isBetween('2024-01-01', '2024-01-01', '2024-12-31')          // false
isBetweenInclusive('2024-01-01', '2024-01-01', '2024-12-31') // true

// isIso8601 is stricter than isDate
isDate('2024-06-15 10:00:00')     // true  — DateTime.tryParse accepts it
isIso8601('2024-06-15 10:00:00')  // false — not the T form
isDate('2024-13-01')              // true  — silently rolls into 2025
isIso8601('2024-13-01')           // false
```

### How dates are parsed

A string with no time and no zone names a **calendar day** and is read as UTC
midnight, so these predicates give the same answer in every timezone. A value
that does carry a time but no zone is treated as local, since a wall-clock
reading without a zone is a local one.

```dart
tryParseDate('2024-06-15')            // 2024-06-15 00:00:00.000Z
tryParseDate('2024-06-15T10:30:00')   // local 10:30, converted to UTC
tryParseDate('2024-06-15T10:30:00Z')  // 2024-06-15 10:30:00.000Z
```

---

## Network

```dart
isIpv4('192.168.0.1')                     // true
isIpv6('::1')                             // true
isIP('192.168.0.1', 4)                    // true  — version check
isCidr('192.168.1.0/24')                  // true  — CIDR block notation
isUrl('https://example.com/api')          // true
isMacAddress('00:1A:2B:3C:4D:5E')         // true
isPort('8080')                            // true
isDataURI('data:image/png;base64,...')    // true  — RFC 2397
isMagnetURI('magnet:?xt=urn:btih:...')    // true  — BitTorrent Magnet
isPostalCode('90210', 'US')               // true

isHostname('localhost')                   // true  — no TLD required
isHostname('sub.example.com')             // true
```

### Address classification

```dart
isPrivateIpv4('10.0.0.1')     // true  — RFC 1918: 10/8, 172.16/12, 192.168/16
isLoopbackIpv4('127.0.0.1')   // true  — the whole 127/8 block
isPublicIpv4('8.8.8.8')       // true
isPublicIpv4('169.254.1.1')   // false — link-local
isPublicIpv4('224.0.0.1')     // false — multicast and above
```

---

## Identifiers

```dart
isUuid('550e8400-e29b-41d4-a716-446655440000') // true
isCreditCard('4111111111111111')             // true  — Luhn check
isLuhnValid('79927398713')                   // true  — standalone Luhn check
isIMEI('490154203237518')                    // true  — 15-digit IMEI
isEAN('4006381333931', '13')                 // true  — EAN-8 / EAN-13
isULID('01ARZ3NDEKTSV4RRFFQ69G5FAV')         // true  — Crockford Base32
isNanoId('V1StGXR8_Z5jdHi6B-myT')            // true  — Nano ID check
isSemVer('1.0.0-alpha.1')                    // true
isPhoneNumber('+1 (415) 555-2671')           // true
isIban('GB82 WEST 1234 5698 7654 32')        // true  — ISO 13616 mod-97
isBic('DEUTDEFF')                            // true  — 8- or 11-character

// isUuid takes a version: '1', '3', '4', '5', '6', or '7'
isUuid('018f7b1a-9c2e-7d3f-8a4b-5c6d7e8f9a0b', '7') // true

// Experimental
isISBN('978-3-16-148410-0')                  // true
isMongoId('507f1f77bcf86cd799439011')         // true
isFQDN('example.com')                        // true
```

---

## Numeric

```dart
isDivisibleBy('9', '3')   // true
isEven('42')              // true
isOdd('7')                // true
isPositive('15.5')        // true
isNegative('-10')         // true
isZero('0.0')             // true
isInRange('5', 1, 10)     // true
isPrime(29)               // true  — integer input
isPrimeString('29')       // true  — string input
```

