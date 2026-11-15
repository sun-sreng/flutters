/// Extensions for nullable [num] values providing safe defaults.
/// Covers both [int?] and [double?] due to Dart's type hierarchy.
extension NumNullableX on num? {
  /// Checks if the value is null or negative.
  bool get isNullOrNegative => this == null || this! < 0;

  /// Checks if the value is null, infinite, or `NaN`.
  bool get isNullOrNotFinite => this == null || !this!.isFinite;

  /// Checks if the value is null or positive.
  bool get isNullOrPositive => this == null || this! > 0;

  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0;

  /// Returns the value if it is finite, otherwise null.
  num? get finiteOrNull => this != null && this!.isFinite ? this : null;

  /// Returns the value if it is not zero, otherwise null.
  num? get nonZeroOrNull => this == 0 ? null : this;

  /// Returns the string representation or an empty string if null.
  String get orEmptyString => this?.toString() ?? '';

  /// Returns the value or `0` if null.
  num get orZero => this ?? 0;

  /// Returns the value or [fallback] if null.
  num orDefault(num fallback) => this ?? fallback;

  /// Returns the value or [fallback] if null, infinite, or `NaN`.
  num orDefaultIfNotFinite(num fallback) =>
      isNullOrNotFinite ? fallback : this!;

  /// Returns the value or [fallback] if null or zero.
  num orDefaultIfZero(num fallback) => isNullOrZero ? fallback : this!;

  /// Applies [transform] only when the value is non-null.
  R? mapNotNull<R>(R Function(num value) transform) =>
      this == null ? null : transform(this!);
}
