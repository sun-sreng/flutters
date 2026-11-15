import 'package:gmana/validation.dart' as validation;
import 'package:test/test.dart';

void main() {
  test('validation entrypoint exports the configs value objects use', () {
    final copied = const validation.PhoneValidationConfig(
      requirePlusPrefix: true,
      minDigits: 7,
      maxDigits: 15,
    ).copyWith(minDigits: 9);

    expect(copied.requirePlusPrefix, isTrue);
    expect(copied.minDigits, 9);
    expect(copied.maxDigits, 15);
  });
}
