# gmana_utils hardening and extension

Date: 2026-08-13
Status: approved

## Goal

Fix confirmed correctness bugs in `packages/gmana_utils`, then extend the package
with additive API that fills genuine gaps. No existing public signature changes.

## Phase 1 findings

Baseline before any change: `dart analyze` clean, 120 tests pass.

Findings marked *confirmed* were reproduced with throwaway probe tests, not
inferred from reading.

### Critical

1. **`AsyncMemoizer.runOnce` runs the computation more than once** —
   `async_cache.dart:13`. `hasRun` reads `_completer.isCompleted`, which is
   `false` while the computation is in flight. Two concurrent calls both start
   it; the loser completes an already-completed completer, raising `StateError`
   inside `then`, which routes to `catchError`, which calls `completeError` on
   the same completed completer and produces an unhandled async error.
   *Confirmed: probe observed `runs=2`, expected `1`.*

2. **`retry` exponential backoff is unbounded and overflows** — `retry.dart:31`.
   `delay * (1 << (attempt - 1))` has no cap. Past attempt 64 the shift wraps
   negative. There is also no jitter, so concurrent callers retry in lockstep.
   *Confirmed: probe with `maxAttempts: 70` hit a 10-second timeout.*

### Warning

3. **CircuitBreaker half-open admits every concurrent caller** —
   `circuit_breaker.dart:85`. Half-open is meant to admit a single probe.
   *Confirmed: 5 concurrent calls all reached the failing dependency.*

4. **`Batcher.dispose()` does not latch** — `batcher.dart:91`. An `add()` after
   `dispose()` enqueues a future that never completes.

5. **`AsyncCache` zero-TTL entry is treated as valid** — `async_cache.dart:31`.
   `isExpired` uses `>` where it needs `>=`. *Confirmed.*

6. **`AsyncCache` grows without bound** — `async_cache.dart:41`. No max size, no
   eviction, no sweep of expired entries.

7. **Time is not injectable** — `RateLimiter`, `CircuitBreaker`, and `AsyncCache`
   hard-code `DateTime.now()`; four more classes hard-code `Timer`. Tests must
   sleep in real time, and finding 2 has no writeable regression test.

### Suggestion

8. ULIDs generated in the same millisecond do not sort; the spec's monotonic
   variant is not implemented. *Confirmed.*
9. `README.md:277` ULID diagram is wrong (claims a 48-bit timestamp and shows a
   28-character example; the code encodes 50 bits over 10 characters plus 16
   random, total 26).
10. Root `README.md:17` summarises the package as three features out of thirteen;
    `example/main.dart` exercises the same three.
11. `Result.capture` discards the `StackTrace`. Missing `fold`, `swap`, `filter`,
    `getOrThrow`, `fromNullable`, `mapBoth`.
12. `tryOrDefault` has no async counterpart although `tryOrNull` does.
13. `Debouncer.run` accepts only `void Function()`; `Throttler` has no trailing
    edge.
14. `Result` overlaps `Either`/`Try` in `gmana_functional` with no documented
    stance on which to use.

### Checked and cleared

`Batcher` recovers correctly when its timer fires mid-processing; `Lazy` retries
after a throwing factory; `RateLimiter` consuming a slot for a throwing action is
defensible; `Success`/`Failure` hashCode collisions across type arguments are
legal.

## Phase 2 design

### Time seam

Add `clock` as a runtime dependency and `fake_async` as a dev dependency; both
are already in the workspace lock as transitive dependencies of `test`, so
resolution is unaffected. Internal `DateTime.now()` becomes `clock.now()`.

No public signature changes. Tests wrap in `withClock`/`FakeAsync`, which turns
today's real-time sleeps into exact assertions and makes finding 2 testable.

Rejected alternatives: an optional `Now` parameter per constructor (adds surface
purely for testability and does nothing for the `Timer`-driven classes); a full
`TimeSource` abstraction (a new public concept for a benefit `clock` already
provides).

### Fixes

| Finding | Fix |
| --- | --- |
| 1 | Track a separate `_started` flag rather than inferring from `_completer.isCompleted`. |
| 2 | Saturating multiplier math so the shift cannot wrap negative. Opt-in `maxDelay`, `jitter`, `onRetry`. |
| 3 | Admit exactly one half-open probe; concurrent callers get `CircuitBreakerOpenException` with `remainingTimeout: Duration.zero`. |
| 4 | `_disposed` latch; post-dispose `add()` returns `Future.error(StateError)`. |
| 5 | `isExpired` uses `>=`. |
| 6 | Opt-in `maxEntries` with LRU eviction; `null` default preserves current behavior. |
| 7 | `clock.now()` as above. |

`retry.maxDelay` defaults to `null` (uncapped). Capping by default would silently
change behavior for callers relying on long backoffs, and with the default
`maxAttempts: 3` the multiplier never exceeds 4x — the unbounded symptom only
appears at absurd attempt counts. The overflow fix is unconditional; the cap is
opt-in.

### New API

New files `semaphore.dart`, `concurrency.dart`, `stream_extensions.dart`.

- `Semaphore` — counting, FIFO, with `withPermit`. Nothing in the package bounds
  concurrency today.
- `KeyedLock<K>` — serializes operations per key. Natural partner to `AsyncCache`.
- `mapConcurrent` / `forEachConcurrent` — order-preserving bounded-concurrency
  iteration, built on `Semaphore`.
- `GmanaStreamTimingX.debounce` / `.throttle` — `Stream` counterparts to the
  existing `Debouncer`/`Throttler`, so users need not add rxdart for these two.
- `Result`: `fold`, `swap`, `filter`, `getOrThrow`, `fromNullable`, `mapBoth`,
  and `captureWith` preserving the `StackTrace` that `capture` drops.
- `tryOrDefaultAsync`, `tryOrElse`.
- `ulidMonotonic()` on both generators — same-millisecond IDs increment the
  random suffix so they sort, per the ULID spec.
- `Debouncer.runAsync<T>()` returning `Future<T>`; `Throttler(trailing: true)`.
  Both additive; defaults unchanged.
- `AsyncCache`: `getIfPresent`, `set`, `length`, `keys`, `evictExpired`,
  `invalidateWhere`.
- `CircuitBreaker`: `onStateChange`, `failureCount`.

Deliberately not built: `Deferred` (it is `Completer` renamed) and timeout
helpers (they duplicate `Future.timeout`). Neither earns a slot.

### Testing

Every Critical and Warning finding gets a named regression test, written and
watched failing before its fix. Timing tests use `FakeAsync` and `withClock`.

### Documentation

Package README sections for each addition; the wrong ULID diagram corrected; root
README summary line made accurate; CHANGELOG entries; `example/main.dart`
expanded from three features to full coverage. A short note documents when to
reach for `Result` here versus `Either`/`Try` in `gmana_functional`.
