import 'package:flutter_test/flutter_test.dart';
import 'package:gmana/value_objects.dart' show Password;
import 'package:gmana_flutter/form.dart';

void main() {
  group('password field default policy', () {
    // Each input exercises a rule where `balanced` and the strong package
    // default disagree, plus clear passes and failures on either policy.
    const inputs = [
      'Kq7mPzw2', // three classes, no symbol
      'Kq7m!Pzw', // all four classes
      'Пароль1!Aa', // non-ASCII letters
      'abcdefgh', // one class and a sequential run
      'Ab1!', // too short
    ];

    void expectAgreesWithPassword(String? Function(String?) validator) {
      for (final input in inputs) {
        final fieldAccepts = validator(input) == null;
        final passwordAccepts = Password.tryParse(input).isRight();

        expect(
          fieldAccepts,
          passwordAccepts,
          reason:
              'the field and Password must agree on "$input" '
              '(field: $fieldAccepts, Password: $passwordAccepts)',
        );
      }
    }

    test('GPasswordField accepts exactly what Password accepts', () {
      expectAgreesWithPassword(GPasswordField().config.validator!);
    });

    test('GTextFormField.password accepts exactly what Password accepts', () {
      expectAgreesWithPassword(GTextFormField.password().config.validator!);
    });
  });
}
