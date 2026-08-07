# gmana_functional

Pure Dart functional programming primitives for clean architecture.

```dart
import 'package:gmana_functional/gmana_functional.dart';
```

---

## Table of contents

- [Either](#either)
- [Option](#option)
- [State](#state)
- [Try](#try)
- [Reader](#reader)
- [Result & type aliases](#result--type-aliases)
- [Failure](#failure)
- [Unit](#unit)
- [UseCase & StreamUseCase](#usecase--streamusecase)
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
    return Left(Failure('Failed to load user', code: 'user.fetch_failed'));
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

### Subclassing for domain errors

```dart
class NetworkFailure extends Failure {
  const NetworkFailure(super.message) : super('network.error');
}

class NotFoundFailure extends Failure {
  final String resource;
  NotFoundFailure(this.resource)
      : super('$resource not found', '$resource.not_found');
}
```

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

## UseCase & StreamUseCase

Interfaces for application-layer business logic following clean architecture.

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
FutureResult<OrderSummary> placeOrder(Cart cart) async {
  return Right<Failure, Cart>(cart)
      .flatMap(validateCart)           // sync validation first
      .flatMapAsync(reserveInventory)  // then async
      .then((r) => r.flatMapAsync(processPayment))
      .then((r) => r.mapAsync(buildSummary));
}
```

### Converting try/catch to Result

```dart
Result<T> tryResult<T>(T Function() action) {
  try {
    return Right(action());
  } catch (e) {
    return Left(Failure(e.toString()));
  }
}

Future<Result<T>> tryResultAsync<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } catch (e) {
    return Left(Failure(e.toString()));
  }
}
```

### Collecting multiple results

```dart
// Fail fast on the first Left
List<Either<String, int>> results = [Right(1), Right(2), Left('oops'), Right(4)];

final firstFailure = results.firstWhere((r) => r.isLeft(), orElse: () => Right(0));
final allValues    = results.whereType<Right<String, int>>().map((r) => r.value);
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
