/// Utility for lazy initialization of values.
class Lazy<T> {
  final T Function() _factory;
  T? _value;
  bool _initialized = false;

  /// Creates a [Lazy] evaluated value using [_factory].
  Lazy(T Function() factory) : _factory = factory;

  /// Whether the lazy value has been evaluated.
  bool get isInitialized => _initialized;

  /// The evaluated lazy value. Computed on first call and cached afterwards.
  T get value {
    if (!_initialized) {
      _value = _factory();
      _initialized = true;
    }
    return _value as T;
  }

  /// Calls [value].
  T call() => value;
}

/// A [Lazy] initialized value that can be reset/invalidated.
class ResettableLazy<T> {
  final T Function() _factory;
  T? _value;
  bool _initialized = false;

  /// Creates a [ResettableLazy] evaluated value using [_factory].
  ResettableLazy(T Function() factory) : _factory = factory;

  /// Whether the lazy value has been evaluated and is currently valid.
  bool get isInitialized => _initialized;

  /// The evaluated lazy value. Computed on first call or after a call to [reset].
  T get value {
    if (!_initialized) {
      _value = _factory();
      _initialized = true;
    }
    return _value as T;
  }

  /// Calls [value].
  T call() => value;

  /// Resets the cached value, causing the next call to re-evaluate [_factory].
  void reset() {
    _value = null;
    _initialized = false;
  }
}
