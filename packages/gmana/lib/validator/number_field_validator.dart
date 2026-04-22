import 'package:gmana/validator/string_field_validator.dart';

/// Validator for integer input with optional bounds.
class NumberFieldValidator implements StringFieldValidator {
  /// Minimum allowed numeric value.
  final int? minValue;

  /// Maximum allowed numeric value.
  final int? maxValue;

  /// Optional extra validation applied before built-in numeric checks.
  final String? Function(String?)? additionalValidator;

  /// Creates a number validator.
  const NumberFieldValidator({
    this.minValue,
    this.maxValue,
    this.additionalValidator,
  });

  @override
  String? validate(String? value) {
    final additionalResult = additionalValidator?.call(value);
    if (additionalResult != null) {
      return additionalResult;
    }

    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (minValue != null && number < minValue!) {
      return 'Number must be at least $minValue';
    }
    if (maxValue != null && number > maxValue!) {
      return 'Number must be at most $maxValue';
    }

    return null;
  }
}
