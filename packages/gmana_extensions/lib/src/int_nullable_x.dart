/// Specific extensions for nullable [int] to preserve explicit type contracts.
extension IntNullableX on int? {
  /// Checks if the value is null or negative.
  bool get isNullOrNegative => this == null || this! < 0;

  /// Checks if the value is null or positive.
  bool get isNullOrPositive => this == null || this! > 0;

  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0;

  /// Returns the value if it is not zero, otherwise null.
  int? get nonZeroOrNull => this == 0 ? null : this;

  /// Returns the decimal string representation or an empty string if null.
  String get orEmptyString => this?.toString() ?? '';

  /// Returns the value or `0` if null.
  int get orZero => this ?? 0;

  /// Returns the value or [fallback] if null.
  int orDefault(int fallback) => this ?? fallback;

  /// Returns the value or [fallback] if null or zero.
  int orDefaultIfZero(int fallback) => isNullOrZero ? fallback : this!;

  /// Applies [transform] only when the value is non-null.
  R? mapNotNull<R>(R Function(int value) transform) =>
      this == null ? null : transform(this!);
}
