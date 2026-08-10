## Unreleased

- Added lazy recovery and branch inspection extensions for `Result`:
  `getOrElseGet`, `recover`, `recoverWith`, `inspectSuccess`, and
  `inspectFailure`.
- Added asynchronous Result composition with `mapAsync`, `flatMapAsync`,
  `mapResult`, `flatMapResult`, and `whenResult`.
- Added `Future.toResult` and `Future.toResultWith` for converting Future
  completions into typed Result values.
- Added `Iterable<Result>.sequenceResults` and `partitionResults` for
  aggregating fallible computations.
- Added `withRetry` on zero-argument synchronous and asynchronous callbacks.

## 0.0.1

- Initial
