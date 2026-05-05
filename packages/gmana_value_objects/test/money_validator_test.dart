import 'package:test/test.dart';
import 'package:gmana_value_objects/gmana_value_objects.dart';

void main() {
  group('MoneyValidator', () {
    test('validates valid money amounts', () {
      const validator = MoneyValidator();

      final result = validator.validate('12.34', currency: 'usd');

      expect(result.isRight(), true);
      result.fold((l) => fail('should be right'), (money) {
        expect(money.amount, 12.34);
        expect(money.currency, Currency.usd);
        expect(money.minorUnits, 1234);
        expect(money.decimalDigits, 2);
      });
    });

    test('returns MoneyEmpty for empty string', () {
      const validator = MoneyValidator();
      final result = validator.validate('');

      result.fold(
        (l) => expect(l, isA<MoneyEmpty>()),
        (r) => fail('should be left'),
      );
    });

    test('returns MoneyInvalidFormat for unparsable amount', () {
      const validator = MoneyValidator();
      final result = validator.validate('12.3.4');

      result.fold(
        (l) => expect(l, isA<MoneyInvalidFormat>()),
        (r) => fail('should be left'),
      );
    });

    test('rejects too many decimal places for validator input', () {
      const validator = MoneyValidator();
      final result = validator.validate('12.345');

      result.fold((l) {
        expect(l, isA<MoneyDecimalPlacesExceeded>());
        final error = l as MoneyDecimalPlacesExceeded;
        expect(error.currentPlaces, 3);
        expect(error.maxPlaces, 2);
      }, (r) => fail('should be left'));
    });

    test('rejects negative amount', () {
      const validator = MoneyValidator();
      final result = validator.validate('-1.00');

      result.fold(
        (l) => expect(l, isA<MoneyNegativeNotAllowed>()),
        (r) => fail('should be left'),
      );
    });

    test('validates allowed currencies', () {
      final validator = MoneyValidator(MoneyValidationConfig.usd());

      expect(validator.validate('1.00', currency: 'USD').isRight(), true);

      validator
          .validate('1.00', currency: 'EUR')
          .fold(
            (l) => expect(l, isA<MoneyUnsupportedCurrency>()),
            (r) => fail('should be left'),
          );
    });

    test(
      'returns MoneyInvalidCurrency for malformed or unsupported currency',
      () {
        const validator = MoneyValidator();

        validator
            .validate('1.00', currency: 'US')
            .fold(
              (l) => expect(l, isA<MoneyInvalidCurrency>()),
              (r) => fail('should be left'),
            );
        validator
            .validate('1.00', currency: 'XXX')
            .fold(
              (l) => expect(l, isA<MoneyInvalidCurrency>()),
              (r) => fail('should be left'),
            );
      },
    );

    test('respects minor unit min and max', () {
      const validator = MoneyValidator(
        MoneyValidationConfig(minMinorUnits: 100, maxMinorUnits: 500),
      );

      validator
          .validate('0.99')
          .fold(
            (l) => expect(l, isA<MoneyTooSmall>()),
            (r) => fail('should be left'),
          );

      validator
          .validate('5.01')
          .fold(
            (l) => expect(l, isA<MoneyTooLarge>()),
            (r) => fail('should be left'),
          );

      expect(validator.validate('5.00').isRight(), true);
    });

    test('uses currency-specific decimal digits', () {
      final validator = MoneyValidator(MoneyValidationConfig.ecommerce());

      validator.validate('1200', currency: 'JPY').fold(
        (l) => fail('should be right'),
        (money) {
          expect(money.currency, Currency.jpy);
          expect(money.decimalDigits, 0);
          expect(money.minorUnits, 1200);
        },
      );

      validator
          .validate('1200.50', currency: 'JPY')
          .fold(
            (l) => expect(l, isA<MoneyDecimalPlacesExceeded>()),
            (r) => fail('should be left'),
          );

      validator.validate('1200', currency: 'KRW').fold(
        (l) => fail('should be right'),
        (money) {
          expect(money.currency, Currency.krw);
          expect(money.decimalDigits, 0);
          expect(money.minorUnits, 1200);
        },
      );
    });

    test('accepts thousands separators when configured', () {
      const validator = MoneyValidator();

      validator
          .validate('1,234.56', currency: 'USD')
          .fold(
            (l) => fail('should be right'),
            (money) => expect(money.minorUnits, 123456),
          );
    });

    test('rejects thousands separators when disabled', () {
      const validator = MoneyValidator(
        MoneyValidationConfig(allowThousandsSeparators: false),
      );

      validator
          .validate('1,234.56', currency: 'USD')
          .fold(
            (l) => expect(l, isA<MoneyInvalidFormat>()),
            (r) => fail('should be left'),
          );
    });
  });
}
