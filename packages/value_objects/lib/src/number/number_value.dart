import 'package:fpdart/fpdart.dart';
import '../core/value_object.dart';
import 'number_errors.dart';
import 'number_validation_config.dart';
import 'number_validator.dart';

final class NumberValue extends ValueObject<num> {
  @override
  final Either<NumberError, num> value;

  factory NumberValue(String input, {NumberValidationConfig config = const NumberValidationConfig()}) {
    final validator = NumberValidator(config);
    return NumberValue._(validator.validate(input));
  }

  factory NumberValue.fromNum(num input, {NumberValidationConfig config = const NumberValidationConfig()}) {
    return NumberValue(input.toString(), config: config);
  }

  factory NumberValue.validated(Either<NumberError, num> validated) {
    return NumberValue._(validated);
  }

  const NumberValue._(this.value);

  int? get asInt => valueOrNull?.toInt();
  double? get asDouble => valueOrNull?.toDouble();

  @override
  String toString() => 'NumberValue(${valueOrNull ?? 'invalid'})';
}
