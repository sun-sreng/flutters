# gmana_predicates

Pure Dart boolean predicate functions for string classification and validation.

```dart
import 'package:gmana_predicates/gmana_predicates.dart';
```

All functions are top-level and pure — no classes, no state, no side effects. Functions marked `@experimental` are subject to change or removal.

---

## Table of contents

- [String](#string)
- [Date](#date)
- [Network](#network)
- [Identifiers](#identifiers)
- [Numeric](#numeric)

---

## String

### Character set

```dart
isAlpha('Hello')        // true  — ASCII letters only (a–z, A–Z)
isAlpha('Hello1')       // false

isAlphaNumeric('A1b2')  // true  — ASCII letters and digits only
isAlphaNumeric('A1 b2') // false — space fails

isAscii('hello')        // true  — printable ASCII (U+0000–U+007F)
isAscii('héllo')        // false

isNumeric('42')         // true  — digits only (optionally negative)
isNumeric('-7')         // true
isNumeric('3.14')       // false — use isFloat for decimals

isInt('42')             // true
isInt('3.14')           // false

isFloat('3.14')         // true
isFloat('42')           // true  — integers are valid floats

isBase64('SGVsbG8=')    // true
isHexadecimal('FF5500') // true
isHexColor('#FF5500')   // true
isHexColor('#FFF')      // true
isHexColor('FF5500')    // false — # required
```

### Case

```dart
isLowerCase('hello')  // true
isLowerCase('Hello')  // false
isUpperCase('HELLO')  // true
```

### Content checks

```dart
contains('hello world', 'world')            // true
containsIgnoreCase('Hello World', 'WORLD')  // true
equals('foo', 'foo')                        // true
equals(null, 'foo')                         // false
matches('hello123', r'^\w+$')               // true  — regex match
```

### Format

```dart
isEmail('user@example.com')   // true  — RFC 5322 heuristic
isEmail('bad@')               // false
isSlug('my-blog-post')        // true  — lowercase alphanumeric with hyphens
isJson('{"a":1}')             // true
isJson('not json')            // false
```

### Length

```dart
// Byte length (uses String.length as proxy)
isByteLength('hello', 3)       // true   — >= 3
isByteLength('hello', 3, 10)   // true   — between 3 and 10
isByteLength('hi', 3)          // false  — < 3

// Display length — counts surrogate pairs as 1 character
isLength('hello', 3, 10)  // true
```

### Null / empty

```dart
isNullOrEmpty(null)   // true
isNullOrEmpty('')     // true
isNullOrEmpty('a')    // false
```

### Experimental

These predicates cover Unicode edge cases and are subject to change.

```dart
isFullWidth('Ａ')     // true  — full-width Unicode
isHalfWidth('A')      // true  — half-width Unicode
isMultiByte('héllo')  // true  — contains non-ASCII
isSurrogatePair('𝄞')  // true  — contains surrogate pairs
isVariableWidth('Aａ') // true  — mixed half and full-width
```

---

## Date

All functions accept any ISO 8601 format supported by `DateTime.tryParse`. All comparisons use UTC.

```dart
tryParseDate('2024-06-15')           // DateTime(2024, 6, 15, ...) UTC
tryParseDate('not a date')           // null

isDate('2024-06-15')                 // true
isDate('32nd of March')              // false
```

`tryParseDate` is also exported for cases where you need the parsed `DateTime` rather than a boolean — it trims whitespace and normalizes to UTC.

### Relative to now

```dart
isToday('2024-06-15')      // true/false depending on today's UTC date
isPast('2020-01-01')       // true
isFuture('2099-12-31')     // true
```

### Relative to a reference

```dart
isAfter('2024-12-31')                       // after now?
isAfter('2024-12-31', '2024-01-01')         // after 2024-01-01?  → true

isBefore('2020-01-01')                      // before now?  → true
isBefore('2020-01-01', '2019-01-01')        // before 2019-01-01? → false

isBetween('2024-06-15', '2024-01-01', '2024-12-31') // true — strictly between
```

### Day classification

```dart
isWeekend('2024-01-13')  // true  — Saturday
isWeekday('2024-01-15')  // true  — Monday
isLeapYear('2024-02-01') // true  — 2024 is a leap year
isLeapYear('2023-02-01') // false
```

---

## Network

### IP addresses

```dart
isIpv4('192.168.0.1')      // true
isIpv4('256.0.0.1')        // false — octet out of range
isIpv4('192.168.0')        // false — too few octets

isIpv6('::1')                              // true
isIpv6('2001:0db8:85a3::8a2e:0370:7334')  // true

isUrl('https://example.com/api')           // true
isMacAddress('00:1A:2B:3C:4D:5E')          // true
isPort('8080')                             // true — 1 to 65535
```

### Postal codes

Validates against locale-specific patterns. Supported locales include common country codes (`US`, `GB`, `DE`, `FR`, `CA`, `AU`, `JP`, etc.).

```dart
isPostalCode('90210', 'US')   // true
isPostalCode('SW1A 1AA', 'GB') // true
isPostalCode('10115', 'DE')    // true

// Unknown locale — use orElse to avoid throwing
isPostalCode('12345', 'XX', orElse: () => false) // false — unsupported locale
// Without orElse: throws FormatException for unsupported locales
```

---

## Identifiers

### UUID

```dart
isUuid('550e8400-e29b-41d4-a716-446655440000')        // true  — any version
isUuid('550e8400-e29b-41d4-a716-446655440000', '4')   // true  — v4 only
isUuid('550e8400-e29b-31d4-a716-446655440000', '4')   // false — v3 treated as v4
```

### Credit card (Luhn)

```dart
isCreditCard('4111111111111111')    // true  — Visa test number
isCreditCard('4111 1111 1111 1111') // true  — spaces stripped
isCreditCard('1234567890123456')    // false — fails Luhn

isSemVer('1.0.0-alpha.1')           // true  — Semantic Versioning 2.0
isPhoneNumber('+1 (415) 555-2671')  // true  — 7-15 digits
```

### Experimental

```dart
// ISBN — version '10' or '13', or null for either
isISBN('0-306-40615-2')       // true  — ISBN-10
isISBN('978-3-16-148410-0')   // true  — ISBN-13
isISBN('978-3-16-148410-0', '13') // true  — explicit version check

// MongoDB ObjectId — 24-character hex string
isMongoId('507f1f77bcf86cd799439011')  // true
isMongoId('507f1f77bcf86cd79943901')   // false — 23 chars

// Fully-qualified domain name
isFQDN('example.com')                   // true
isFQDN('sub.example.co.uk')            // true
isFQDN('localhost', requireTld: false)  // true
isFQDN('example_.com')                 // false — underscore not allowed by default
isFQDN('example_.com', allowUnderscores: true) // true
```

---

## Numeric

```dart
isDivisibleBy('9', '3')    // true   — 9 % 3 == 0
isDivisibleBy('10', '3')   // false
isDivisibleBy('4.0', '2')  // true   — parses as double
isDivisibleBy('abc', '2')  // false  — parse failure returns false
```
