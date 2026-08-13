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
- [Stream timing extensions](#stream-timing-extensions)
- [IdGenerator](#idgenerator)
- [SecureIdGenerator](#secureidgenerator)
- [Lazy & ResettableLazy](#lazy--resettablelazy)
- [RateLimiter](#ratelimiter)
- [Semaphore & KeyedLock](#semaphore--keyedlock)
- [mapConcurrent & forEachConcurrent](#mapconcurrent--foreachconcurrent)
- [Retry](#retry)
- [tryOrNull & tryOrDefault](#tryornull--tryordefault)
- [Result](#result)
- [Result extensions](#result-extensions)
- [CircuitBreaker](#circuitbreaker)
- [AsyncCache & AsyncMemoizer](#asynccache--asyncmemoizer)
- [Batcher](#batcher)
- [Choosing between Result and gmana_functional](#choosing-between-result-and-gmana_functional)


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

| Method             | Description                                              |
| ------------------ | -------------------------------------------------------- |
| `run(action)`      | Resets the timer; `action` fires after the quiet period  |
| `runAsync(action)` | Same, but returns the action's eventual result           |
| `flush()`          | Runs any pending action immediately                      |
| `isPending`        | Whether an action is currently scheduled                 |
| `dispose()`        | Cancels any pending timer immediately                    |

> **Ownership**: you own the `Debouncer` — always call `dispose()` when done.

### Awaiting the result

`runAsync` returns whatever the debounced action produces. Only the final call
of a burst runs; every superseded call — and anything still pending at
`dispose()` — completes with a `DebouncedException` rather than hanging.

```dart
final _debouncer = Debouncer(milliseconds: 300);

Future<void> onQueryChanged(String query) async {
  try {
    final results = await _debouncer.runAsync(() => search(query));
    setState(() => _results = results);
  } on DebouncedException {
    // A newer keystroke took over. Nothing to do.
  }
}
```

Errors thrown by the action itself surface normally, so a `catch` still sees a
genuine search failure. A superseded future you never await will not raise an
unhandled async error.

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

| Parameter      | Type   | Default                          |
| -------------- | ------ | -------------------------------- |
| `milliseconds` | `int`  | `kDefaultThrottleDuration` (300) |
| `trailing`     | `bool` | `false`                          |

### API

| Method             | Description                                                          |
| ------------------ | -------------------------------------------------------------------- |
| `run(action)`      | Runs `action` immediately if idle; suppressed within the active window |
| `isActive`         | Whether a cooldown window is currently open                          |
| `hasPendingAction` | Whether a trailing action is waiting                                 |
| `dispose()`        | Cancels the active window timer and drops any trailing action        |

### Trailing edge

By default a suppressed action is dropped outright, so the **last** event of a
burst never runs. Enable `trailing` to run the most recent suppressed action
when the window closes.

```dart
final throttler = Throttler(milliseconds: 100, trailing: true);

throttler..run(() => print('a'))   // runs now
         ..run(() => print('b'))   // suppressed
         ..run(() => print('c'));  // suppressed, but retained

// 'a' immediately, then 'c' at the 100 ms mark. 'b' never runs —
// only the most recent suppressed action is kept.
```

A trailing run opens the next window itself, so a continuous stream is shaped
to one action per window rather than two.

### Debounce vs Throttle at a glance

| Behavior           | `Debouncer`                            | `Throttler`                       |
| ------------------ | -------------------------------------- | --------------------------------- |
| When does it fire? | After the **last** call + quiet period | On the **first** call immediately |
| Rapid calls        | Only the last survives                 | First fires; rest are dropped     |
| Good for           | Search fields, resize handlers         | Scroll events, button guards      |

---

## Stream timing extensions

`Debouncer` and `Throttler` shape **callbacks**. When the events already arrive
as a `Stream`, use `debounce` and `throttle` directly — no rxdart dependency
needed for these two operators.

```dart
searchQueries
    .debounce(const Duration(milliseconds: 300))
    .listen(performSearch);

scrollOffsets
    .throttle(const Duration(milliseconds: 100))
    .listen(updateHeader);
```

### `debounce`

Emits an event only after `duration` passes with no further events. A burst
collapses to a single emission carrying the burst's **last** value.

If the source closes while an event is still pending, that event is emitted
before the done signal rather than dropped — so the final value of a stream
that ends mid-burst is not lost.

### `throttle`

Emits the first event of each window and drops the rest. Pass `trailing: true`
to also emit the most recent dropped event when the window closes; a window
during which nothing was dropped emits nothing extra.

```dart
events.throttle(const Duration(milliseconds: 100), trailing: true);
```

### Error handling

Both operators forward errors immediately. An error does not reset a debounce
timer and does not open or close a throttle window, so a failing event cannot
delay or suppress a legitimate one.

| Operator     | Emits                         | On source close       |
| ------------ | ----------------------------- | --------------------- |
| `debounce`   | Last event of a quiet burst   | Flushes pending event |
| `throttle`   | First event of each window    | Flushes trailing event |

Both throw `ArgumentError` for a non-positive duration.

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
01HGZQ3K4M        XNP8VWRY2STJF0C7
──────────        ────────────────
10 chars          16 chars
timestamp         random
(50 bits encoded) (80 bits)
```

- The timestamp part makes ULIDs **lexicographically sortable** by creation time.
- 26 characters, no hyphens — fits neatly in a `VARCHAR(26)` or URL path segment.
- ULIDs generated within the same millisecond differ only in the random
  suffix, so they **do not** sort against each other. Use
  [`ulidMonotonic()`](#ulidmonotonic) when order within a millisecond matters.

> Uses `Random` (not `Random.secure()`). For security-sensitive ULIDs use `SecureIdGenerator.ulid()`.

---

### `ulidMonotonic`

Like `ulid()`, but guarantees each ID sorts strictly after the previous one —
including within the same millisecond, where plain `ulid()` re-randomises the
suffix and produces arbitrary order.

```dart
final ids = List.generate(3, (_) => IdGenerator.ulidMonotonic());
// Already ascending, even though all three share a millisecond:
// ['01HGZQ3K4MXNP8VWRY2STJF0C7',
//  '01HGZQ3K4MXNP8VWRY2STJF0C8',
//  '01HGZQ3K4MXNP8VWRY2STJF0C9']
```

Within a millisecond the 80-bit suffix is incremented rather than redrawn. If
the system clock moves backwards, the generator holds its previous position so
the sequence stays ascending.

Monotonicity is **per generator instance**: `IdGenerator` and
`SecureIdGenerator` keep separate sequences, and separate processes are not
coordinated with each other.

> Because consecutive IDs in one millisecond differ by an increment, they are
> predictable relative to each other. Use `nanoid()` or `prefixed()` where each
> value must be independently unguessable — even under `SecureIdGenerator`.

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

## Semaphore & KeyedLock

`RateLimiter` bounds calls *per unit time*. `Semaphore` bounds how many run
*at once* — the limit that matters for connection pools, file handles, and
APIs that reject concurrent bursts.

```dart
final uploads = Semaphore(3);

await Future.wait([
  for (final file in files) uploads.withPermit(() => upload(file)),
]);
// At most three uploads in flight at any moment.
```

Permits are handed to waiters in **FIFO order**, so a long queue cannot starve
its earliest members. Prefer `withPermit` over a manual `acquire`/`release`
pair — it releases the permit even when the action throws, including a
synchronous throw.

| Member                | Description                                          |
| --------------------- | ---------------------------------------------------- |
| `permits`             | Configured maximum                                   |
| `available`           | Permits currently free                               |
| `queueLength`         | Callers waiting                                      |
| `acquire()`           | Takes a permit, waiting if none is free              |
| `release()`           | Returns a permit                                     |
| `withPermit(action)`  | Runs `action` holding a permit, releasing after      |

`release()` throws `StateError` if it would push free permits above `permits`,
which means a release was not paired with an acquire.

### KeyedLock

Serializes work **per key** while letting different keys run concurrently.

```dart
final lock = KeyedLock<String>();

// Concurrent writes to one account are serialized; writes to different
// accounts still overlap.
await lock.synchronized(accountId, () => applyTransaction(accountId, delta));
```

Key state is dropped once no operation holds it, so a long-lived lock over
high-cardinality keys does not leak. Pairs naturally with `AsyncCache` when a
cache miss triggers an expensive load that must not run twice.

---

## mapConcurrent & forEachConcurrent

Bounded-concurrency iteration. `Future.wait` starts *everything* at once;
these start at most `concurrency` at a time.

```dart
// Fetch 200 users without hammering the API with 200 simultaneous requests.
final users = await mapConcurrent(
  userIds,
  (id) => api.fetchUser(id),
  concurrency: 8,
);
```

`mapConcurrent` returns results in **input order**, regardless of the order in
which individual conversions complete.

```dart
await forEachConcurrent(pendingJobs, (job) => job.run(), concurrency: 4);
```

| Parameter     | Type  | Default |
| ------------- | ----- | ------- |
| `concurrency` | `int` | `4`     |

**Error behavior**: the first error stops new work from starting. The returned
future completes with that error — carrying its original stack trace — once
already-started work has settled. Both throw `ArgumentError` for a
non-positive `concurrency`.

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

### Parameters

| Parameter               | Type        | Default  | Description                                     |
| ----------------------- | ----------- | -------- | ----------------------------------------------- |
| `maxAttempts`           | `int`       | `3`      | Includes the initial call                       |
| `delay`                 | `Duration`  | `500 ms` | Base wait between attempts                      |
| `useExponentialBackoff` | `bool`      | `true`   | Doubles the wait after each failure             |
| `maxDelay`              | `Duration?` | `null`   | Caps how large a single wait can grow            |
| `jitter`                | `bool`      | `false`  | Randomizes each wait into `[0, computedDelay]`  |
| `retryIf`               | predicate   | `null`   | Decides whether an error is worth retrying      |
| `onRetry`               | callback    | `null`   | Notified after each attempt that will be retried |

### Capping the backoff

Without `maxDelay` the exponential curve is uncapped. That is harmless at the
default 3 attempts, but grows absurd quickly: attempt 30 from a 500 ms base
waits roughly **8,500 years**. Set `maxDelay` whenever `maxAttempts` is raised.

```dart
await retry(
  () => fetchApiData(),
  maxAttempts: 10,
  delay: const Duration(milliseconds: 200),
  maxDelay: const Duration(seconds: 5),   // 0.2s, 0.4s, 0.8s … 5s, 5s, 5s
);
```

### Jitter

Clients that fail together retry together, re-creating the load that caused the
failure. `jitter: true` applies full jitter — each wait becomes a random
duration in `[0, computedDelay]` — spreading retries out.

```dart
await retry(() => fetchApiData(), maxAttempts: 5, jitter: true);
```

### Observing retries

```dart
await retry(
  () => fetchApiData(),
  onRetry: (attempt, error, nextDelay) {
    log.warning('Attempt $attempt failed: $error. Retrying in $nextDelay.');
  },
);
```

`attempt` is the 1-based number of the attempt that just failed. `onRetry` is
not called after the final attempt, since nothing follows it.

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
final port = await tryOrDefaultAsync(() => readPortFromConfig(), 8080);
```

`tryOrNull` and `tryOrDefault` discard the error entirely. When the recovery
needs to know what went wrong, `tryOrElse` hands it the error *and* its stack
trace:

```dart
final config = tryOrElse(
  () => parseConfig(raw),
  (error, stackTrace) {
    log.warning('Falling back to defaults', error, stackTrace);
    return Config.defaults();
  },
);

final remote = await tryOrElseAsync(
  () => fetchRemoteConfig(),
  (error, stackTrace) async => loadCachedConfig(),
);
```

| Function            | Recovery                          | Sync/Async |
| ------------------- | --------------------------------- | ---------- |
| `tryOrNull`         | `null`                            | sync       |
| `tryOrNullAsync`    | `null`                            | async      |
| `tryOrDefault`      | A fixed value                     | sync       |
| `tryOrDefaultAsync` | A fixed value                     | async      |
| `tryOrElse`         | Computed from error + stack trace | sync       |
| `tryOrElseAsync`    | Computed from error + stack trace | async      |

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

### Core API

| Method                          | Semantics                                                    |
| ------------------------------- | ------------------------------------------------------------ |
| `isSuccess` / `isFailure`       | Branch tests                                                 |
| `valueOrNull` / `errorOrNull`   | Nullable access to either branch                             |
| `getOrElse(fallback)`           | Success value, or a fixed fallback                           |
| `getOrThrow()`                  | Success value, or throws the error                           |
| `map` / `mapError` / `mapBoth`  | Transform one branch, the other, or whichever is present     |
| `flatMap(fn)`                   | Chain into another `Result`                                  |
| `filter(predicate, orElse:)`    | Demote a success failing the predicate into a failure        |
| `swap()`                        | Exchange the success and failure branches                    |
| `when(...)` / `fold(...)`       | Collapse both branches into one value                        |

### Capturing failures

```dart
// Discards the stack trace.
final quick = Result.capture(() => parseData());

// Keeps it — the mapper receives both error and stack trace.
final detailed = Result.captureWith<Config, String>(
  () => parseConfig(raw),
  (error, stackTrace) => 'Invalid config: $error',
);

final remote = await Result.captureAsyncWith<Data, String>(
  () => fetchData(),
  (error, stackTrace) => 'Fetch failed: $error',
);
```

### Working with nullables

```dart
final user = Result.fromNullable<User, String>(
  cache[id],
  () => 'No cached user for $id',
);
```

### getOrThrow

Throws an `Exception` or `Error` as-is, preserving its type for `catch`
clauses. Any other error type is wrapped in a `StateError` describing it,
rather than throwing a bare value that callers would struggle to handle.

```dart
Result<int, Object>.failure(StateError('boom')).getOrThrow(); // throws StateError
Result<int, String>.failure('bad input').getOrThrow();        // throws StateError('Result was a failure: bad input')
```

Prefer `getOrElse` or `when` where a throw is not wanted.

### fold and filter

```dart
final label = result.fold(
  onSuccess: (port) => 'Listening on $port',
  onFailure: (error) => 'Cannot start: $error',
);

final port = parsed.filter(
  (value) => value > 0 && value < 65536,
  orElse: (value) => '$value is not a valid port',
);
```

`filter` leaves an existing failure untouched and does not run the predicate.

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

### States

| State      | Behavior                                                          |
| ---------- | ----------------------------------------------------------------- |
| `closed`   | Calls pass through; consecutive failures accumulate               |
| `open`     | Calls fail immediately without touching the dependency            |
| `halfOpen` | A **single** trial call is admitted to test recovery              |

After `resetTimeout` an open circuit moves to half-open. Only one trial call
runs at a time — concurrent callers get a `CircuitBreakerOpenException` with a
`remainingTimeout` of zero. This is the point of half-open: a recovering
dependency receives one probe, not the full concurrent load.

A successful trial (or `halfOpenSuccessThreshold` of them) closes the circuit;
a failed trial re-opens it.

### Observability

```dart
final breaker = CircuitBreaker(
  failureThreshold: 3,
  onStateChange: (state) => metrics.recordCircuitState(state),
);

print(breaker.failureCount); // consecutive failures so far
```

| Member          | Description                                     |
| --------------- | ----------------------------------------------- |
| `state`         | Current state, re-evaluating the reset timeout  |
| `isClosed` / `isOpen` / `isHalfOpen` | State predicates            |
| `failureCount`  | Consecutive failures since the last success     |
| `onStateChange` | Called on each actual transition                |
| `reset()`       | Manually returns the circuit to `closed`        |

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

`AsyncMemoizer` runs its computation **exactly once**, including for callers
that arrive while the first run is still in flight — they share the single run
rather than starting their own.

### Cache API

| Method                       | Description                                            |
| ---------------------------- | ------------------------------------------------------ |
| `get(key, ifAbsent:)`        | Cached value, loading it on a miss                     |
| `getIfPresent(key)`          | Cached value or `null` — never loads                   |
| `set(key, value)`            | Stores a value directly; its TTL starts now            |
| `invalidate(key)`            | Drops one key                                          |
| `invalidateWhere(test)`      | Drops every matching key; returns how many             |
| `evictExpired()`             | Drops every expired entry; returns how many            |
| `clear()`                    | Drops everything, including in-flight bookkeeping      |
| `containsKey(key)`           | Whether a live (unexpired) entry exists                |
| `length` / `keys`            | Current size and keys, least to most recently used     |

Concurrent misses for the same key share one in-flight request, so a cold cache
under load issues a single load per key rather than one per caller.

### Bounding memory

Expired entries are otherwise only dropped when their key is read again — a key
never read again is retained indefinitely. Two ways to bound this:

```dart
// Hard cap: evicts the least recently used entry past the limit.
final cache = AsyncCache<String, User>(maxEntries: 500);

// Or sweep periodically.
Timer.periodic(const Duration(minutes: 5), (_) => cache.evictExpired());
```

Reads through `get` and `getIfPresent` count as uses for LRU ordering.

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

A batch flushes when it reaches `maxBatchSize` or when `maxDelay` elapses,
whichever comes first. The handler must return exactly one result per input, in
the same order; a length mismatch fails every future in that batch.

| Member          | Description                                             |
| --------------- | ------------------------------------------------------- |
| `add(item)`     | Queues an item; resolves when its batch processes       |
| `flush()`       | Forces an immediate flush                               |
| `pendingCount`  | Items currently queued                                  |
| `isDisposed`    | Whether `dispose()` has been called                     |
| `dispose()`     | Cancels the timer and rejects queued futures            |

After `dispose()`, `add()` returns a failed future with a `StateError` rather
than a future that never completes.

---

## Choosing between Result and gmana_functional

This package's `Result` overlaps conceptually with `Either` and `Try` in
[`gmana_functional`](../gmana_functional). They are not interchangeable, and
which one to reach for depends on what you are modelling:

| Use                       | When                                                                 |
| ------------------------- | -------------------------------------------------------------------- |
| `Result<T, E>` (here)     | Success-or-failure where failure is an **expected outcome** you name — parse errors, validation, network failures. Pairs with `retry`, `CircuitBreaker`, and the async combinators in this package. |
| `Either<L, R>`            | A genuine sum type where neither side is "the error" — two equally valid alternatives. |
| `Try<T>`                  | Wrapping code that throws, where the error is always `Object` and you have no domain error type to map onto. |

`Result` is the right default inside this package's async workflows because
every combinator here (`toResult`, `mapResult`, `sequenceResults`, and the rest)
is built on it. Reach for `gmana_functional` when the algebra matters more than
the workflow.
