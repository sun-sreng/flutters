import 'package:gmana_functional/gmana_functional.dart';

// The result type now lives in gmana_functional, next to `Either`. It is
// re-exported here under its real names, and under the names this package
// used to declare.
export 'package:gmana_functional/gmana_functional.dart'
    show
        GFailure,
        GResult,
        GSuccess,
        GmanaFutureResultX,
        GmanaFutureToResultX,
        GmanaIterableResultX,
        GmanaResultX;

/// Former name of [GResult].
@Deprecated(
  'Use GResult from package:gmana_functional instead. '
  'This alias will be removed before 1.0.',
)
typedef Result<T, E> = GResult<T, E>;

/// Former name of [GSuccess].
@Deprecated(
  'Use GSuccess from package:gmana_functional instead. '
  'This alias will be removed before 1.0.',
)
typedef Success<T, E> = GSuccess<T, E>;

/// Former name of [GFailure].
@Deprecated(
  'Use GFailure from package:gmana_functional instead. '
  'This alias will be removed before 1.0.',
)
typedef Failure<T, E> = GFailure<T, E>;
