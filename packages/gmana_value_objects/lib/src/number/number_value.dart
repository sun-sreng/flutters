import 'package:gmana/gmana.dart' show Either;
import '../core/value_object.dart';
import 'number_errors.dart';
import 'number_validation_config.dart';
import 'number_validator.dart';

/// A value object representing a validated number constraint.
///
/// Holds either a [NumberError] if validation fails, or the successful [num] value.
final class NumberValue extends ValueObject<num> {
  /// The underlying value, which is either a [NumberError] or a valid [num].
  @override
  final Either<NumberError, num> value;

  /// Creates a new [NumberValue] instance by parsing and validating the given string [input].
  ///
  /// The [config] provides limits and restrictions for validation.
  factory NumberValue(
    String input, {
    NumberValidationConfig config = const NumberValidationConfig(),
  }) {
    final validator = NumberValidator(config);
    return NumberValue._(validator.validate(input));
  }

  /// Creates a [NumberValue] directly from a [num], wrapping it in a string for validation.
  factory NumberValue.fromNum(
    num input, {
    NumberValidationConfig config = const NumberValidationConfig(),
  }) {
    return NumberValue(input.toString(), config: config);
  }

  /// Creates a new [NumberValue] instance directly from a validated [Either].
  factory NumberValue.validated(Either<NumberError, num> validated) {
    return NumberValue._(validated);
  }

  /// Internal constructor for [NumberValue].
  const NumberValue._(this.value);

  /// Returns the underlying valid numeric value as an [int], or `null` if invalid.
  int? get asInt => valueOrNull?.toInt();

  /// Returns the underlying valid numeric value as a [double], or `null` if invalid.
  double? get asDouble => valueOrNull?.toDouble();

  /// Returns a string representation of the [NumberValue].
  @override
  String toString() => 'NumberValue(${valueOrNull ?? 'invalid'})';
}
