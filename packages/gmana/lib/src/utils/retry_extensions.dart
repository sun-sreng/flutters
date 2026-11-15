import 'dart:async';

import 'retry.dart' as retry_utils;

/// Fluent retry support for synchronous or asynchronous operations.
extension GmanaRetryFunctionX<T> on FutureOr<T> Function() {
  /// Invokes this operation and retries failures according to the options.
  ///
  /// This is the extension equivalent of [retry_utils.retry]. The receiver is
  /// a function because each attempt must start a new operation; an
  /// already-running `Future` cannot be retried.
  Future<T> withRetry({
    int maxAttempts = 3,
    Duration delay = const Duration(milliseconds: 500),
    bool useExponentialBackoff = true,
    Duration? maxDelay,
    bool jitter = false,
    bool Function(Object error)? retryIf,
    retry_utils.RetryCallback? onRetry,
  }) => retry_utils.retry<T>(
    this,
    maxAttempts: maxAttempts,
    delay: delay,
    useExponentialBackoff: useExponentialBackoff,
    maxDelay: maxDelay,
    jitter: jitter,
    retryIf: retryIf,
    onRetry: onRetry,
  );
}
