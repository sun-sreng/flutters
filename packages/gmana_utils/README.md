# gmana_utils

Pure Dart runtime utilities and composable extensions for fallible async
workflows, retries, caching, batching, rate limiting, timing, lazy values, and
ID generation.

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
- [tryOrNull & tryOrDefault](#tryornull--tryordefault)
- [Result](#result)
- [Result extensions](#result-extensions)
- [CircuitBreaker](#circuitbreaker)
- [AsyncCache & AsyncMemoizer](#asynccache--asyncmemoizer)
- [Batcher](#batcher)


---

## Debouncer

Delays execution until a quiet period has elapsed. Each call to `run()` resets the timer — only the **last** call fires.

Use this for search fields, resize handlers, or any input that fires faster than you want to react.

```dart
final defaultDebouncer = Debouncer();                   // 150 ms default
final customDebouncer = Debouncer(milliseconds: 300);  // custom window
```

### Quick start

```dart
final _search = Debouncer(milliseconds: 400);

void onSearchChanged(String query) {
  _search.run(() => performSearch(query));
}

// Only one API call fires — 400 ms after the user stops typing.
```

### Lifecycle

```dart
class _SearchState extends State<SearchPage> {
  final _debouncer = Debouncer(milliseconds: 400);

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
final defaultThrottler = Throttler();                   // 300 ms default
final customThrottler = Throttler(milliseconds: 500);  // custom window
```

### Quick start

```dart
final _save = Throttler(milliseconds: 1000);

void onSavePressed() {
  _save.run(() => saveDocument()); // fires immediately; next call within 1 s is ignored
}
```

### Scroll listener example

```dart
final _onScroll = Throttler(milliseconds: 100);

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

> **Deprecated**: `uuidV1()` remains as a compatibility alias for
> `uuidV4Like()`. New code should call `uuidV4Like()` directly.

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

Retries synchronous or asynchronous operations with optional exponential
backoff and an error predicate:

```dart
final data = await retry(
  () => fetchApiData(),
  maxAttempts: 3,
  delay: Duration(milliseconds: 500),
  useExponentialBackoff: true,
  retryIf: (e) => e is SocketException,
);
```

### Callback extension

`GmanaRetryFunctionX.withRetry()` offers the same behavior on a zero-argument
callback. The callback—not an already-running `Future`—is the receiver because
every attempt must start the operation again.

```dart
Future<void> main() async {
  var attempts = 0;

  Future<String> loadConfig() async {
    attempts++;
    if (attempts < 3) throw StateError('Config is not ready');
    return 'production';
  }

  final config = await loadConfig.withRetry(
    maxAttempts: 3,
    delay: const Duration(milliseconds: 100),
    useExponentialBackoff: false,
    retryIf: (error) => error is StateError,
  );

  print(config); // production
}
```

`maxAttempts` includes the initial call. Synchronous throws and failed futures
are both eligible for retry. The final error—or an error rejected by
`retryIf`—is rethrown. Delays occur only between attempts; with exponential
backoff enabled, the configured delay doubles after each failed attempt.

---

## tryOrNull & tryOrDefault

Exception-safe wrapper functions:

```dart
final number = tryOrNull(() => int.parse(rawInput)); // returns null on FormatException
final value = tryOrDefault(() => int.parse(rawInput), 0); // returns 0 on error
final asyncResult = await tryOrNullAsync(() => fetchUserData());
```

---

## Result

Type-safe success or failure monad:

```dart
final result = Result.capture(() => parseData());

switch (result) {
  case Success(:final value):
    print('Value: $value');
  case Failure(:final error):
    print('Error: $error');
}

final value = result.getOrElse(0);
final mapped = result.map((v) => v * 2);
```

---

## Result extensions

The named extensions `GmanaResultX`, `GmanaFutureToResultX`,
`GmanaFutureResultX`, and `GmanaIterableResultX` add lazy recovery,
branch-specific observation, asynchronous composition, Future conversion, and
collection aggregation. They preserve the original error type unless an API
explicitly maps it.

### Recover and observe a Result

```dart
final parsed = Result<int, String>.failure('missing port');

// The fallback runs only for Failure.
final port = parsed.getOrElseGet((error) => 8080);

final recovered = parsed
    .recover((error) => 8080)
    .inspectSuccess((value) => print('Using port $value'));

final recoveredFromBackup = parsed.recoverWith(
  (error) => Result<int, String>.success(8081),
);

parsed.inspectFailure((error) => print('Could not parse: $error'));
```

| Method                   | Semantics                                                                 |
| ------------------------ | ------------------------------------------------------------------------- |
| `getOrElseGet(fallback)` | Returns the success value; lazily calls `fallback` only for a failure     |
| `recover(transform)`     | Converts a failure into a success; leaves an existing success unchanged  |
| `recoverWith(transform)` | Replaces a failure with another `Result`; leaves a success unchanged      |
| `inspectSuccess(action)` | Runs `action` only for a success and returns the same result unchanged    |
| `inspectFailure(action)` | Runs `action` only for a failure and returns the same result unchanged    |
| `mapAsync(transform)`    | Maps a success with a sync or async callback and forwards a failure       |
| `flatMapAsync(transform)` | Chains a success into a sync or async `Result` and forwards a failure   |

Callbacks passed to these methods are not an error-catching boundary. If a
recovery or inspection callback throws, that exception reaches the caller. If
an async transform throws or returns a failed Future, the returned Future
completes with that error rather than producing a `Failure`.

```dart
final normalized = await Result<String, String>.success(' 8080 ')
    .mapAsync((text) async => text.trim());

final validated = await normalized.flatMapAsync<int>((text) async {
  final value = int.tryParse(text);
  return value == null
      ? Result<int, String>.failure('Not an integer')
      : Result<int, String>.success(value);
});
```

### Convert and compose Futures

Use `toResult()` to preserve a Future error as `Object`, or `toResultWith()` to
map the error and its original stack trace into a domain error.

```dart
Future<int> readCount() async => throw const FormatException('Bad count');

final untyped = await readCount().toResult();
// Result<int, Object> containing the FormatException as a Failure.

final typed = await readCount().toResultWith<String>(
  (error, stackTrace) => 'Unable to read count: $error',
);
// Result<int, String> containing the mapped message as a Failure.
```

`toResult()` and `toResultWith()` observe an already-created Future. If an
operation can throw before returning its Future, invoke it inside
`Result.captureAsync(() => operation())` instead. If the `toResultWith()` error
mapper throws, its new error completes the returned Future.

A `Future<Result<T, E>>` can be transformed without repeatedly awaiting and
unwrapping it:

```dart
final message = await Future.value(Result<int, String>.success(21))
    .mapResult((value) async => value * 2)
    .flatMapResult<String>(
      (value) => value == 42
          ? Result<String, String>.success('answer')
          : Result<String, String>.failure('unexpected value'),
    )
    .whenResult(
      onSuccess: (value) => 'Success: $value',
      onFailure: (error) => 'Failure: $error',
    );
```

| Receiver               | Method                           | Semantics                                                        |
| ---------------------- | -------------------------------- | ---------------------------------------------------------------- |
| `Future<T>`            | `toResult()`                     | Converts completion or error to `Result<T, Object>`              |
| `Future<T>`            | `toResultWith(mapError)`         | Maps an error and stack trace to `Result<T, E>`                   |
| `Future<Result<T, E>>` | `mapResult(transform)`           | Maps a successful value with a sync or async callback            |
| `Future<Result<T, E>>` | `flatMapResult(transform)`       | Chains a successful value into another sync or async `Result`    |
| `Future<Result<T, E>>` | `whenResult(onSuccess, onFailure)` | Resolves the Future and invokes exactly one branch callback     |

A failed source Future or an error thrown by a `mapResult`, `flatMapResult`, or
`whenResult` callback remains a Future error. Use `toResult()` or
`toResultWith()` when that error should become a `Failure`.

### Aggregate Result collections

```dart
final results = <Result<int, String>>[
  Result<int, String>.success(10),
  Result<int, String>.failure('bad row'),
  Result<int, String>.success(30),
];

final sequenced = results.sequenceResults();
// Result.failure('bad row')

final partition = results.partitionResults();
print(partition.successes); // [10, 30]
print(partition.failures);  // [bad row]
```

`sequenceResults()` consumes values in iteration order and stops at the first
failure. An empty iterable produces `Result.success(<T>[])`.
`partitionResults()` consumes the entire iterable once and returns new,
growable `successes` and `failures` lists that preserve the relative order of
each branch. For an empty iterable, both lists are empty.

---

## CircuitBreaker

Fault-tolerance circuit breaker for external services:

```dart
final breaker = CircuitBreaker(
  failureThreshold: 3,
  resetTimeout: Duration(seconds: 15),
);

try {
  final res = await breaker.run(() => fetchRemoteApi());
} on CircuitBreakerOpenException catch (e) {
  print('Circuit is OPEN! $e');
}
```

---

## AsyncCache & AsyncMemoizer

Key-value cache with TTL expiration and request deduplication:

```dart
final cache = AsyncCache<String, UserData>(
  defaultTtl: Duration(minutes: 10),
);

final user = await cache.get(
  'user_123',
  ifAbsent: () => fetchUserFromNetwork('user_123'),
);

// Single-run async memoizer
final memoizer = AsyncMemoizer<Config>();
final config = await memoizer.runOnce(() => loadConfigFromFile());
```

---

## Batcher

Aggregates individual calls into bulk requests based on size or delay:

```dart
final batcher = Batcher<int, String>(
  maxBatchSize: 50,
  maxDelay: Duration(milliseconds: 100),
  handler: (items) async => bulkFetchItems(items),
);

// Individual calls receive matching results when the batch processes
final itemFuture = batcher.add(42);
```
