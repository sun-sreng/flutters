import 'package:gmana_functional/gmana_functional.dart';
import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import 'number_errors.dart';
import 'number_validation_config.dart';
import 'number_validator.dart';

/// A value object representing a validated number.
///
/// A [NumberValue] is always valid: its [value] is a finite [num] that has
/// passed the configured [NumberValidationConfig]. Use [NumberValue.tryParse]
/// (or [NumberValue.tryParseNum]) for untrusted input and the [NumberValue]
/// constructors for trusted literals.
final class NumberValue extends ValueObject<num> {
  /// The validated numeric value.
  @override
  final num value;

  const NumberValue._(this.value);

  /// Validates the string [input], throwing [ValueObjectException] when invalid.
  ///
  /// Prefer [tryParse] for user input.
  factory NumberValue(
    String input, {
    NumberValidationConfig config = const NumberValidationConfig(),
  }) {
    return tryParse(
      input,
      config: config,
    ).getOrElse((error) => throw ValueObjectException(error));
  }

  /// Validates the numeric [input], throwing [ValueObjectException] when invalid.
  factory NumberValue.fromNum(
    num input, {
    NumberValidationConfig config = const NumberValidationConfig(),
  }) {
    return tryParseNum(
      input,
      config: config,
    ).getOrElse((error) => throw ValueObjectException(error));
  }

  /// Parses and validates the string [input], returning the value or an error.
  static Either<NumberError, NumberValue> tryParse(
    String input, {
    NumberValidationConfig config = const NumberValidationConfig(),
  }) {
    return NumberValidator(config).validate(input).map(NumberValue._);
  }

  /// Validates the numeric [input], returning the value or an error.
  static Either<NumberError, NumberValue> tryParseNum(
    num input, {
    NumberValidationConfig config = const NumberValidationConfig(),
  }) {
    return tryParse(input.toString(), config: config);
  }

  /// The value as an [int], truncated toward zero.
  int get asInt => value.toInt();

  /// The value as a [double].
  double get asDouble => value.toDouble();
}
