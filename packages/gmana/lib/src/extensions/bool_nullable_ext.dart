/// Extensions for nullable [bool] values providing safe defaults.
extension BoolNullableX on bool? {
  /// Returns true only when the value is explicitly `false`.
  bool get isFalse => this == false;

  /// Checks if the value is null or false.
  bool get isNullOrFalse => this != true;

  /// Checks if the value is null or true.
  bool get isNullOrTrue => this != false;

  /// Returns true only when the value is explicitly `true`.
  bool get isTrue => this == true;

  /// Returns the value or `false` if null.
  bool get orFalse => this ?? false;

  /// Returns the value or `true` if null.
  bool get orTrue => this ?? true;

  /// Returns the value or [fallback] if null.
  bool orDefault({required bool fallback}) => this ?? fallback;

  /// Resolves this nullable boolean into one of three values.
  T fold<T>({
    required T Function() whenTrue,
    required T Function() whenFalse,
    required T Function() whenNull,
  }) {
    if (this == true) return whenTrue();
    if (this == false) return whenFalse();
    return whenNull();
  }

  /// Executes [action] only when the value is explicitly `false`.
  void whenFalse(void Function() action) {
    if (this == false) action();
  }

  /// Executes [action] only when the value is null.
  void whenNull(void Function() action) {
    if (this == null) action();
  }

  /// Executes [action] only when the value is explicitly `true`.
  void whenTrue(void Function() action) {
    if (this == true) action();
  }
}
