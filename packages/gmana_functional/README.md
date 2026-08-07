# gmana_functional

Pure Dart functional programming primitives for clean architecture.

```dart
import 'package:gmana_functional/gmana_functional.dart';
```

---

## Table of contents

- [Either](#either)
- [Collections of Either](#collections-of-either)
- [Async Either](#async-either)
- [Option](#option)
- [Collections of Option](#collections-of-option)
- [State](#state)
- [Try](#try)
- [Reader](#reader)
- [Result & type aliases](#result--type-aliases)
- [Failure](#failure)
- [Unit](#unit)
- [UseCase, SyncUseCase & StreamUseCase](#usecase-syncusecase--streamusecase)
- [NoParams](#noparams)
- [Patterns & recipes](#patterns--recipes)


---

## Either

`Either<L, R>` is a disjoint union with exactly two states:

| Side  | Class         | Convention      |
| ----- | ------------- | --------------- |
| Left  | `Left<L, R>`  | failure / error |
| Right | `Right<L, R>` | success / value |

### Construction

```dart
Either<String, int> ok    = const Right(42);
Either<String, int> fail  = const Left('Something went wrong');

// Catching exceptions into Either
final safe = Either.tryCatch<String, int>(
  () => int.parse(rawInput),
  (error, stack) => 'Parse failure: $error',
);
```

Three more constructors cover the shapes that come up most often:

```dart
// cond — branch on a boolean
Either.cond(age >= 18, () => 'Too young', () => age);

// fromNullable — lift a nullable value, naming the reason it may be absent
Either.fromNullable(map['id'], () => 'Missing id');

// sequence — collapse a collection, short-circuiting on the first Left
Either.sequence([Right(1), Right(2)]);           // Right([1, 2])
Either.sequence([Right(1), Left('bad'), Right(3)]); // Left('bad')

// traverse — map each element through a fallible function, then sequence
Either.traverse(['1', '2', 'x'], parseInt);      // Left('Not a number: x')
```

### Pattern matching — `fold`

The primary way to consume an `Either`. Always handles both sides.

```dart
final message = result.fold(
  (error) => 'Error: $error',
  (value) => 'Got: $value',
);

// Async variant
final message = await result.foldAsync(
  (error) async => await logAndFormat(error),
  (value) async => await render(value),
);
```

### Transformation

```dart
// map — transform Right, pass Left through unchanged
final doubled = Right<String, int>(21).map((n) => n * 2);  // Right(42)
final noop    = Left<String, int>('err').map((n) => n * 2); // Left('err')

// mapAsync
final upper = await result.mapAsync((s) async => s.toUpperCase());

// mapLeft — transform Left, pass Right through
final wrapped = Left<String, int>('oops').mapLeft((e) => Failure(e));

// flatMap — chain operations that also return Either
Either<String, int> parse(String s) =>
    int.tryParse(s) != null ? Right(int.parse(s)) : Left('Not a number');

Either<String, double> divide(int n) =>
    n == 0 ? Left('Division by zero') : Right(100 / n);

final result = parse('5').flatMap(divide); // Right(20.0)
final error  = parse('0').flatMap(divide); // Left('Division by zero')
final bad    = parse('x').flatMap(divide); // Left('Not a number')

// flatMapAsync
final result = await fetchUser(id).flatMapAsync(
  (user) async => await fetchProfile(user.profileId),
);

// bimap — transform both sides at once
final mapped = result.bimap(
  (err) => 'Failure: $err',
  (val) => val * 2,
);
```

### Extraction

```dart
// Safe — prefer fold or getOrElse in production code
result.rightOrNull()        // R? — null when Left
result.leftOrNull()         // L? — null when Right
result.getOrNull()          // alias for rightOrNull()
result.getOrElse((e) => 0)  // R — fallback computed from Left

// Unsafe — throw StateError on the wrong side
result.getRight()   // R  — throws if Left
result.getLeft()    // L  — throws if Right
```

### Predicates

```dart
result.isRight()         // true for Right
result.isLeft()          // true for Left

result.contains(42)                   // true if Right(42)
result.exists((n) => n > 0)           // true if Right and value passes test
result.all((n) => n > 0)              // true if Left OR Right passes test
```

### Side effects (tap)

Useful for logging or analytics without breaking a chain.

```dart
result
    .tap((value) => logger.info('Success: $value'))
    .tapLeft((error) => logger.error('Failure: $error'));
```

### Swap

```dart
Right<String, int>(42).swap()   // Left<int, String>(42)
Left<String, int>('err').swap() // Right<int, String>('err')
```

### Recovery

Four ways to act on a `Left`, differing in what they may produce.

```dart
// recover — always succeed, deriving a value from the error
loadSettings().recover((_) => Settings.defaults());   // Either<E, Settings>

// orElse — try another Either of the same type
fromCache(id).orElse((_) => fromDisk(id));

// orElseWith — same, but the fallback may report a different error type
fromCache(id).orElseWith((_) => fromNetwork(id));     // Either<HttpError, T>

// flatMapLeft — map the error into another attempt (alias of orElseWith)
result.flatMapLeft((e) => retryOnce(e));
```

`Right` passes through all four untouched, and the callback never runs.

### Refinement — `filterOrElse`

Demotes a `Right` whose value fails a test, naming the reason.

```dart
parseAge(input)
    .filterOrElse((age) => age >= 0, (age) => 'Negative age: $age')
    .filterOrElse((age) => age < 150, (age) => 'Implausible age: $age');
```

### Combining

```dart
// zip — pair two Rights into a record; the first Left wins
final pair = name.zip(email);              // Either<E, (String, String)>

// zipWith — combine through a function instead
final user = name.zipWith(email, User.new);
```

Both short-circuit: if `name` is a `Left`, `email` is never inspected and the
combiner never runs.

### Conversion

```dart
result.getOrDefault(0)   // R — a constant fallback, no callback
result.toOption()        // Option<R> — Some for Right, None for Left
result.toList()          // List<R> — one element for Right, empty for Left
```

`toOption` discards the left value, so reach for it only once the error has
been handled or logged.

---

## Collections of Either

`IterableEitherX` operates on a whole collection at once.

```dart
final results = [Right(1), Left('bad id'), Right(3), Left('no access')];

results.sequence()          // Left('bad id') — stops at the first failure
results.rights              // [1, 3]
results.lefts               // ['bad id', 'no access']
results.allRight            // false
results.anyLeft             // true
```

`sequence` is fail-fast; `partitionEithers` is the exhaustive counterpart,
returning every failure alongside every success in one pass:

```dart
final (failures, values) = results.partitionEithers();
// failures: ['bad id', 'no access']
// values:   [1, 3]
```

Use `sequence` when one bad element invalidates the batch, and
`partitionEithers` when you want to report all of them — a form with several
invalid fields should show every error, not just the first.

---

## Async Either

`FutureEitherX` puts the `Either` combinators directly on
`Future<Either<L, R>>`, so an async pipeline reads top to bottom without
`then` calls that unwrap and rewrap the value.

```dart
// Before
final summary = await fetchUser(id)
    .then((r) => r.flatMapAsync(fetchOrders))
    .then((r) => r.map(summarise));

// After
final summary = await fetchUser(id)
    .flatMap(fetchOrders)
    .map(summarise);
```

The full set mirrors the synchronous API:

```dart
future.map(f)            // f may return R2 or Future<R2>
future.mapLeft(f)
future.flatMap(f)        // f returns Either or Future<Either>
future.fold(ifLeft, ifRight)
future.getOrElse((e) => fallback)
future.getOrDefault(value)
future.getOrNull()
future.tap(onRight)      // observe without changing the value
future.tapLeft(onLeft)
future.orElseWith((e) => recoverAsync(e))
await future.isRight()
await future.isLeft()
```

These extensions chain lazily on the future; nothing runs until you `await`.

---

## Option

`Option<T>` represents an optional value that is either present (`Some<T>`) or absent (`None<T>`).

```dart
final some = Option.fromNullable(42);     // Some(42)
final none = Option<int>.fromNullable(null); // None

final val = some.fold(
  () => 'empty',
  (value) => 'Got $value',
);

final either = some.toEither(() => 'Missing value'); // Right(42)
```

### Refinement

```dart
Some(4).filter((n) => n.isEven)     // Some(4)
Some(3).filter((n) => n.isEven)     // None
Some(3).filterNot((n) => n.isEven)  // Some(3)

Some(4).isSomeAnd((n) => n.isEven)  // true
None<int>().isSomeAnd((n) => true)  // false — the test never runs
```

### Fallback and side effects

```dart
// orElse — the alternative is only computed when this Option is None
fromCache(id).orElse(() => fromDefaults(id));

// tap / tapNone — observe a branch, returning the Option unchanged
option
    .tap((value) => logger.info('hit: $value'))
    .tapNone(() => metrics.increment('cache.miss'));
```

### Combining and conversion

```dart
Some('a').zip(Some(1))                    // Some(('a', 1))
Some('a').zip(None<int>())                // None
Some(3).zipWith(Some(4), (a, b) => a * b) // Some(12)

Some(5).toList()      // [5]
None<int>().toList()  // []
```

> `Some` equality delegates to the inner value, so `Some([1, 2])` does **not**
> equal another `Some([1, 2])` — two distinct lists are never `==`. Unwrap
> before comparing collections.

---

## Collections of Option

```dart
const options = [Some(1), None<int>(), Some(3)];

options.sequence()   // None — fail-fast, like Either.sequence
options.values       // [1, 3] — the lenient counterpart
options.firstSome    // Some(1)
```

`NullableOptionX` is the entry point from ordinary nullable Dart:

```dart
config['retries']
    .toOption()
    .map(int.parse)
    .filter((n) => n > 0)
    .getOrElse(() => 1);
```

---

## State

`State<S, A>` monad for stateful computations:

```dart
final increment = State.get<int>().flatMap(
  (val) => State.set(val + 1).map((_) => 'Incremented from $val'),
);

final (message, newState) = increment.run(10); // ('Incremented from 10', 11)
```

---

## Try

`Try<T>` monad for safe exception handling (`TrySuccess<T>` and `TryFailure<T>`):

```dart
final attempt = Try.of(() => int.parse('42'));

if (attempt.isSuccess) {
  print(attempt.getOrNull()); // 42
}

final either = attempt.toEither();
```

---

## Reader

`Reader<R, A>` monad for dependency injection:

```dart
final getEndpoint = Reader.ask<Config>().map((config) => '${config.baseUrl}/api');
final url = getEndpoint.run(Config('https://example.com'));
```

---

## Result & type aliases

`Result<T>` is the standard alias for `Either<Failure, T>`. Use it wherever an operation can fail with a `Failure`.

```dart
// Aliases
Result<T>       == Either<Failure, T>
ResultUnit      == Result<Unit>       // success with no value

FutureResult<T>     == Future<Result<T>>
FutureResultUnit    == FutureResult<Unit>

StreamResult<T>     == Stream<Result<T>>
StreamResultUnit    == StreamResult<Unit>
```

```dart
// Repository returning Result<User>
Future<Result<User>> fetchUser(String id) async {
  try {
    final data = await api.get('/users/$id');
    return Right(User.fromJson(data));
  } catch (e) {
    return Left(Failure('Failed to load user', 'user.fetch_failed'));
  }
}

// Caller
final result = await fetchUser('abc');
result.fold(
  (failure) => showError(failure.message),
  (user)    => showProfile(user),
);
```

---

## Failure

`Failure` is the standard error carrier for the left side of a `Result`.

```dart
// Minimal
const Failure('Something went wrong')

// With a stable code for programmatic handling
const Failure('User not found', 'user.not_found')

// With structured metadata
Failure(
  'Validation failed',
  'validation.error',
  {'field': 'email', 'value': 'bad-input'},
)
```

```dart
// Consuming a Failure
result.fold(
  (f) => switch (f.code) {
    'user.not_found' => redirectToSignUp(),
    'network.timeout' => showRetry(),
    _ => showGenericError(f.message),
  },
  (user) => showProfile(user),
);

// Failure has value equality
Failure('msg', 'code') == Failure('msg', 'code') // true
```

### Wrapping a caught error

`Failure.fromError` has the exact shape `Either.tryCatch` expects for its
`onError` callback, so it can be passed as a tearoff:

```dart
final result = Either.tryCatch<Failure, Map<String, dynamic>>(
  () => jsonDecode(raw),
  Failure.fromError,
);
```

The original error is kept under the `'error'` detail, and a stack trace under
`'stackTrace'` when one is supplied.

### Enriching a failure

```dart
failure.copyWith(code: 'validation.error')
failure.withDetail('field', 'email')          // one entry
failure.withDetails({'field': 'email', 'attempt': 2})  // merge; new keys win

failure.detail<int>('attempt')     // 2
failure.detail<String>('attempt')  // null — wrong type, not a throw
failure.detail<int>('missing')     // null
```

All four return a new `Failure`; the original is untouched. Note that
`copyWith(code: null)` *keeps* the existing code rather than clearing it —
construct a new `Failure` when you need to drop one.

### Subclassing for domain errors

```dart
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message, 'network.error');
}

class NotFoundFailure extends Failure {
  final String resource;
  NotFoundFailure(this.resource)
      : super('$resource not found', '$resource.not_found');
}
```

`Failure`'s parameters are positional (`message`, `code`, `details`), so a
subclass that wants to fix the `code` has to forward `message` explicitly —
`super.message` cannot be combined with an explicit `super(...)` call.

---

## Unit

`Unit` (and its constant `unit`) represents successful completion with no meaningful value — the functional equivalent of `void`.

```dart
// Return unit when the operation succeeded but there is nothing to return
FutureResult<Unit> deleteUser(String id) async {
  try {
    await api.delete('/users/$id');
    return Right(unit);
  } catch (e) {
    return Left(Failure('Delete failed'));
  }
}

// Caller
final result = await deleteUser('abc');
result.fold(
  (f) => showError(f.message),
  (_) => showSuccess('User deleted'),   // _ is unit — no value needed
);
```

```dart
unit == unit    // true (singleton)
unit.toString() // '()'
```

---

## UseCase, SyncUseCase & StreamUseCase

Interfaces for application-layer business logic following clean architecture.

| Interface       | Returns              | Use for                         |
| --------------- | -------------------- | ------------------------------- |
| `UseCase`       | `FutureResult<T>`    | anything touching I/O           |
| `SyncUseCase`   | `Result<T>`          | pure rules — validation, policy |
| `StreamUseCase` | `StreamResult<T>`    | values arriving over time       |

### `UseCase<SuccessType, Params>`

```dart
class GetUserUseCase implements UseCase<User, String> {
  final UserRepository _repo;
  const GetUserUseCase(this._repo);

  @override
  FutureResult<User> call(String id) => _repo.fetchUser(id);
}

// Usage
final useCase = GetUserUseCase(repository);
final result  = await useCase('user-123');

result.fold(
  (f) => handleError(f),
  (user) => render(user),
);
```

### `SyncUseCase<SuccessType, Params>`

For business rules that need no I/O, where a `Future` would only add ceremony
at every call site.

```dart
class CheckWithdrawalUseCase implements SyncUseCase<Unit, Withdrawal> {
  @override
  Result<Unit> call(Withdrawal params) {
    if (params.amount <= 0) {
      return const Left(Failure('Amount must be positive.', 'amount.invalid'));
    }
    if (params.amount > params.balance) {
      return const Left(Failure('Insufficient funds.', 'balance.insufficient'));
    }
    return const Right(unit);
  }
}

// No await — composes straight into an async pipeline
final result = checkWithdrawal(withdrawal).flatMap(submit);
```

### `StreamUseCase<SuccessType, Params>`

```dart
class WatchCartUseCase implements StreamUseCase<Cart, String> {
  final CartRepository _repo;
  const WatchCartUseCase(this._repo);

  @override
  StreamResult<Cart> call(String userId) => _repo.watchCart(userId);
}

// Usage
watchCart('user-123').listen((result) {
  result.fold(
    (f) => showError(f.message),
    (cart) => updateCartUI(cart),
  );
});
```

---

## NoParams

Marker type for use cases that require no input parameter.

```dart
class GetCurrentUserUseCase implements UseCase<User, NoParams> {
  final AuthRepository _repo;
  const GetCurrentUserUseCase(this._repo);

  @override
  FutureResult<User> call(NoParams _) => _repo.currentUser();
}

// Usage
final result = await getCurrentUser(const NoParams());
```

---

## Patterns & recipes

### Chaining async operations

```dart
FutureResult<OrderSummary> placeOrder(Cart cart) {
  return Right<Failure, Cart>(cart)
      .flatMap(validateCart)           // sync validation first
      .flatMapAsync(reserveInventory)  // returns a Future from here on
      .flatMap(processPayment)         // FutureEitherX keeps the chain flat
      .map(buildSummary);
}
```

Once any step returns a `Future`, `FutureEitherX` takes over and the rest of
the chain reads the same as the synchronous part.

### Converting try/catch to Result

`Either.tryCatch` with `Failure.fromError` already covers this, so there is no
need for a local helper:

```dart
Result<T> tryResult<T>(T Function() action) =>
    Either.tryCatch(action, Failure.fromError);

FutureResult<T> tryResultAsync<T>(Future<T> Function() action) =>
    Either.tryCatchAsync(action, Failure.fromError);
```

### Collecting multiple results

```dart
final results = <Either<String, int>>[Right(1), Right(2), Left('oops'), Right(4)];

// Fail fast — one bad element invalidates the batch
results.sequence();          // Left('oops')

// Exhaustive — report every failure, e.g. a form with several bad fields
final (failures, values) = results.partitionEithers();
// failures: ['oops']
// values:   [1, 2, 4]

// Or take one side only
results.rights;              // [1, 2, 4]
results.lefts;               // ['oops']
```

### Using with Riverpod / state management

```dart
// AsyncNotifier that holds a Result
class UserNotifier extends AsyncNotifier<Result<User>> {
  @override
  Future<Result<User>> build() => ref.read(getUserUseCase)(const NoParams());

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(getUserUseCase)(const NoParams()));
  }
}
```
