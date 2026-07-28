import 'dart:async';

/// Retries asynchronous operation [fn] up to [maxAttempts] times.
///
/// Delay defaults to 500ms and doubles with exponential backoff if [useExponentialBackoff] is true.
/// Optional [retryIf] predicate controls whether a specific exception should be retried.
Future<T> retry<T>(
  FutureOr<T> Function() fn, {
  int maxAttempts = 3,
  Duration delay = const Duration(milliseconds: 500),
  bool useExponentialBackoff = true,
  bool Function(Object error)? retryIf,
}) async {
  if (maxAttempts < 1) {
    throw ArgumentError.value(
      maxAttempts,
      'maxAttempts',
      'must be greater than or equal to 1',
    );
  }

  var attempt = 0;
  while (true) {
    attempt++;
    try {
      return await fn();
    } catch (error) {
      if (attempt >= maxAttempts) rethrow;
      if (retryIf != null && !retryIf(error)) rethrow;

      final currentDelay = useExponentialBackoff
          ? delay * (1 << (attempt - 1))
          : delay;

      await Future<void>.delayed(currentDelay);
    }
  }
}
