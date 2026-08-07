# gmana_extensions

Pure Dart extension methods for core Dart types.

```dart
import 'package:gmana_extensions/gmana_extensions.dart';
```

---

## Table of contents

- [Duration](#duration)
- [num / int / double / bool](#num--int--double--bool)
- [String](#string)
- [Iterable](#iterable)
- [List](#list)
- [Set](#set)
- [Map](#map)
- [DateTime](#datetime)
- [Stream](#stream)
- [Future & async](#future--async)
- [Uri](#uri)
- [Comparable](#comparable)
- [Any object](#any-object)

---

## Duration

### Construction from numbers (`NumDurationExtension` on `num`)

```dart
5.seconds           // Duration(seconds: 5)
5.second            // singular alias
5.sec               // short alias
30.minutes          // Duration(minutes: 30)
30.minute           // singular alias
2.hours             // Duration(hours: 2)
1.days              // Duration(days: 1)
3.weeks             // Duration(days: 21)
1.fortnight         // Duration(days: 14)
500.milliseconds    // Duration(milliseconds: 500)
500.ms              // same, shorter alias
500.millis          // same
100.microseconds
100.us              // same
1500.nanoseconds    // Duration(microseconds: 2), rounded
120.framesAt(24)    // Duration(seconds: 5)

// Arithmetic still works
final eta = 1.hours + 30.minutes + 45.seconds;
```

### Arithmetic & clamping (`HumanizedDuration`)

```dart
final d = 90.minutes;

d * 2                       // Duration(hours: 3)
d / 3                       // Duration(minutes: 30)

d.clamp(1.hours, 2.hours)   // Duration(hours: 1, minutes: 30)
d.coerceAtLeast(2.hours)    // Duration(hours: 2)
d.coerceAtMost(1.hours)     // Duration(hours: 1)

d.abs                       // always non-negative
d.isNegative                // false
d.isPositive                // true
d.isZero                    // false
d.sign                      // 1

d.isLongerThan(1.hours)     // true
d.isShorterThan(2.hours)    // true
d.isWithin(15.minutes, 1.hours + 10.minutes) // within 15m of 1h10m?
d.isBetween(1.hours, 2.hours) // true
```

### Rounding

```dart
final d = Duration(minutes: 7, seconds: 40);

d.roundToSeconds()    // Duration(minutes: 7, seconds: 40) — already whole seconds
d.roundToMinutes()    // Duration(minutes: 8)
d.ceilToMinutes()     // Duration(minutes: 8)
d.floorToMinutes()    // Duration(minutes: 7)

d.roundTo(5.minutes)  // Duration(minutes: 10)
d.floorTo(5.minutes)  // Duration(minutes: 5)
d.ceilTo(5.minutes)   // Duration(minutes: 10)
```

### Parts & fractions

```dart
final d = Duration(hours: 1, minutes: 23, seconds: 45, milliseconds: 600);

d.daysPart          // 0
d.hoursPart         // 1
d.minutesPart       // 23
d.secondsPart       // 45
d.millisecondsPart  // 600
d.microsecondsPart  // 0

d.inHoursDouble     // 1.395...
d.inMinutesDouble   // 83.76
d.inSecondsDouble   // 5025.6
d.inWeeksDouble     // 0.00993...
d.totalHours        // same as inHoursDouble
d.totalDays
d.totalMinutes
d.toSeconds()       // fractional seconds including ms
```

### Progress & remaining

```dart
final elapsed = 3.minutes;
final total = 10.minutes;

elapsed.progressOf(total)              // 0.3
elapsed.progressOf(total, clampResult: false) // can exceed 1.0
elapsed.percentOf(total)               // 30.0
elapsed.remainingIn(total)             // Duration(minutes: 7)
```

### Video / animation frames

```dart
const fps = 24.0;
final d = Duration(seconds: 5);

d.toFrames(fps)                 // 120
HumanizedDuration.fromFrames(120, fps) // Duration(seconds: 5)
```

### Async helpers

```dart
await 2.seconds.delay;                       // Future.delayed
final result = await 500.ms.delayed(() => 42); // runs callback after delay
```

### Formatting

```dart
final d = Duration(hours: 1, minutes: 2, seconds: 34);

d.toHuman()            // '1h 2m 34s'  — compact parts
d.toVerboseString()    // '1h 2m 34s'
d.toVerboseString(includeSeconds: false) // '1h 2m'
d.toWordString()       // '1 hour 2 minutes 34 seconds'
d.toHHMMSS()           // '01:02:34' or 'MM:SS' for durations under 1h
d.toIso8601String()    // 'PT1H2M34S'
d.toHumanizedString()  // '1:02:34'
d.toPaddedString()     // '01:02:34'
d.toRelativeString()   // 'in 1h 2m' / '1h 2m ago'

// Natural language (DurationNaturalLanguageX)
d.toNaturalString()    // '1 hour 2 minutes'
d.toNaturalString(maxUnits: 3) // '1 hour 2 minutes 34 seconds'
d.toCompactString()    // '1h 2m'
d.toCompactString(maxUnits: 3) // '1h 2m 34s'
d.toDetailedString()   // '1h 2m 34s'
d.toNaturalSentence()  // '1 hour and 2 minutes'
d.toApproximateString() // 'about 1 hour'
```

---

## num / int / double / bool

### Nullable coercion

```dart
// int?
int? n;
n.orZero             // 0
n.isNullOrZero       // true
n.orDefault(42)      // 42

// double?
double? d;
d.orZero             // 0.0
d.orDefault(3.14)    // 3.14

// num?
num? x;
x.orZero
x.orDefault(10)

// bool?
bool? b;
b.orFalse            // false
b.orTrue             // true
b.isNullOrFalse      // true
```

### `NumX` — math on any `num`

```dart
// Rounding to multiples
17.roundToMultiple(5)    // 15
17.ceilToMultiple(5)     // 20
17.floorToMultiple(5)    // 15
3.14159.roundTo(2)       // 3.14

// Range checks
7.isBetween(1, 10)       // true

// Normalization / lerp
50.normalized(0, 100)           // 0.5  — maps [0,100] → [0,1]
50.normalized(0, 100, 0, 255)   // 127.5 — maps [0,100] → [0,255]
50.normalizedClamped(0, 100)    // 0.5  — same but result clamped to [toMin,toMax]
50.safeNormalized(0, 0, fallback: 0.5) // 0.5 — source range is zero, no throw

0.3.lerp(10, 20)    // 13.0  — t=0.3 between 10 and 20

// Temperature conversion
100.0.celsiusToFahrenheit   // 212.0
212.0.fahrenheitToCelsius   // 100.0
0.0.celsiusToKelvin         // 273.15
300.0.kelvinToCelsius       // 26.85

// Predicates
3.0.isWholeNumber    // true
3.5.isWholeNumber    // false
```

### `IntX` — int-specific helpers

```dart
42.isEven           // true
7.isOdd             // true
42.digitCount       // 2
42.digits           // [4, 2]
7.isBetween(1, 10)  // true

// Repeat an action
3.times(() => print('hello'));  // prints 3 times

// Inclusive range as lazy iterable
1.to(5)              // [1, 2, 3, 4, 5]
0.to(10, step: 2)    // [0, 2, 4, 6, 8, 10]

// Number theory
97.isPrime           // true
1024.isPowerOfTwo    // true
4.lcm(6)             // 12  (pairs with the built-in 4.gcd(6))
5.factorial          // 120 (rejects negatives and anything over 20)
```

### Angles & powers (`NumX`)

```dart
180.toRadians        // 3.14159...
math.pi.toDegrees    // 180.0
2.raisedTo(10)       // 1024.0
16.squareRoot        // 4.0
(0 / 0).orFinite()   // 0    — swaps NaN/infinity for a fallback
```

### Human-readable formatting (`NumFormatX`)

```dart
1234.toCompact()                  // '1.2K'
2500000.toCompact()               // '2.5M'
(-4500000).toCompact()            // '-4.5M'
1234.toCompact(decimals: 2)       // '1.23K'

1024.toBytes()                    // '1 KiB'   — 1024-based, IEC units
1500.toBytes(binary: false)       // '1.5 kB'  — 1000-based, SI units

1234567.toThousands()             // '1,234,567'
1234567.toThousands(separator: ' ') // '1 234 567'
1234.5.toThousands(decimals: 2)   // '1,234.50'

1234.5.toCurrency()               // '$1,234.50'
(-9.5).toCurrency()               // '-$9.50'
1234.5.toCurrency(symbol: '€', suffix: true) // '1,234.50€'

0.256.toPercentString()           // '26%'
0.256.toPercentString(decimals: 1) // '25.6%'

3.14159.toFixed(2)                // '3.14'
3.10.toTrimmed(2)                 // '3.1'  — trailing zeros dropped
```

### Integer formatting (`IntFormatX`)

```dart
1.toOrdinal          // '1st'
12.toOrdinal         // '12th'
23.toOrdinal         // '23rd'

2024.toRoman         // 'MMXXIV'
1994.toRoman         // 'MCMXCIV'  (valid for 1–3999)

7.toPadded(3)                     // '007'
(-7).toPadded(3)                  // '-07'
255.toHexString(upperCase: true)  // 'FF'
255.toHexString(prefix: true, padTo: 4) // '0x00ff'
5.toBinaryString(prefix: true)    // '0b101'
8.toOctalString()                 // '10'
```

---

## String

### Null / blank safety (`StringNullableX` on `String?`)

```dart
String? s;
s.orEmpty            // ''
s.isNullOrEmpty      // true
s.isNullOrBlank      // true
s.orNull             // null (coerces blank '' to null)
s.mapNotBlank((v) => v.toUpperCase())  // null if blank, else transformed
```

### Predicates (`StringX`)

```dart
'hello'.isBlank          // false
'  '.isBlank             // true
'hello'.isNotBlank       // true
'ABC'.isAlpha            // true
'A1B2'.isAlphanumeric    // true
'42'.isNumeric           // true
'hello'.blankToNull      // 'hello'
'  '.blankToNull         // null
```

### Case conversion

```dart
'hello world'.toTitleCase       // 'Hello World'
'hello world'.toSentenceCase    // 'Hello world'
'hello world'.toCamelCase       // 'helloWorld'
'hello world'.toSnakeCase       // 'hello_world'
'hello world'.toKebabCase       // 'hello-world'
'hello world'.toScreamingSnakeCase // 'HELLO_WORLD'
'helloWorld'.toSnakeCase        // 'hello_world'
'helloWorld'.toKebabCase        // 'hello-world'
```

### Slugs & URL helpers

```dart
'Hello World! 2024'.toSlug   // 'hello-world-2024'
'hello'.toUriOrNull          // null (no scheme)
'https://example.com'.toUriOrNull  // Uri(...)
'https://example.com'.isUrl  // true
```

### Parse helpers

```dart
'42'.toIntOrNull     // 42
'abc'.toIntOrNull    // null
'abc'.toIntOrZero    // 0
'3.14'.toDoubleOrNull // 3.14

'true'.toBool        // true
'yes'.toBool         // false  (only 'true' returns true)

'{"a":1}'.jsonDecodeOrNull   // {'a': 1}
'bad json'.jsonDecodeOrNull  // null

'01:30'.toDurationOrNull     // Duration(minutes: 1, seconds: 30)
'1:02:03'.toDuration()       // Duration(hours: 1, minutes: 2, seconds: 3)
```

### Manipulation

```dart
'hello'.repeat(3)                     // 'hellohellohello'
'Hello World'.truncate(8)             // 'Hello...'
'Hello World'.truncate(8, ellipsis: '…') // 'Hello W…'
'Hello World'.truncateWords(8)        // 'Hello...' (breaks at word boundary)
'hello'.wrap('(', ')')                // '(hello)'
'hello'.wrap('<b>')                   // '<b>hello<b>'
'--hello--'.trimHyphens()             // 'hello'
'hello world'.removeWhitespace        // 'helloworld'
'héllo'.reversed                      // 'ollèh' (Unicode-safe)
'hello world'.countOccurrences('l')   // 3
'hello'.hasLengthBetween(3, 10)       // true
'Hello World'.readingTimeMinutes      // 1  (225 wpm estimate)
```

### Tokenizing

```dart
'user_firstName'.words        // ['user', 'first', 'Name']
'a\nb\r\nc'.lines             // ['a', 'b', 'c']
'ada lovelace'.initials()     // 'AL'
'Grace Brewster Hopper'.initials(max: 3) // 'GBH'
'4111111111111111'.chunked(4) // ['4111', '1111', '1111', '1111']
```

### Case-insensitive comparison

```dart
'Hello'.equalsIgnoreCase('HELLO')      // true
'Hello World'.containsIgnoreCase('lo wo') // true
'Hello'.startsWithIgnoreCase('HE')     // true
'Hello'.endsWithIgnoreCase('LO')       // true
'Hello'.swapCase                       // 'hELLO'
```

### Padding & shaping

```dart
'example.com'.ensurePrefix('https://') // 'https://example.com'
'path'.ensureSuffix('/')               // 'path/'
'ok'.padCenter(6, '-')                 // '--ok--'
'a\nb'.indent(2)                       // '  a\n  b'
'a\nb'.indent(0, prefix: '> ')         // '> a\n> b'
'  a   b \n c '.normalizeWhitespace    // 'a b c'
'<p>Hi <b>there</b></p>'.stripHtmlTags // 'Hi there'
```

### Safe indexing

```dart
'abc'.charAtOrNull(1)        // 'b'
'abc'.charAtOrNull(9)        // null
'abc'.substringSafe(1, 99)   // 'bc'   — clamps instead of throwing
'abc'.substringSafe(-5)      // 'abc'
```

### Encoding & lenient parsing

```dart
'hello'.toBase64             // 'aGVsbG8='
'aGVsbG8='.fromBase64OrNull  // 'hello'
'not base64!!!'.fromBase64OrNull // null

'YES'.toBoolOrNull           // true   — accepts true/yes/y/on/1
'off'.toBoolOrNull           // false  — accepts false/no/n/off/0
'maybe'.toBoolOrNull         // null
```

### Fuzzy matching

```dart
'kitten'.levenshteinDistance('sitting') // 3
'colour'.similarityTo('color')          // 0.833...  (0..1)
```

### Nullable fallbacks (`StringNullableX`)

```dart
String? nickname;
nickname.ifBlank('Anonymous')  // 'Anonymous'
'   '.ifBlank('Anonymous')     // 'Anonymous'
'   '.ifEmpty('fallback')      // '   '  — whitespace is kept
```

### Validation (`StringValidation`)

```dart
'user@example.com'.isValidEmail       // true
'+12025551234'.isValidE164Phone       // true
'555-1234'.isValidPhone               // true  (7–15 digits after stripping)
'https://example.com'.isValidUrl      // true
'#FF5500'.isValidHexColor             // true
'192.168.0.1'.isValidIpv4            // true
'2001:db8::1'.isValidIpv6            // true
'192.168.0.1'.isValidIpAddress       // true
'2024-01-31'.isValidIsoDate          // true
'550e8400-e29b-41d4-a716-446655440000'.isValidUuid // true
'550e8400-e29b-11d4-a716-446655440000'.isValidUuidAny // true
'4111111111111111'.isValidCreditCard // true  (Luhn check)
'AA:BB:CC:DD:EE:FF'.isValidMacAddress // true
'hello-world'.isValidSlug            // true
'aGVsbG8='.isValidBase64             // true
'header.payload.signature'.isValidJwt // structure only, no signature verification
'John O\'Brien'.isValidName          // true
'Abc123!xyz'.isValidPassword         // true
'sreng.sun'.isValidUsername()        // true

// Password strength — returns set of unmet requirements
'weak'.passwordStrength   // {PasswordStrength.minLength, PasswordStrength.uppercase, ...}

// Length guard (protects against huge inputs)
'hello'.isWithinLength(min: 3, max: 10)  // true
```

### Date strings (`StringDateExtension`)

```dart
'2024-01-15'.isDate        // true
'2024-01-15'.isToday       // depends on today
'2020-01-01'.isPast        // true
'2099-12-31'.isFuture      // true
'2024-01-13'.isWeekend     // true  (Saturday)
'2024-01-15'.isWeekday     // true  (Monday)
'2024-01-01'.isLeapYear    // true

'2024-06-01'.isAfter('2024-01-01')    // true
'2024-01-01'.isBefore('2025-01-01')   // true
'2024-06-15'.isBetween('2024-01-01', '2024-12-31') // true
'2024-01-01'.isBetweenInclusive('2024-01-01', '2024-12-31') // true
'2024-03-15'.isSameDayAs('2024-03-15T12:00:00') // true
'2024-03-15'.daysUntil('2024-03-20') // 5
'2024-03-16'.differenceFrom('2024-03-15') // Duration(days: 1)
'2024-02-28'.addDays(1)              // '2024-02-29'
'2024-03-01'.subtractDays(1)         // '2024-02-29'
'2024-03-15'.toDateTimeOrNull        // DateTime(...)
'2024-03-15'.toIsoDateString         // '2024-03-15'
'2024-03-15'.year                    // 2024
```

---

## Iterable

### Numeric statistics (`IterableNumX` on `Iterable<num>`)

```dart
final nums = [3, 1, 4, 1, 5, 9, 2, 6];

nums.sum()          // 31
nums.product()      // 6480
nums.average        // 3.875
nums.median         // 3.5
nums.minOrNull      // 1
nums.maxOrNull      // 9
nums.modes          // [1]  (most frequent values)
nums.frequencyMap() // {3: 1, 1: 2, 4: 1, ...}
nums.range          // 8  (max - min)
nums.variance       // population variance
nums.stdDev         // population standard deviation
nums.sampleVariance // sample variance
nums.sampleStdDev   // sample standard deviation
nums.percentile(90) // interpolated percentile

nums.top(3)         // [9, 6, 5]  — descending
nums.bottom(3)      // [1, 1, 2]  — ascending

nums.clampAll(2, 7)            // [3, 2, 4, 2, 5, 7, 2, 6]
nums.normalize()               // [0.25, 0.0, 0.375, 0.0, 0.5, 1.0, 0.125, 0.625]
nums.normalizeTo(0, 100)       // [25.0, 0.0, 37.5, ...]
nums.deltas().toList()         // [-2, 3, -3, 4, 4, -7, 4]
nums.runningSum().toList()     // [3, 4, 8, 9, 14, 23, 25, 31]
nums.runningProduct().toList() // [3, 3, 12, 12, 60, 540, 1080, 6480]
nums.runningAverage().toList() // [3.0, 2.0, 2.66..., ...]

nums.allPositive    // true
nums.allNonNegative // true
nums.allNegative    // false
nums.anyPositive    // true
nums.anyNegative    // false
nums.anyZero        // false
nums.allZero        // false

// With empty-list safety
<int>[].sum()           // 0 (identity default)
<int>[].average         // null
<int>[].averageOrThrow  // throws StateError
<int>[].minOrNull       // null
<int>[].minOrThrow      // throws StateError
```

### General iterable (`IterableX`)

```dart
final words = ['apple', 'ant', 'banana', 'bear', 'cherry'];

// Group by first letter
words.groupBy((w) => w[0]);
// {'a': ['apple', 'ant'], 'b': ['banana', 'bear'], 'c': ['cherry']}

// Chunk into pages
[1, 2, 3, 4, 5].chunked(2).toList();
// [[1, 2], [3, 4], [5]]

// Distinct by derived key (preserves first-seen order)
['foo', 'bar', 'baz'].distinctBy((s) => s[0]).toList();
// ['foo', 'bar']

// flatMap
['hello', 'world'].flatMap((s) => s.split('').take(2)).toList();
// ['h', 'e', 'w', 'o']

['hello', null, 'world'].flatMapNotNull((s) => s?.split('')).toList();
// ['h','e','l','l','o','w','o','r','l','d']
```

### Flatten (`IterableOfIterablesX`)

```dart
[[1, 2], [3, 4], [5]].flatten().toList()    // [1, 2, 3, 4, 5]
[[1, 2], [3, 4], [5]].flattenToList()       // [1, 2, 3, 4, 5]
```

### Nullable filtering (`IterableNullableX`)

```dart
final values = ['a', null, 'b', null, 'c'];

values.whereNotNull.toList()   // ['a', 'b', 'c']
values.compact().toList()      // ['a', 'b', 'c']

values.compactMap((s) => s?.toUpperCase()).toList(); // ['A', 'B', 'C']
```

### Safe access & predicates (`IterableX`)

```dart
[1, 2, 3].firstOrNull          // 1
<int>[].firstOrNull            // null
[1, 2, 3].lastOrNull           // 3
[1, 2, 3].elementAtOrNull(9)   // null  (negative indices too)

[1, 2, 3].none((e) => e > 5)      // true
[1, 2, 3, 4].countWhere((e) => e.isEven) // 2
[1, 2, 3, 4].whereNot((e) => e.isEven)   // (1, 3)
['1', 'x', '3'].mapNotNull(int.tryParse) // (1, 3)
```

### Indexed variants

```dart
['a', 'b'].mapIndexed((i, e) => '$i:$e')  // ('0:a', '1:b')
[10, 20, 30].whereIndexed((i, _) => i.isEven) // (10, 30)
['a', 'b'].forEachIndexed((i, e) => print('$i $e'));
[10, 20].foldIndexed<int>(0, (i, acc, e) => acc + i * e); // 20
```

### Zipping

```dart
[1, 2, 3].zip(['a', 'b'])                      // ((1, 'a'), (2, 'b'))
[1, 2].zipWith(['a', 'b'], (n, s) => '$s$n')   // ('a1', 'b2')
```

### Ordering & aggregation by key

```dart
people.sortedBy((p) => p.age);            // new List, source untouched
people.sortedByDescending((p) => p.age);
[3, 1, 2].sortedWith((a, b) => b.compareTo(a)); // [3, 2, 1]

people.maxBy((p) => p.age);   // oldest, or null when empty
people.minBy((p) => p.age);   // youngest (first wins on ties)
people.sumBy((p) => p.age);   // 122
people.averageBy((p) => p.age); // 40.66..., or null when empty
```

### Rendering & splitting

```dart
[1, 2, 3].joinToString(prefix: '[', suffix: ']', separator: ' | ');
// '[1 | 2 | 3]'
[1, 2, 3, 4].joinToString(prefix: '[', suffix: ']', limit: 2);
// '[1, 2, ...]'
[1, 2].joinToString(transform: (e) => 'n$e'); // 'n1, n2'

[1, 2, 5, 6, 10].splitWhen((a, b) => b - a > 1);
// ([1, 2], [5, 6], [10])

[1, 2, 3].randomOrNull();               // random element, null when empty
[1, 2, 3].randomOrNull(Random(42));     // seeded, deterministic
```

---

## List

### Index-safe access (`ListX`)

```dart
final list = [1, 2, 3];

list.isValidIndex(3)            // false
list.getOrNull(9)               // null
list.getOrElse(9, (i) => -i)    // -9
```

### Reordering

```dart
final list = [1, 2, 3];
list.swap(0, 2);                // mutates -> [3, 2, 1]

[1, 2, 3].swapped(0, 2)         // [3, 2, 1]  — source untouched
['a', 'b', 'c'].moved(0, 2)     // ['b', 'c', 'a']
[1, 2, 3, 4].rotated(1)         // [2, 3, 4, 1]
[1, 2, 3, 4].rotated(-1)        // [4, 1, 2, 3]
[1, 2, 3].shuffled(Random(7))   // seeded copy, source untouched
```

### Transformation

```dart
[1, 2, 3, 4].replaceWhere((e) => e.isEven, (e) => e * 10); // [1, 20, 3, 40]
[3, 1, 3, 2, 1].distinct();     // [3, 1, 2]  — first-seen order
[1, 2, 3, 4].takeLast(2);       // [3, 4]
[1, 2, 3, 4].dropLast(2);       // [1, 2]
```

### Nullable lists (`ListNullableX`)

```dart
List<int>? items;
items.isNullOrEmpty;      // true
items.isNotNullOrEmpty;   // false
items.orEmpty;            // []
```

---

## Set

### Set algebra (`SetX`)

```dart
final selected = <int>{1, 2};

selected.toggle(3);                 // true  — added; mutates in place
selected.toggle(2);                 // false — removed
{1, 2}.toggled(3);                  // {1, 2, 3} — source untouched

{1, 2}.isSubsetOf({1, 2, 3});       // true
{1, 2, 3}.isSupersetOf({1, 2});     // true
{1, 2}.isProperSubsetOf({1, 2});    // false — equality excluded
{1, 2}.intersects([2, 5]);          // true
{1, 2}.isDisjointFrom([5, 6]);      // true
{1, 2, 3}.symmetricDifference({3, 4}); // {1, 2, 4}

final tags = <String>{'a'};
tags.addAllNew(['a', 'b', 'c']);    // {'b', 'c'} — only what was added
```

### Nullable sets (`SetNullableX`)

```dart
Set<int>? tags;
tags.isNullOrEmpty;     // true
tags.isNotNullOrEmpty;  // false
tags.orEmpty;           // {}
```

---

## Stream

### Operators (`StreamX`)

```dart
// Debounce — emits only after a quiet period (e.g. search input)
searchController.stream
    .debounce(const Duration(milliseconds: 300))
    .listen(runSearch);

// Throttle — emits the first event, suppresses the rest within the window
buttonTaps.throttle(const Duration(seconds: 1)).listen(submit);

// Distinct — skip repeated values
prefs.onChange
    .distinctUntilChanged()
    .listen(applySettings);

// Custom equality
stream
    .distinctUntilChanged((a, b) => a.id == b.id)
    .listen(update);

// Scan — accumulate state (like redux reduce)
clickStream
    .scan(0, (count, _) => count + 1)
    .listen((count) => print('Clicked $count times'));

// Skip until a condition is met, then pass all subsequent events
stream.skipUntil((v) => v > 10).listen(print);

// Take while (inclusive — includes the first failing value, then closes)
stream.takeWhileInclusive((v) => v < 100).listen(print);

// Indexed — enumerate events
stream.indexed.listen((pair) => print('${pair.$1}: ${pair.$2}'));

// Pairwise — compare consecutive events
prices.pairwise.listen((pair) {
  final delta = pair.$2 - pair.$1;
  print('Change: $delta');
});

// Error recovery
stream.onErrorReturn(0).listen(print);
stream.onErrorReturnWith((e) => -1).listen(print);

// Null filtering
Stream<int?>.value(null).whereNotNull<int>().listen(print); // skips null

// Last value as Future (null if stream closes empty)
final last = await stream.lastOrNull();

// First value as Future (null instead of a StateError when empty)
final first = await stream.firstOrNull();
```

### Batching, seeding & merging

```dart
// Batch events into fixed-size lists (the tail is flushed on close)
events.bufferCount(50).listen(batchUpload);

// Give a stream an initial value
state.startWith(initial).listen(render);
state.startWithMany([a, b]).listen(render);

// Interleave several sources; closes when all of them are done
socketA.mergeWith([socketB, socketC]).listen(handle);
```

### Side effects & filtering

```dart
stream
    .doOnData((v) => log('got $v'))     // observe, don't modify
    .doOnError((e, st) => report(e))    // observe, error still propagates
    .doOnDone(() => log('closed'))
    .listen(handle);

stream.mapNotNull(int.tryParse).listen(print); // drops unparsable events
stream.whereNot((v) => v.isEmpty).listen(print);
stream.ignoreErrors().listen(print);           // errors dropped, data kept
```

### List stream operators (`StreamListX`)

```dart
final itemsStream = Stream<List<int>>.value([3, 1, 4, 1, 5]);

itemsStream.lengths.listen(print);              // 5
itemsStream.whereNotEmpty.listen(print);        // passes [3,1,4,1,5], skips []
itemsStream.filter((n) => n > 2).listen(print); // [3, 4, 5]
itemsStream.mapItems((n) => n * 2).listen(print); // [6, 2, 8, 2, 10]
itemsStream.flatMapItems((n) => [n, -n]).listen(print); // [3,-3,1,-1,4,-4,1,-1,5,-5]
itemsStream.sortedBy((a, b) => a.compareTo(b)).listen(print); // [1,1,3,4,5]
itemsStream.flatten().listen(print);            // 3, 1, 4, 1, 5  (individual ints)
```

---

## Map

### Functional filtering, mapping, inverting, and merging (`MapX`)

```dart
final map = {'a': 1, 'b': 2, 'c': 3};

map.whereKeys((k) => k != 'b');                      // {'a': 1, 'c': 3}
map.whereValues((v) => v.isEven);                    // {'b': 2}
map.where((k, v) => k == 'a' || v == 3);             // {'a': 1, 'c': 3}

map.mapKeys((k, v) => k.toUpperCase());              // {'A': 1, 'B': 2, 'C': 3}
map.mapValues((k, v) => v * 10);                     // {'a': 10, 'b': 20, 'c': 30}

map.invert();                                       // {1: 'a', 2: 'b', 3: 'c'}
map.merge({'b': 20, 'd': 4}, combine: (a, b) => a + b); // {'a': 1, 'b': 22, 'c': 3, 'd': 4}

// Nullable values
final mapWithNulls = <String, int?>{'a': 1, 'b': null};
mapWithNulls.whereNotNullValues;                    // {'a': 1}
mapWithNulls.compact();                             // same
```

### Nullable Map helpers (`MapNullableX`)

```dart
Map<String, int>? nullMap;
nullMap.isNullOrEmpty;        // true
nullMap.isNotNullOrEmpty;     // false
nullMap.orEmpty;              // {}
```

---

## DateTime

### Calendar boundaries & relative getters (`DateTimeX`)

```dart
final now = DateTime.now();

now.isToday;              // true
now.isYesterday;          // false
now.isTomorrow;           // false
now.isWeekend;            // true / false
now.isLeapYear;           // true if leap year

now.startOfDay;           // YYYY-MM-DD 00:00:00.000
now.endOfDay;             // YYYY-MM-DD 23:59:59.999999
now.startOfWeek();        // Monday 00:00:00
now.endOfWeek();          // Sunday 23:59:59.999999
now.startOfMonth;         // 1st of month 00:00:00
now.endOfMonth;           // last day of month 23:59:59.999999

now.nextDay;              // tomorrow start of day
now.previousDay;          // yesterday start of day

final birthday = DateTime(1995, 8, 15);
birthday.age();           // e.g. 30

final updated = now.copyWith(year: 2025, month: 12);
```

### Calendar facts

```dart
DateTime(2024, 2, 10).daysInMonth  // 29
DateTime(2024, 3, 1).dayOfYear     // 61
DateTime(2024, 6, 15).weekOfYear   // 24  (ISO 8601)
DateTime(2024, 5, 1).quarter       // 2

DateTime(2000).isPast              // true
DateTime(2999).isFuture            // true
```

### More boundaries

```dart
final now = DateTime.now();

now.startOfMinute;   // seconds and below zeroed
now.startOfHour;     // :00:00.000000
now.endOfHour;       // :59:59.999999
now.startOfQuarter;  // first day of Q1/Q2/Q3/Q4
now.endOfQuarter;
now.startOfYear;     // Jan 1 00:00:00
now.endOfYear;       // Dec 31 23:59:59.999999
```

UTC inputs produce UTC results.

### Same-period comparison

```dart
DateTime(2024, 5, 1).isSameMonth(DateTime(2024, 5, 31)); // true
DateTime(2024, 1, 1).isSameYear(DateTime(2024, 12, 31)); // true
DateTime(2024, 1, 1).isSameWeek(DateTime(2024, 1, 7));   // true
```

### Calendar arithmetic

```dart
// Month/year math that clamps instead of overflowing
DateTime(2024, 1, 31).addMonths(1);      // 2024-02-29
DateTime(2024, 12, 15).addMonths(1);     // 2025-01-15
DateTime(2024, 3, 31).subtractMonths(1); // 2024-02-29
DateTime(2024, 2, 29).addYears(1);       // 2025-02-28
DateTime(2024, 2, 29).subtractYears(1);  // 2023-02-28

// Whole calendar days — ignores the time of day, DST-safe
DateTime(2024, 3, 15, 23).daysUntil(DateTime(2024, 3, 20, 1)); // 5

// Weekdays only
DateTime(2024, 1, 5).businessDaysUntil(DateTime(2024, 1, 8)); // 1
DateTime(2024, 1, 5).addBusinessDays(1);   // Monday 2024-01-08
DateTime(2024, 1, 8).addBusinessDays(-1);  // Friday 2024-01-05

// Strictly the next/previous occurrence, never the same day
DateTime(2024, 1, 1).nextWeekday(DateTime.monday);     // 2024-01-08
DateTime(2024, 1, 3).previousWeekday(DateTime.monday); // 2024-01-01
```

### Formatting

```dart
final moment = DateTime(2024, 3, 5, 9, 7, 3);

moment.toDateString();                      // '2024-03-05'
moment.toTimeString();                      // '09:07:03'
moment.toTimeString(withSeconds: false);    // '09:07'
moment.toDateTimeString();                  // '2024-03-05 09:07:03'

// Relative phrasing — pass `clock` to make it deterministic in tests
moment.toRelativeString(clock: DateTime(2024, 3, 5, 12)); // '3 hours ago'
DateTime(2024, 3, 8).toRelativeString(clock: DateTime(2024, 3, 5)); // 'in 3 days'
```

### Nullable dates (`DateTimeNullableX`)

```dart
DateTime? maybe;
maybe.orNow;                  // DateTime.now()
maybe.orDate(DateTime(2024)); // 2024-01-01
maybe.toDateStringOrNull;     // null
maybe.isSameDayAs(other);     // false when either side is null
```

---

## Future & async

### Timeouts and recovery (`FutureX`)

```dart
await fetchProfile().timeoutOrNull(2.seconds);      // null if too slow
await fetchProfile().timeoutWith(2.seconds, cached); // fallback if too slow

await readCache().orNull();                // null on any error
await risky().onErrorReturn(fallback);
await risky().onErrorReturnWith((e, st) => recoverFrom(e));

// Turn a failure into data instead of a throw
final (value, error) = await risky().settled();
if (error != null) log(error);
```

### Chaining

```dart
await future.thenMap((v) => v * 2);   // terser `then` for sync transforms
await future.tap(print);              // observe, value passes through
await future.delayedBy(300.ms);       // hold the result back
```

### Async iteration (`IterableFutureX`)

```dart
// One at a time, in order — for rate limits and ordered writes
await ids.mapSequential(fetchUser);

// All at once
await urls.mapParallel(fetch);

// At most N in flight, results still in source order
await urls.mapConcurrent(fetch, concurrency: 4);

// Async filter
await files.whereAsync((f) => f.exists());
```

---

## Uri

### Accessors (`UriX`)

```dart
final uri = Uri.parse('https://www.example.com/docs/guide.pdf?page=2');

uri.isSecure;       // true
uri.isHttp;         // true
uri.domain;         // 'example.com'  — leading `www.` dropped
uri.fileName;       // 'guide.pdf'
uri.fileExtension;  // 'pdf'
uri.origin;         // https://www.example.com
```

### Immutable builders

```dart
Uri.parse('https://x.com/s?q=a').withQueryParameters({'page': 2, 'q': null});
// https://x.com/s?page=2          — null removes a key

Uri.parse('https://x.com/s').withQueryParameters({'tag': ['a', 'b']});
// https://x.com/s?tag=a&tag=b     — Iterable values repeat the key

Uri.parse('https://x.com/a?b=1&c=2').withoutQueryParameters(['b']);
// https://x.com/a?c=2

Uri.parse('https://x.com/a?b=1#frag').withoutQuery;
// https://x.com/a#frag

Uri.parse('https://api.dev/v1').appendPath(['users', '42']);
// https://api.dev/v1/users/42
```

### Nullable URIs (`UriNullableX`)

```dart
Uri? link;
link.isNullOrEmpty;  // true
link.orEmpty;        // ''
```

---

## Comparable

Range and ordering helpers for any self-comparable type — `String`,
`DateTime`, `Duration`, and your own `Comparable` implementations. Numeric
types are excluded by the bound because `num` already has these built in.

```dart
// Comparison operators DateTime and String don't ship with
DateTime(2024, 1, 1) < DateTime(2024, 6, 1);   // true
DateTime(2024, 6, 1) >= DateTime(2024, 6, 1);  // true
'a' < 'b';                                     // true

// Clamping
'm'.coerceIn('a', 'f');                        // 'f'
date.coerceIn(windowStart, windowEnd);
'a'.coerceAtLeast('c');                        // 'c'
'e'.coerceAtMost('c');                         // 'c'

// Range checks
'b'.isInRange('a', 'c');            // true  (inclusive)
'a'.isInRangeExclusive('a', 'c');   // false
date.isInRange(start, end);

// Pick an extreme
'a'.coerceMax('b');   // 'b'
'a'.coerceMin('b');   // 'a'
```

> Named `isInRange` rather than `isBetween`: `StringDateExtension.isBetween`
> already owns that name on `String` with date-parsing semantics, and the
> more specific extension always wins.

---

## Any object

### Scope functions (`ScopeFunctionsX`)

Available on every non-null value, so expression chains stay flat.

```dart
'hello'.let((s) => s.length);        // 5
User().also((u) => log('created $u')); // returns the user

'admin'.takeIf((s) => s.isNotEmpty); // 'admin'
''.takeUnless((s) => s.isEmpty);     // null

value.asOrNull<int>() ?? 0;          // safe cast, null on mismatch
```

### Null-aware helpers (`ObjectNullableX`)

```dart
String? name;

name.isNull;                          // true
name.isNotNull;                       // false
name.letOrNull((n) => n.length);      // null — transform skipped
name.alsoNotNull(print);              // side effect skipped, returns null
name.orElseGet(() => expensive());    // lazy default
```

These never shadow the per-type nullable extensions — `int?.orDefault`,
`bool?.orDefault`, `String?.orEmpty` and friends still resolve first.

