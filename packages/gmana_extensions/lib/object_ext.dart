/// Kotlin-style scope functions available on every non-null value.
///
/// These let you keep expression chains flat instead of introducing
/// intermediate local variables.
extension ScopeFunctionsX<T extends Object> on T {
  /// Applies [transform] to this value and returns its result.
  ///
  /// ```dart
  /// final length = 'hello'.let((s) => s.length); // 5
  /// ```
  R let<R>(R Function(T it) transform) => transform(this);

  /// Runs [action] with this value and returns the value unchanged.
  ///
  /// Useful for side effects (logging, registration) inside a chain.
  ///
  /// ```dart
  /// final user = User().also((u) => print('created $u'));
  /// ```
  T also(void Function(T it) action) {
    action(this);
    return this;
  }

  /// Returns this value when [predicate] holds, otherwise `null`.
  ///
  /// ```dart
  /// 'admin'.takeIf((s) => s.isNotEmpty); // 'admin'
  /// ```
  T? takeIf(bool Function(T it) predicate) => predicate(this) ? this : null;

  /// Returns this value when [predicate] fails, otherwise `null`.
  ///
  /// ```dart
  /// ''.takeUnless((s) => s.isEmpty); // null
  /// ```
  T? takeUnless(bool Function(T it) predicate) => predicate(this) ? null : this;

  /// Safe cast: returns this value as [R], or `null` if it is not an [R].
  ///
  /// ```dart
  /// final n = value.asOrNull<int>() ?? 0;
  /// ```
  R? asOrNull<R>() {
    final self = this;
    return self is R ? self as R : null;
  }
}

/// Null-aware helpers available on any nullable value.
extension ObjectNullableX<T extends Object> on T? {
  /// Whether this value is `null`.
  bool get isNull => this == null;

  /// Whether this value is not `null`.
  bool get isNotNull => this != null;

  /// Applies [transform] only when this value is non-null.
  ///
  /// ```dart
  /// String? name;
  /// name.letOrNull((n) => n.length); // null
  /// ```
  R? letOrNull<R>(R Function(T it) transform) {
    final self = this;
    return self == null ? null : transform(self);
  }

  /// Runs [action] only when this value is non-null, then returns it unchanged.
  T? alsoNotNull(void Function(T it) action) {
    final self = this;
    if (self != null) action(self);
    return self;
  }

  /// Returns this value if non-null, otherwise the result of [fallback].
  ///
  /// Unlike `??`, [fallback] is a callback, so the default is computed lazily.
  T orElseGet(T Function() fallback) => this ?? fallback();
}
