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
