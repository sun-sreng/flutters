import 'package:gmana/value_objects.dart' as value_objects;
import 'package:test/test.dart';

void main() {
  test('focused value-objects entrypoint exports config copyWith', () {
    final copied = const value_objects.PhoneValidationConfig(
      requirePlusPrefix: true,
      minDigits: 7,
      maxDigits: 15,
    ).copyWith(minDigits: 9);

    expect(copied.requirePlusPrefix, isTrue);
    expect(copied.minDigits, 9);
    expect(copied.maxDigits, 15);
  });
}
