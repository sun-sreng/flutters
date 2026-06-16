import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('NumberValue value object', () {
    test('tryParse returns the parsed value for valid input', () {
      NumberValue.tryParse('42').fold((l) => fail('should be right'), (value) {
        expect(value.value, 42);
        expect(value.asInt, 42);
        expect(value.asDouble, 42.0);
        expect(value.toString(), 'NumberValue(42)');
      });
    });

    test('tryParse returns the error for invalid input', () {
      NumberValue.tryParse('abc').fold(
        (error) => expect(error, isA<NumberInvalidFormat>()),
        (r) => fail('should be left'),
      );
    });

    test('tryParseNum validates numeric input', () {
      NumberValue.tryParseNum(
        -1,
        config: const NumberValidationConfig(allowNegative: false),
      ).fold(
        (error) => expect(error, isA<NumberNegativeNotAllowed>()),
        (r) => fail('should be left'),
      );
    });

    test('constructors build trusted values and throw otherwise', () {
      expect(NumberValue('42').value, 42);
      expect(NumberValue.fromNum(42).value, 42);
      expect(() => NumberValue('abc'), throwsA(isA<ValueObjectException>()));
    });

    test('has value equality', () {
      expect(NumberValue('42'), NumberValue.fromNum(42));
      expect(NumberValue('42').hashCode, NumberValue.fromNum(42).hashCode);
      expect(NumberValue('42'), isNot(NumberValue('43')));
    });
  });
}
