import 'package:test/test.dart';
import 'package:gmana/gmana.dart';

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

    test('uses normalized default currency', () {
      const validator = MoneyValidator(
        MoneyValidationConfig(defaultCurrency: ' usd '),
      );

      validator.validate('12.34').fold((l) => fail('should be right'), (money) {
        expect(money.currency, Currency.usd);
        expect(money.minorUnits, 1234);
      });
    });

    test('returns MoneyEmptyIssue for empty string', () {
      const validator = MoneyValidator();
      final result = validator.validate('');

      result.fold(
        (l) => expect(l, isA<MoneyEmptyIssue>()),
        (r) => fail('should be left'),
      );
    });

    test('returns MoneyInvalidFormatIssue for unparsable amount', () {
      const validator = MoneyValidator();
      for (final input in [
        '12.3.4',
        'NaN',
        'Infinity',
        '1,23.45',
        '1,234,56',
      ]) {
        validator
            .validate(input)
            .fold(
              (l) => expect(l, isA<MoneyInvalidFormatIssue>()),
              (r) => fail('should be left'),
            );
      }
    });

    test('rejects too many decimal places for validator input', () {
      const validator = MoneyValidator();
      final result = validator.validate('12.345');

      result.fold((l) {
        expect(l, isA<MoneyDecimalPlacesExceededIssue>());
        final error = l as MoneyDecimalPlacesExceededIssue;
        expect(error.currentPlaces, 3);
        expect(error.maxPlaces, 2);
      }, (r) => fail('should be left'));
    });

    test('rejects negative amount', () {
      const validator = MoneyValidator();
      final result = validator.validate('-1.00');

      result.fold(
        (l) => expect(l, isA<MoneyNegativeNotAllowedIssue>()),
        (r) => fail('should be left'),
      );
    });

    test('validates allowed currencies', () {
      final validator = MoneyValidator(MoneyValidationConfig.usd());

      expect(validator.validate('1.00', currency: 'USD').isRight(), true);

      validator
          .validate('1.00', currency: 'EUR')
          .fold(
            (l) => expect(l, isA<MoneyUnsupportedCurrencyIssue>()),
            (r) => fail('should be left'),
          );
    });

    test(
      'returns MoneyInvalidCurrencyIssue for malformed or unsupported currency',
      () {
        const validator = MoneyValidator();

        validator
            .validate('1.00', currency: 'US')
            .fold(
              (l) => expect(l, isA<MoneyInvalidCurrencyIssue>()),
              (r) => fail('should be left'),
            );
        validator
            .validate('1.00', currency: 'XXX')
            .fold(
              (l) => expect(l, isA<MoneyInvalidCurrencyIssue>()),
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
            (l) => expect(l, isA<MoneyTooSmallIssue>()),
            (r) => fail('should be left'),
          );

      validator
          .validate('5.01')
          .fold(
            (l) => expect(l, isA<MoneyTooLargeIssue>()),
            (r) => fail('should be left'),
          );

      expect(validator.validate('5.00').isRight(), true);
    });

    test('validates exact minor-unit input', () {
      const validator = MoneyValidator(
        MoneyValidationConfig(minMinorUnits: 100, maxMinorUnits: 500),
      );

      validator.validateMinorUnits(123, currency: 'USD').fold(
        (l) => fail('should be right'),
        (money) {
          expect(money.currency, Currency.usd);
          expect(money.minorUnits, 123);
          expect(money.decimalString, '1.23');
        },
      );

      validator
          .validateMinorUnits(-1)
          .fold(
            (l) => expect(l, isA<MoneyNegativeNotAllowedIssue>()),
            (r) => fail('should be left'),
          );
      validator
          .validateMinorUnits(99)
          .fold(
            (l) => expect(l, isA<MoneyTooSmallIssue>()),
            (r) => fail('should be left'),
          );
      validator
          .validateMinorUnits(501)
          .fold(
            (l) => expect(l, isA<MoneyTooLargeIssue>()),
            (r) => fail('should be left'),
          );
    });

    test('validates numeric input', () {
      const validator = MoneyValidator();

      validator
          .validateNum(12.3, currency: 'USD')
          .fold(
            (l) => fail('should be right'),
            (money) => expect(money.minorUnits, 1230),
          );

      validator
          .validateNum(double.nan)
          .fold(
            (l) => expect(l, isA<MoneyInvalidFormatIssue>()),
            (r) => fail('should be left'),
          );
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
            (l) => expect(l, isA<MoneyDecimalPlacesExceededIssue>()),
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
      validator
          .validate('+1,234.56', currency: 'USD')
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
            (l) => expect(l, isA<MoneyInvalidFormatIssue>()),
            (r) => fail('should be left'),
          );
    });

    test('normalizes allowed currencies', () {
      const validator = MoneyValidator(
        MoneyValidationConfig(allowedCurrencies: {' usd '}),
      );

      expect(validator.validate('1.00', currency: 'USD').isRight(), true);
      validator
          .validate('1.00', currency: 'EUR')
          .fold(
            (l) => expect(l, isA<MoneyUnsupportedCurrencyIssue>()),
            (r) => fail('should be left'),
          );
    });

    group('amounts beyond Money.maxMinorUnits', () {
      const validator = MoneyValidator();

      test('a long digit string is an issue, not an exception', () {
        final result = validator.validate('9' * 25, currency: 'USD');

        expect(result.leftOrNull(), isA<MoneyOutOfRangeIssue>());
      });

      test('an amount that would overflow when scaled is rejected', () {
        // 92233720368547759 * 100 wraps past the 64-bit limit.
        final result = validator.validate('92233720368547759', currency: 'USD');

        expect(result.leftOrNull(), isA<MoneyOutOfRangeIssue>());
      });

      test('the largest representable amount is accepted', () {
        final result = validator.validate('90071992547409.91', currency: 'USD');

        expect(result.rightOrNull()?.minorUnits, Money.maxMinorUnits);
      });

      test('one minor unit above the limit is rejected', () {
        final result = validator.validate('90071992547409.92', currency: 'USD');

        expect(result.leftOrNull(), isA<MoneyOutOfRangeIssue>());
      });

      test('validateMinorUnits rejects values above the limit', () {
        final result = validator.validateMinorUnits(
          Money.maxMinorUnits + 1,
          currency: 'USD',
        );

        expect(result.leftOrNull(), isA<MoneyOutOfRangeIssue>());
      });

      test('the issue has a stable code and a default message', () {
        const issue = MoneyOutOfRangeIssue(maxMinorUnits: 10);

        expect(issue.code, 'money.outOfRange');
        expect(resolveValidationIssue(issue).contains('10'), isTrue);
      });
    });
  });
}
