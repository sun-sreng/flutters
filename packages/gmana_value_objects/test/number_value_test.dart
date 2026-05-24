import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('NumberValue', () {
    test('creates valid NumberValue', () {
      final value = NumberValue('42');
      expect(value.isValid, true);
      expect(value.valueOrNull, 42);
      expect(value.asInt, 42);
      expect(value.asDouble, 42.0);
    });

    test('creates invalid NumberValue', () {
      final value = NumberValue('abc');
      expect(value.isInvalid, true);
      expect(value.valueOrNull, null);
      expect(value.errorOrNull, isA<NumberInvalidFormat>());
      expect(value.asInt, null);
      expect(value.asDouble, null);
    });

    test('creates from num', () {
      final value = NumberValue.fromNum(42);
      expect(value.isValid, true);
      expect(value.valueOrNull, 42);
    });

    test('creates from validated result', () {
      final validated = const NumberValidator().validate('42');
      final value = NumberValue.validated(validated);

      expect(value.isValid, true);
      expect(value.valueOrNull, 42);
    });

    test('toString returns proper format', () {
      expect(NumberValue('42').toString(), 'NumberValue(42)');
      expect(NumberValue('abc').toString(), 'NumberValue(invalid)');
    });
  });
}
