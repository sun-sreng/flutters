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

- [Fluent Extensions](#fluent-extensions)
- [String](#string)
- [Date](#date)
- [Network](#network)
- [Identifiers](#identifiers)
- [Numeric](#numeric)

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
isCamelCase('camelCaseStr')   // true
isPascalCase('PascalCaseStr') // true
isSnakeCase('snake_case_str') // true
isKebabCase('kebab-case-str') // true
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

