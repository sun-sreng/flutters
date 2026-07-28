# gmana_utils

Pure Dart utilities for debouncing, throttling, and ID generation.

```dart
import 'package:gmana_utils/gmana_utils.dart';
```

---

## Table of contents

- [Debouncer](#debouncer)
- [Throttler](#throttler)
- [IdGenerator](#idgenerator)
- [SecureIdGenerator](#secureidgenerator)
- [Lazy & ResettableLazy](#lazy--resettablelazy)
- [RateLimiter](#ratelimiter)
- [Retry](#retry)
- [tryOrNull & tryOrDefault](#tryornull--tryodefault)

---

## Debouncer

Delays execution until a quiet period has elapsed. Each call to `run()` resets the timer — only the **last** call fires.

Use this for search fields, resize handlers, or any input that fires faster than you want to react.

```dart
final debouncer = Debouncer();          // 150 ms default
final debouncer = Debouncer(300);       // custom window
```

### Quick start

```dart
final _search = Debouncer(400);

void onSearchChanged(String query) {
  _search.run(() => performSearch(query));
}

// Only one API call fires — 400 ms after the user stops typing.
```

### Lifecycle

```dart
class _SearchState extends State<SearchPage> {
  final _debouncer = Debouncer(400);

  @override
  void dispose() {
    _debouncer.dispose(); // cancels any pending timer
    super.dispose();
  }

  void _onChanged(String q) => _debouncer.run(() => _fetch(q));
}
```

### Parameters

| Parameter      | Type  | Default                      |
| -------------- | ----- | ---------------------------- |
| `milliseconds` | `int` | `kDefaultDebounceTime` (150) |

### API

| Method        | Description                                             |
| ------------- | ------------------------------------------------------- |
| `run(action)` | Resets the timer; `action` fires after the quiet period |
| `dispose()`   | Cancels any pending timer immediately                   |

> **Ownership**: you own the `Debouncer` — always call `dispose()` when done.

---

## Throttler

Executes immediately on the first call, then **suppresses** subsequent calls for the duration of the window. The opposite of debounce — **run-first** semantics.

Use this for scroll listeners, button guards, or rapid-fire events where you want the first action to go through but subsequent duplicates dropped.

```dart
final throttler = Throttler();          // 300 ms default
final throttler = Throttler(500);       // custom window
```

### Quick start

```dart
final _save = Throttler(1000);

void onSavePressed() {
  _save.run(() => saveDocument()); // fires immediately; next call within 1 s is ignored
}
```

### Scroll listener example

```dart
final _onScroll = Throttler(100);

NotificationListener<ScrollNotification>(
  onNotification: (notification) {
    _onScroll.run(() => _updateHeader(notification.metrics.pixels));
    return false;
  },
  child: ListView(...),
)
```

### Lifecycle

```dart
@override
void dispose() {
  _throttler.dispose(); // clears the active window timer
  super.dispose();
}
```

### Parameters

| Parameter      | Type  | Default                          |
| -------------- | ----- | -------------------------------- |
| `milliseconds` | `int` | `kDefaultThrottleDuration` (300) |

### API

| Method        | Description                                                          |
| ------------- | -------------------------------------------------------------------- |
| `run(action)` | Runs `action` immediately if idle; no-op if within the active window |
| `dispose()`   | Cancels the active window timer                                      |

### Debounce vs Throttle at a glance

| Behavior           | `Debouncer`                            | `Throttler`                       |
| ------------------ | -------------------------------------- | --------------------------------- |
| When does it fire? | After the **last** call + quiet period | On the **first** call immediately |
| Rapid calls        | Only the last survives                 | First fires; rest are dropped     |
| Good for           | Search fields, resize handlers         | Scroll events, button guards      |

---

## IdGenerator

All-static class for generating various ID formats. No instantiation needed.

```dart
import 'package:gmana_utils/gmana_utils.dart';

final id = IdGenerator.nanoid();
```

> **Security notice**: `IdGenerator` uses Dart's non-cryptographic `Random`. It is safe for database primary keys, slugs, and display codes, but **not** for tokens, session keys, API keys, or password-reset links. Use [`SecureIdGenerator`](#secureidgenerator) for those cases.

---

### `nanoid`

Generates a URL-safe random string using the NanoID alphabet (`A–Za–z0–9_-`). Pass a custom `alphabet` to override the default character set.

```dart
IdGenerator.nanoid()                          // 21-character ID (default)
IdGenerator.nanoid(size: 10)                  // shorter ID
IdGenerator.nanoid(size: 36)                  // longer ID
IdGenerator.nanoid(size: 12, alphabet: '01')  // binary-style custom alphabet
```

```text
// Example outputs
// 'V1StGXR8_Z5jdHi6B-myT'
// 'K9vF2xQm3p'
// '010110011010'
```

| Parameter  | Type      | Default                       |
| ---------- | --------- | ----------------------------- |
| `size`     | `int`     | `21`                          |
| `alphabet` | `String?` | `null` (uses NanoID alphabet) |

---

### `randomString`

Generates a random string from a configurable character set.

```dart
// Default — letters, numbers, and symbols, length 8
IdGenerator.randomString()

// Numbers only, 6 digits (PIN-style)
IdGenerator.randomString(length: 6, useLetters: false, useNumbers: true, useSymbols: false)

// Letters only
IdGenerator.randomString(length: 12, useLetters: true, useNumbers: false, useSymbols: false)

// All character types, longer
IdGenerator.randomString(length: 20, useLetters: true, useNumbers: true, useSymbols: true)
```

| Parameter    | Type   | Default |
| ------------ | ------ | ------- |
| `length`     | `int`  | `8`     |
| `useLetters` | `bool` | `true`  |
| `useNumbers` | `bool` | `true`  |
| `useSymbols` | `bool` | `true`  |

---

### `shortId`

Generates a short URL-safe alphanumeric ID — letters and digits only, no symbols. Good for readable codes, invite links, and slugs.

```dart
IdGenerator.shortId()           // 8 characters (default)
IdGenerator.shortId(length: 12) // custom length
```

```text
// Example outputs
// 'aB3xK9mZ'
// 'Xk3mQ9vF2xQm'
```

| Parameter | Type  | Default |
| --------- | ----- | ------- |
| `length`  | `int` | `8`     |

---

### `prefixed`

Generates a prefixed ID in the style `prefix_<random>` — the same pattern used by Stripe (`cus_`, `pay_`, `inv_`) and similar APIs.

```dart
IdGenerator.prefixed('cus')              // 'cus_Xk3mQ9vF2xQm1234'
IdGenerator.prefixed('pay', length: 8)  // 'pay_aB3xK9mZ'
IdGenerator.prefixed('inv', length: 24) // 'inv_aB3xK9mZxK3mQ9vF2xQm12'
```

| Parameter | Type     | Default |
| --------- | -------- | ------- |
| `prefix`  | `String` | —       |
| `length`  | `int`    | `16`    |

The `prefix` must be non-empty. The random suffix contains only `[a-zA-Z0-9]`.

---

### `ulid`

Generates a **ULID** (Universally Unique Lexicographically Sortable Identifier) — a 26-character string that sorts chronologically.

```dart
final id = IdGenerator.ulid();
// '01HGZQ3K4MXNP8VWRY2STJF0C7'
```

**Structure** (Crockford Base32, `0–9 A–Z` excluding `I L O U`):

```text
01HGZQ3K4M  XNPF0CVWRY2STJF0C7
──────────  ────────────────────
10 chars    16 chars
timestamp   random (80 bits)
(48 bits)
```

- The timestamp part makes ULIDs **lexicographically sortable** by creation time.
- ULIDs generated within the same millisecond differ only in the random suffix.
- 26 characters, no hyphens — fits neatly in a `VARCHAR(26)` or URL path segment.

> Uses `Random` (not `Random.secure()`). For security-sensitive ULIDs use `SecureIdGenerator.ulid()`.

---

### `timestampId`

Generates a time-ordered ID prefixed with `G`, combining the current epoch milliseconds with a random hex suffix.

```dart
final id = IdGenerator.timestampId();
// 'G1716220800000-k9vF-2xQm3p4r'
```

Useful for document keys where insertion order matters (logs, events, audit trails).

---

### `uuidV4Like`

Generates a UUID v4-**shaped** string (`xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`). The format is correct but the randomness uses `Random`, **not** `Random.secure()` — do not rely on this for cryptographic uniqueness.

```dart
final id = IdGenerator.uuidV4Like();
// 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
```

For a cryptographically random UUID-shaped token use `SecureIdGenerator.uuidV4Like()`.

> **Deprecated**: `uuidV1()` has been removed — use `uuidV4Like()` instead.

---

### `encodeToBase64` / `decodeFromBase64`

Encodes a `List<Object?>` to a Base64 string via JSON, and decodes it back. Useful for embedding structured data in URLs or cookies. This is **encoding, not encryption** — the data is trivially reversible.

```dart
final token = IdGenerator.encodeToBase64(['user-123', 'admin', 1716220800]);
// 'WyJ1c2VyLTEyMyIsImFkbWluIiwxNzE2MjIwODAwXQ=='

final data = IdGenerator.decodeFromBase64(token);
// ['user-123', 'admin', 1716220800]
```

`decodeFromBase64` throws a `FormatException` if the payload is not a JSON array.

---

### ID format comparison

| Method           | Example output                         | Sortable | Length   | Use case                          |
| ---------------- | -------------------------------------- | -------- | -------- | --------------------------------- |
| `ulid()`         | `01HGZQ3K4MXNP8VWRY2STJF0C7`           | **yes**  | 26       | Primary keys, time-ordered events |
| `timestampId()`  | `G1716220800000-k9vF-2xQm3p4r`         | **yes**  | variable | Logs, audit trails                |
| `nanoid()`       | `V1StGXR8_Z5jdHi6B-myT`                | no       | 21       | Short unique keys, URLs           |
| `shortId()`      | `aB3xK9mZ`                             | no       | 8        | Invite codes, slugs               |
| `prefixed()`     | `cus_Xk3mQ9vF2xQm1234`                 | no       | variable | Domain-typed IDs (Stripe-style)   |
| `randomString()` | `aB3xK9mZ`                             | no       | 8        | PINs, OTPs, display codes         |
| `uuidV4Like()`   | `f47ac10b-58cc-4372-a567-0e02b2c3d479` | no       | 36       | UUID-expecting APIs               |
| `encodeToBase64` | `WyJ1c2VyLTEyMyIsImFkbWluIl0=`         | no       | variable | Structured data in URLs           |

---

## SecureIdGenerator

Cryptographically-secure variant of `IdGenerator`. Every method uses `Random.secure()` — backed by the operating-system CSPRNG — making output suitable for tokens, session keys, API keys, and password-reset links.

```dart
import 'package:gmana_utils/gmana_utils.dart';

// Generate a secure API key
final apiKey = SecureIdGenerator.prefixed('sk', length: 32);

// Verify it in constant time — never use ==
if (!SecureIdGenerator.safeEqual(received, stored)) {
  throw UnauthorizedException();
}
```

### IdGenerator vs SecureIdGenerator

| Question                                                            | Use                 |
| ------------------------------------------------------------------- | ------------------- |
| Is this ID ever transmitted to a client and verified server-side?   | `SecureIdGenerator` |
| Could an attacker gain anything by guessing this value?             | `SecureIdGenerator` |
| Is this just a database primary key or a display slug?              | `IdGenerator`       |
| Do I need the fastest possible generation with no security concern? | `IdGenerator`       |

> **Prefer `IdGenerator` for non-security IDs.** `Random.secure()` draws entropy from the OS; overusing it for display slugs or primary keys wastes that entropy unnecessarily.

---

### `SecureIdGenerator.nanoid`

Same signature as `IdGenerator.nanoid`. Output is suitable for one-time tokens and invite codes.

```dart
SecureIdGenerator.nanoid()                         // 21-char secure token
SecureIdGenerator.nanoid(size: 32)                 // longer token
SecureIdGenerator.nanoid(size: 16, alphabet: '01') // custom alphabet
```

| Parameter  | Type      | Default                       |
| ---------- | --------- | ----------------------------- |
| `size`     | `int`     | `21`                          |
| `alphabet` | `String?` | `null` (uses NanoID alphabet) |

---

### `SecureIdGenerator.randomString`

Same signature as `IdGenerator.randomString`. Suitable for generated passwords and OTPs.

```dart
// 12-character password with all character types
SecureIdGenerator.randomString(length: 12)

// 6-digit PIN
SecureIdGenerator.randomString(length: 6, useLetters: false, useNumbers: true, useSymbols: false)
```

| Parameter    | Type   | Default |
| ------------ | ------ | ------- |
| `length`     | `int`  | `8`     |
| `useLetters` | `bool` | `true`  |
| `useNumbers` | `bool` | `true`  |
| `useSymbols` | `bool` | `true`  |

---

### `SecureIdGenerator.shortId`

Same signature as `IdGenerator.shortId`. Suitable for one-time activation tokens and invite links.

```dart
SecureIdGenerator.shortId()           // 8-char secure alphanumeric token
SecureIdGenerator.shortId(length: 32) // longer token
```

| Parameter | Type  | Default |
| --------- | ----- | ------- |
| `length`  | `int` | `8`     |

---

### `SecureIdGenerator.prefixed`

Same signature as `IdGenerator.prefixed`. The secure choice for API keys.

```dart
SecureIdGenerator.prefixed('sk', length: 32)  // secret key:  'sk_Xk3mQ9...'
SecureIdGenerator.prefixed('pk', length: 32)  // public key:  'pk_aB3xK9...'
SecureIdGenerator.prefixed('tok', length: 24) // reset token: 'tok_mQ9vF2...'
```

| Parameter | Type     | Default |
| --------- | -------- | ------- |
| `prefix`  | `String` | —       |
| `length`  | `int`    | `16`    |

---

### `SecureIdGenerator.ulid`

Generates a ULID whose 80-bit random suffix uses `Random.secure()`. The 48-bit timestamp part is always deterministic (current millisecond).

```dart
final id = SecureIdGenerator.ulid();
// '01HGZQ3K4MXNP8VWRY2STJF0C7'
```

---

### `SecureIdGenerator.uuidV4Like`

Generates a UUID v4-shaped token whose bits are from `Random.secure()`. Use this when an external system requires UUID format but the value must be unpredictable.

```dart
final id = SecureIdGenerator.uuidV4Like();
// 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
```

---

### `SecureIdGenerator.safeEqual`

Compares two strings in **constant time** to prevent timing-based side-channel attacks.

```dart
final stored  = SecureIdGenerator.prefixed('tok', length: 24);
final received = getTokenFromRequest();

if (!SecureIdGenerator.safeEqual(received, stored)) {
  throw UnauthorizedException('Invalid token');
}
```

The loop always runs `max(a.length, b.length)` iterations regardless of where the strings first differ. This means an attacker cannot measure response time to learn the correct value character-by-character.

**Always use `safeEqual` — never `==` — when validating caller-supplied tokens.**

| Parameter | Type     |
| --------- | -------- |
| `a`       | `String` |
| `b`       | `String` |

Returns `true` only if `a` and `b` are identical. Case-sensitive.

---

### Secure ID format comparison

| Method                           | Suitable for                                      |
| -------------------------------- | ------------------------------------------------- |
| `SecureIdGenerator.prefixed`     | API keys, scoped tokens (`sk_…`, `pk_…`, `tok_…`) |
| `SecureIdGenerator.nanoid`       | Opaque one-time tokens, invite codes              |
| `SecureIdGenerator.shortId`      | Short activation codes, magic links               |
| `SecureIdGenerator.randomString` | Generated passwords, numeric OTPs                 |
| `SecureIdGenerator.uuidV4Like`   | UUID-format tokens for UUID-expecting systems     |
| `SecureIdGenerator.ulid`         | Time-ordered tokens with secure random suffix     |
| `SecureIdGenerator.safeEqual`    | Validating any of the above at verification time  |

---

## Lazy & ResettableLazy

Lazy value evaluation on demand:

```dart
final heavyConfig = Lazy(() => loadExpensiveConfig());

print(heavyConfig.isInitialized); // false
print(heavyConfig.value);         // evaluates and caches result

// ResettableLazy can be invalidated
final cache = ResettableLazy(() => fetchLatestFeed());
cache.value; // fetched
cache.reset(); // cleared; next .value call re-fetches
```

---

## RateLimiter

Sliding window call rate limiting:

```dart
final limiter = RateLimiter(
  maxRequests: 5,
  duration: Duration(minutes: 1),
);

if (limiter.canRun) {
  limiter.tryRun(() => sendAnalyticsEvent());
}
```

---

## Retry

Asynchronous operation retry with exponential backoff and jitter predicate:

```dart
final data = await retry(
  () => fetchApiData(),
  maxAttempts: 3,
  delay: Duration(milliseconds: 500),
  useExponentialBackoff: true,
  retryIf: (e) => e is SocketException,
);
```

---

## tryOrNull & tryOrDefault

Exception-safe wrapper functions:

```dart
final number = tryOrNull(() => int.parse(rawInput)); // returns null on FormatException
final value = tryOrDefault(() => int.parse(rawInput), 0); // returns 0 on error
final asyncResult = await tryOrNullAsync(() => fetchUserData());
```

