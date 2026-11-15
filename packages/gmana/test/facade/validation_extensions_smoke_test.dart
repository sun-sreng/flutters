import 'package:gmana/gmana.dart';
import 'package:test/test.dart';

void main() {
  test('typed and boolean String validation extensions coexist', () {
    final result = ' User@Example.COM '.validateEmail();

    expect(result.isValid, isTrue);
    expect(result.valueOrNull, 'user@example.com');
    expect('user@example.com'.isValidEmail, isTrue);
  });
}
