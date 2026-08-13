import 'dart:async';
import 'dart:math';

/// Signature for the [retry] progress callback.
///
/// [attempt] is the 1-based number of the attempt that just failed, [error] is
/// what it threw, and [nextDelay] is how long [retry] will wait before the
/// following attempt.
typedef RetryCallback = void Function(
  int attempt,
  Object error,
  Duration nextDelay,
);

final Random _jitterRandom = Random();

/// Retries asynchronous operation [fn] up to [maxAttempts] times.
///
/// [maxAttempts] includes the initial call. Delay defaults to 500 ms and
/// doubles after each failure when [useExponentialBackoff] is true.
///
/// [maxDelay] caps how long a single wait can grow to. Without it the
/// exponential curve is uncapped, so a large [maxAttempts] produces waits far
/// longer than any caller wants — attempt 30 from a 500 ms base is roughly
/// 8,500 years. The doubling itself saturates rather than overflowing.
///
/// [jitter] applies full jitter: each wait becomes a random duration in
/// `[0, computedDelay]`. This spreads out clients that failed together, which
/// otherwise retry in lockstep and re-create the load that caused the failure.
///
/// [retryIf] controls whether a specific error is worth retrying. [onRetry] is
/// notified after each failed attempt that will be retried.
///
/// Example:
/// ```dart
/// final data = await retry(
///   () => fetchApiData(),
///   maxAttempts: 5,
///   delay: const Duration(milliseconds: 200),
///   maxDelay: const Duration(seconds: 5),
///   jitter: true,
///   retryIf: (error) => error is SocketException,
/// );
/// ```
Future<T> retry<T>(
  FutureOr<T> Function() fn, {
  int maxAttempts = 3,
  Duration delay = const Duration(milliseconds: 500),
  bool useExponentialBackoff = true,
  Duration? maxDelay,
  bool jitter = false,
  bool Function(Object error)? retryIf,
  RetryCallback? onRetry,
}) async {
  if (maxAttempts < 1) {
    throw ArgumentError.value(
      maxAttempts,
      'maxAttempts',
      'must be greater than or equal to 1',
    );
  }
  if (maxDelay != null && maxDelay <= Duration.zero) {
    throw ArgumentError.value(maxDelay, 'maxDelay', 'must be positive');
  }

  var attempt = 0;
  while (true) {
    attempt++;
    try {
      return await fn();
    } catch (error) {
      if (attempt >= maxAttempts) rethrow;
      if (retryIf != null && !retryIf(error)) rethrow;

      final currentDelay = _backoffDelay(
        base: delay,
        attempt: attempt,
        useExponentialBackoff: useExponentialBackoff,
        maxDelay: maxDelay,
        jitter: jitter,
      );

      onRetry?.call(attempt, error, currentDelay);

      await Future<void>.delayed(currentDelay);
    }
  }
}

/// Computes the wait before the attempt following [attempt].
///
/// Doubling saturates at the largest representable [Duration] instead of
/// overflowing into a negative value, which would turn a long backoff into an
/// immediate retry.
Duration _backoffDelay({
  required Duration base,
  required int attempt,
  required bool useExponentialBackoff,
  required Duration? maxDelay,
  required bool jitter,
}) {
  const maxMicroseconds = 9223372036854775807;

  var micros = base.inMicroseconds;
  if (micros < 0) micros = 0;

  if (useExponentialBackoff) {
    for (var i = 1; i < attempt; i++) {
      if (micros > maxMicroseconds ~/ 2) {
        micros = maxMicroseconds;
        break;
      }
      micros *= 2;
    }
  }

  if (maxDelay != null && micros > maxDelay.inMicroseconds) {
    micros = maxDelay.inMicroseconds;
  }

  if (jitter && micros > 0) {
    micros = (_jitterRandom.nextDouble() * micros).round();
  }

  return Duration(microseconds: micros);
}
