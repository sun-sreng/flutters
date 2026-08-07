import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_form/gmana_form.dart';

void main() {
  group('GValidators.required', () {
    test('rejects null, empty, and whitespace', () {
      final validate = GValidators.required();

      expect(validate(null), 'This field is required');
      expect(validate(''), 'This field is required');
      expect(validate('   '), 'This field is required');
    });

    test('accepts any real content', () {
      expect(GValidators.required()('a'), isNull);
    });

    test('honours a custom message', () {
      expect(GValidators.required(message: 'Need it')(''), 'Need it');
    });
  });

  group('GValidators.minLength / maxLength', () {
    test('minLength checks the lower bound', () {
      final validate = GValidators.minLength(3);

      expect(validate('ab'), 'Must be at least 3 characters');
      expect(validate('abc'), isNull);
      expect(validate('abcd'), isNull);
    });

    test('maxLength checks the upper bound', () {
      final validate = GValidators.maxLength(3);

      expect(validate('abcd'), 'Must be at most 3 characters');
      expect(validate('abc'), isNull);
    });

    test('both let an empty value through so they stay optional', () {
      expect(GValidators.minLength(3)(''), isNull);
      expect(GValidators.minLength(3)(null), isNull);
      expect(GValidators.maxLength(3)(''), isNull);
    });

    test('reject a negative length', () {
      expect(() => GValidators.minLength(-1), throwsArgumentError);
      expect(() => GValidators.maxLength(-1), throwsArgumentError);
    });
  });

  group('GValidators.pattern', () {
    test('checks the expression', () {
      final validate = GValidators.pattern(
        RegExp(r'^[a-z]+$'),
        message: 'Lowercase letters only',
      );

      expect(validate('abc'), isNull);
      expect(validate('Abc'), 'Lowercase letters only');
      expect(validate(''), isNull);
    });
  });

  group('GValidators.matches', () {
    test('reads the other value at validation time, not at build time', () {
      var other = 'first';
      final validate = GValidators.matches(() => other);

      expect(validate('first'), isNull);
      other = 'second';
      expect(validate('first'), 'Values do not match');
      expect(validate('second'), isNull);
    });

    test('can trim both sides', () {
      final validate = GValidators.matches(() => ' secret ', trim: true);

      expect(validate('secret'), isNull);
      expect(GValidators.matches(() => ' secret ')('secret'), isNotNull);
    });

    test('treats null as an empty string', () {
      expect(GValidators.matches(() => '')(null), isNull);
    });
  });

  group('GValidators.oneOf', () {
    test('checks membership', () {
      final validate = GValidators.oneOf(['a', 'b']);

      expect(validate('a'), isNull);
      expect(validate('c'), 'Must be one of: a, b');
      expect(validate(''), isNull);
    });
  });

  group('GValidators.numeric and range', () {
    test('numeric parses', () {
      final validate = GValidators.numeric();

      expect(validate('42'), isNull);
      expect(validate('4.2'), isNull);
      expect(validate('-4'), isNull);
      expect(validate('abc'), 'Enter a valid number');
      expect(validate(''), isNull);
    });

    test('range checks both bounds', () {
      final validate = GValidators.range(min: 1, max: 10);

      expect(validate('5'), isNull);
      expect(validate('1'), isNull);
      expect(validate('10'), isNull);
      expect(validate('0'), 'Must be at least 1');
      expect(validate('11'), 'Must be at most 10');
    });

    test('range works with only one bound', () {
      expect(GValidators.range(min: 18)('17'), 'Must be at least 18');
      expect(GValidators.range(max: 100)('101'), 'Must be at most 100');
      expect(GValidators.range(min: 18)('21'), isNull);
    });

    test('range reports unparsable input', () {
      expect(GValidators.range(min: 1)('abc'), 'Enter a valid number');
    });

    test('range rejects an inverted window', () {
      expect(() => GValidators.range(min: 10, max: 1), throwsArgumentError);
    });
  });

  group('GValidators.satisfies', () {
    test('runs the predicate for non-empty values', () {
      final validate = GValidators.satisfies(
        (value) => value.startsWith('SKU-'),
        message: 'Must start with SKU-',
      );

      expect(validate('SKU-1'), isNull);
      expect(validate('X-1'), 'Must start with SKU-');
      expect(validate(''), isNull);
    });
  });

  group('combineValidators', () {
    test('returns the first failure', () {
      final validate = combineValidators([
        GValidators.required(),
        GValidators.minLength(5),
      ]);

      expect(validate(''), 'This field is required');
      expect(validate('abc'), 'Must be at least 5 characters');
      expect(validate('abcde'), isNull);
    });

    test('skips null entries', () {
      final validate = combineValidators([null, GValidators.required(), null]);

      expect(validate(''), 'This field is required');
      expect(validate('x'), isNull);
    });

    test('an empty list always passes', () {
      expect(combineValidators([])('anything'), isNull);
      expect(combineValidators([])(null), isNull);
    });

    test('order decides which message wins', () {
      final requiredFirst = combineValidators([
        GValidators.required(),
        GValidators.numeric(),
      ]);
      final numericFirst = combineValidators([
        GValidators.numeric(),
        GValidators.required(),
      ]);

      // numeric() lets empty through, so ordering changes the empty-case result.
      expect(requiredFirst(''), 'This field is required');
      expect(numericFirst(''), 'This field is required');
      expect(requiredFirst('abc'), 'Enter a valid number');
    });
  });
}
