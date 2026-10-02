## Unreleased

### Added

- `GResult<T, E>`, `GSuccess`, and `GFailure`, with their combinators
  (`GmanaResultX`, `GmanaFutureToResultX`, `GmanaFutureResultX`,
  `GmanaIterableResultX`). The type moved here from `gmana_utils`, where it was
  named `Result`; it keeps the `G` prefix because this package already has
  `Result<T>` and `Failure`.
- `toResult`, `toEither`, `toResultAsync`, and `toEitherAsync` for converting
  between `Either` and `GResult`. They moved here from `gmana`.

## 0.0.2

Additive release — no existing member changed signature or behaviour.

### Either

- Static constructors: `Either.cond`, `Either.fromNullable`, `Either.sequence`,
  `Either.traverse`.
- Recovery: `orElse`, `orElseWith`, `recover`, `flatMapLeft`.
- Refinement: `filterOrElse` demotes a `Right` that fails a test.
- Combining: `zip`, `zipWith`.
- Conversion: `getOrDefault`, `toOption`, `toList`.

### Option

- Refinement: `filter`, `filterNot`, `isSomeAnd`.
- Fallback: `orElse`.
- Side effects: `tap`, `tapNone`.
- Combining: `zip`, `zipWith`.
- Conversion: `toList`.

### New extensions

- `FutureEitherX` on `Future<Either<L, R>>` — `map`, `mapLeft`, `flatMap`,
  `fold`, `getOrElse`, `getOrDefault`, `getOrNull`, `tap`, `tapLeft`,
  `orElseWith`, `isRight`, `isLeft`, so async chains no longer need
  intermediate `then` calls.
- `IterableEitherX` on `Iterable<Either<L, R>>` — `sequence`, `lefts`,
  `rights`, `partitionEithers`, `allRight`, `anyLeft`.
- `IterableOptionX` on `Iterable<Option<T>>` — `sequence`, `values`,
  `firstSome`.
- `NullableOptionX` on `T?` — `toOption`, the entry point from nullable Dart
  into the `Option` API.

### Failure & use cases

- `Failure.fromError` — wraps a caught error, usable directly as the `onError`
  callback of `Either.tryCatch`.
- `Failure.copyWith`, `withDetail`, `withDetails`, and typed `detail<T>`.
- `SyncUseCase<SuccessType, Params>` for business rules that complete without
  a `Future`.

### Docs

- README documents every addition and corrects two examples that would not
  compile: `Failure` takes positional arguments, not `code:`, and a subclass
  cannot combine `super.message` with an explicit `super(...)` call.

## 0.0.1

- Initial
