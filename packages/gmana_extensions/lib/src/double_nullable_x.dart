/// Specific extensions for nullable [double] to preserve explicit type contracts.
extension DoubleNullableX on double? {
  /// Checks if the value is null or `NaN`.
  bool get isNullOrNaN => this == null || this!.isNaN;

  /// Checks if the value is null, infinite, or `NaN`.
  bool get isNullOrNotFinite => this == null || !this!.isFinite;

  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0.0;

  /// Returns the value if it is finite, otherwise null.
  double? get finiteOrNull => this != null && this!.isFinite ? this : null;

  /// Returns the value or `NaN` if null.
  double get orNaN => this ?? double.nan;

  /// Returns the value or `0.0` if null.
  double get orZero => this ?? 0.0;

  /// Returns the value or [fallback] if null.
  double orDefault(double fallback) => this ?? fallback;

  /// Returns the value or [fallback] if null or `NaN`.
  double orDefaultIfNaN(double fallback) => isNullOrNaN ? fallback : this!;

  /// Returns the value or [fallback] if null, infinite, or `NaN`.
  double orDefaultIfNotFinite(double fallback) =>
      isNullOrNotFinite ? fallback : this!;

  /// Applies [transform] only when the value is non-null.
  R? mapNotNull<R>(R Function(double value) transform) =>
      this == null ? null : transform(this!);
}
