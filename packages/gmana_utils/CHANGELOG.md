## Unreleased

### Fixed

- `AsyncMemoizer.runOnce` ran its computation once per concurrent caller
  instead of once in total, because `hasRun` inferred "started" from
  `_completer.isCompleted`, which is `false` while the computation is in
  flight. The losing caller then completed an already-completed completer,
  raising a `StateError` that surfaced as an unhandled async error. `hasRun`
  now reports whether the computation has *started*, matching its
  documentation, and a synchronous throw from the computation is handled.
- `CircuitBreaker` admitted every concurrent caller while half-open, sending a
  recovering dependency the full load rather than a single probe. Only one
  trial call now runs at a time; others get a `CircuitBreakerOpenException`
  with a zero `remainingTimeout`.
- `Batcher.dispose()` did not latch, so a later `add()` returned a future that
  never completed. Post-dispose adds now fail with a `StateError`.
- `AsyncCache` treated an entry as live at exactly its TTL, so a zero TTL never
  expired anything.

### Added

- Lazy recovery and branch inspection extensions for `Result`: `getOrElseGet`,
  `recover`, `recoverWith`, `inspectSuccess`, and `inspectFailure`.
- Asynchronous Result composition with `mapAsync`, `flatMapAsync`, `mapResult`,
  `flatMapResult`, and `whenResult`.
- `Future.toResult` and `Future.toResultWith` for converting Future completions
  into typed Result values.
- `Iterable<Result>.sequenceResults` and `partitionResults` for aggregating
  fallible computations.
- `withRetry` on zero-argument synchronous and asynchronous callbacks.
- `Semaphore` — FIFO counting semaphore with `withPermit`, which releases on
  both normal and exceptional exit.
- `KeyedLock<K>` — serializes operations per key while different keys run
  concurrently; key state is released once unheld.
- `mapConcurrent` and `forEachConcurrent` — bounded-concurrency iteration.
  `mapConcurrent` preserves input order regardless of completion order.
- `Stream.debounce` and `Stream.throttle` — stream counterparts to `Debouncer`
  and `Throttler`. `debounce` flushes a pending event when the source closes;
  `throttle` takes an optional trailing edge.
- `Result.fold`, `swap`, `mapBoth`, `filter`, `getOrThrow`, `fromNullable`,
  `captureWith`, and `captureAsyncWith`. The `captureWith` pair hands the stack
  trace to an error mapper instead of discarding it as `capture` does.
- `tryOrDefaultAsync`, `tryOrElse`, and `tryOrElseAsync`. The `tryOrElse` pair
  passes the error and its stack trace to the recovery.
- `retry` and `withRetry` gain `maxDelay`, `jitter`, and `onRetry`. Without
  `maxDelay` the exponential curve is uncapped — attempt 30 from the default
  500 ms base waits roughly 8,500 years — so set it whenever raising
  `maxAttempts`. The doubling now saturates rather than overflowing to a
  negative multiplier.
- `IdGenerator.ulidMonotonic` and `SecureIdGenerator.ulidMonotonic` — ULIDs
  that sort strictly ascending within a millisecond, which plain `ulid` does
  not do. Holds position if the system clock moves backwards.
- `Debouncer.runAsync` returns the debounced action's eventual result.
  Superseded and disposed calls complete with the new `DebouncedException`
  rather than hanging.
- `Throttler(trailing: true)` runs the most recent suppressed action when the
  window closes. Leading-only remains the default.
- `AsyncCache` gains `getIfPresent`, `set`, `length`, `keys`, `evictExpired`,
  `invalidateWhere`, and an optional `maxEntries` LRU bound. Expired entries
  were previously dropped only when their key was read again, so a key never
  read again was retained indefinitely.
- `CircuitBreaker` gains `failureCount` and `onStateChange`.
- `Batcher` gains `isDisposed` and `pendingCount`.

### Changed

- Depends on `package:clock`; internal `DateTime.now()` calls now go through
  `clock.now()`. No public signature changed. This lets timing behavior be
  tested exactly under `FakeAsync` instead of with wall-clock sleeps, which is
  how the half-open and TTL-boundary fixes above are verified.
- Corrected the ULID structure diagram in the README, which showed an
  18-character random suffix and a 48-bit timestamp for what is a 16-character
  suffix over a 10-character, 50-bit-encoded timestamp.

## 0.0.1

- Initial
