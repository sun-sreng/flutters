import 'dart:async';

/// Executes [action] and returns its result, or `null` if any exception occurs.
T? tryOrNull<T>(T Function() action) {
  try {
    return action();
  } catch (_) {
    return null;
  }
}

/// Executes async [action] and returns its result, or `null` if any exception occurs.
Future<T?> tryOrNullAsync<T>(Future<T> Function() action) async {
  try {
    return await action();
  } catch (_) {
    return null;
  }
}

/// Executes [action] and returns its result, or [defaultValue] if any exception occurs.
T tryOrDefault<T>(T Function() action, T defaultValue) {
  try {
    return action();
  } catch (_) {
    return defaultValue;
  }
}

/// Executes async [action], or returns [defaultValue] if any exception occurs.
///
/// The asynchronous counterpart to [tryOrDefault].
///
/// Example:
/// ```dart
/// final port = await tryOrDefaultAsync(() => readPortFromConfig(), 8080);
/// ```
Future<T> tryOrDefaultAsync<T>(
  Future<T> Function() action,
  T defaultValue,
) async {
  try {
    return await action();
  } catch (_) {
    return defaultValue;
  }
}

/// Executes [action], recovering from a thrown error with [onError].
///
/// Unlike [tryOrNull] and [tryOrDefault], which discard the error, [onError]
/// receives both the error and its stack trace, so the recovery can log or
/// branch on what actually went wrong.
///
/// Example:
/// ```dart
/// final config = tryOrElse(
///   () => parseConfig(raw),
///   (error, stackTrace) {
///     log.warning('Falling back to defaults', error, stackTrace);
///     return Config.defaults();
///   },
/// );
/// ```
T tryOrElse<T>(
  T Function() action,
  T Function(Object error, StackTrace stackTrace) onError,
) {
  try {
    return action();
  } catch (error, stackTrace) {
    return onError(error, stackTrace);
  }
}

/// Executes async [action], recovering from a thrown error with [onError].
///
/// The asynchronous counterpart to [tryOrElse]. [onError] may itself be
/// asynchronous.
Future<T> tryOrElseAsync<T>(
  Future<T> Function() action,
  FutureOr<T> Function(Object error, StackTrace stackTrace) onError,
) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    return await onError(error, stackTrace);
  }
}
