import 'package:meta/meta.dart';

@immutable
final class NumberValidationConfig {
  final num? min;
  final num? max;
  final bool allowNegative;
  final bool integerOnly;
  final int? maxDecimalPlaces;
  
  const NumberValidationConfig({
    this.min,
    this.max,
    this.allowNegative = true,
    this.integerOnly = false,
    this.maxDecimalPlaces,
  });
  
  /// Positive integers only (0, 1, 2, ...)
  factory NumberValidationConfig.positiveInteger() {
    return const NumberValidationConfig(
      min: 0,
      allowNegative: false,
      integerOnly: true,
    );
  }
  
  /// Natural numbers (1, 2, 3, ...)
  factory NumberValidationConfig.naturalNumber() {
    return const NumberValidationConfig(
      min: 1,
      allowNegative: false,
      integerOnly: true,
    );
  }
  
  /// Percentage (0-100)
  factory NumberValidationConfig.percentage() {
    return const NumberValidationConfig(
      min: 0,
      max: 100,
      allowNegative: false,
    );
  }
  
  /// Price/Money (non-negative with 2 decimal places)
  factory NumberValidationConfig.price() {
    return const NumberValidationConfig(
      min: 0,
      allowNegative: false,
      maxDecimalPlaces: 2,
    );
  }
  
  /// Age validation
  factory NumberValidationConfig.age() {
    return const NumberValidationConfig(
      min: 0,
      max: 150,
      allowNegative: false,
      integerOnly: true,
    );
  }
  
  /// Rating (1-5)
  factory NumberValidationConfig.rating() {
    return const NumberValidationConfig(
      min: 1,
      max: 5,
      allowNegative: false,
      integerOnly: true,
    );
  }
}
