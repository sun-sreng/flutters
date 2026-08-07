import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart';

/// Records how many times it ran, so short-circuiting can be asserted.
class _Counting {
  int calls = 0;
  final bool answer;

  _Counting({required this.answer});

  bool call(String value) {
    calls++;
    return answer;
  }
}

void main() {
  group('Predicates.all', () {
    test('passes only when every predicate passes', () {
      final predicate = Predicates.all<String>([isAlphaNumeric, isLowerCase]);

      expect(predicate('abc123'), isTrue);
      expect(predicate('ABC123'), isFalse);
      expect(predicate('abc-123'), isFalse);
    });

    test('short-circuits on the first failure', () {
      final first = _Counting(answer: false);
      final second = _Counting(answer: true);

      Predicates.all<String>([first.call, second.call])('x');

      expect(first.calls, 1);
      expect(second.calls, 0);
    });

    test('an empty list passes everything', () {
      expect(Predicates.all<String>([])('anything'), isTrue);
    });

    test('copies the source, so later mutation does not leak in', () {
      final sources = <Predicate<String>>[isAlpha];
      final predicate = Predicates.all(sources);
      sources.add(isNumeric);

      expect(predicate('abc'), isTrue);
    });
  });

  group('Predicates.any', () {
    test('passes when at least one predicate passes', () {
      final predicate = Predicates.any<String>([isEmail, isUrl]);

      expect(predicate('user@example.com'), isTrue);
      expect(predicate('https://example.com'), isTrue);
      expect(predicate('neither'), isFalse);
    });

    test('short-circuits on the first success', () {
      final first = _Counting(answer: true);
      final second = _Counting(answer: true);

      Predicates.any<String>([first.call, second.call])('x');

      expect(first.calls, 1);
      expect(second.calls, 0);
    });

    test('an empty list rejects everything', () {
      expect(Predicates.any<String>([])('anything'), isFalse);
    });
  });

  group('Predicates.none', () {
    test('passes only when no predicate passes', () {
      final predicate = Predicates.none<String>([isBlank, isNumeric]);

      expect(predicate('hello'), isTrue);
      expect(predicate('   '), isFalse);
      expect(predicate('42'), isFalse);
    });

    test('an empty list passes everything', () {
      expect(Predicates.none<String>([])('anything'), isTrue);
    });
  });

  group('Predicates.not', () {
    test('inverts the result', () {
      final notEmail = Predicates.not<String>(isEmail);

      expect(notEmail('user@example.com'), isFalse);
      expect(notEmail('nope'), isTrue);
    });
  });

  group('Predicates constants', () {
    test('alwaysTrue and alwaysFalse ignore the value', () {
      expect(Predicates.alwaysTrue<String>()(''), isTrue);
      expect(Predicates.alwaysFalse<String>()(''), isFalse);
    });

    test('alwaysTrue is the identity element for all', () {
      final predicate = Predicates.all<String>([
        Predicates.alwaysTrue(),
        isNumeric,
      ]);

      expect(predicate('42'), isTrue);
      expect(predicate('x'), isFalse);
    });
  });

  group('Predicates.equalTo', () {
    test('compares by ==', () {
      final predicate = Predicates.equalTo('draft');

      expect(predicate('draft'), isTrue);
      expect(predicate('published'), isFalse);
    });

    test('works for non-string types', () {
      expect(Predicates.equalTo(3)(3), isTrue);
    });
  });

  group('Predicates.oneOf', () {
    test('tests membership', () {
      final predicate = Predicates.oneOf(['draft', 'review', 'published']);

      expect(predicate('review'), isTrue);
      expect(predicate('deleted'), isFalse);
    });

    test('an empty set rejects everything', () {
      expect(Predicates.oneOf<String>([])('x'), isFalse);
    });

    test('snapshots the values at construction time', () {
      final values = ['a'];
      final predicate = Predicates.oneOf(values);
      values.add('b');

      expect(predicate('b'), isFalse);
    });
  });

  group('Predicates.nullable', () {
    test('answers whenNull for null and defers otherwise', () {
      final optional = Predicates.nullable(isEmail, whenNull: true);

      expect(optional(null), isTrue);
      expect(optional('user@example.com'), isTrue);
      expect(optional('nope'), isFalse);
    });

    test('rejects null by default', () {
      expect(Predicates.nullable(isEmail)(null), isFalse);
    });
  });

  group('PredicateX.and', () {
    test('requires both sides', () {
      final predicate = isAlphaNumeric.and(isLowerCase);

      expect(predicate('abc123'), isTrue);
      expect(predicate('ABC123'), isFalse);
    });

    test('does not evaluate the right side when the left fails', () {
      final right = _Counting(answer: true);

      isNumeric.and(right.call)('not a number');

      expect(right.calls, 0);
    });
  });

  group('PredicateX.or', () {
    test('accepts either side', () {
      final predicate = isEmail.or(isUrl);

      expect(predicate('user@example.com'), isTrue);
      expect(predicate('https://example.com'), isTrue);
      expect(predicate('neither'), isFalse);
    });

    test('does not evaluate the right side when the left passes', () {
      final right = _Counting(answer: true);

      isNumeric.or(right.call)('42');

      expect(right.calls, 0);
    });
  });

  group('PredicateX.xor', () {
    test('passes when exactly one side passes', () {
      final predicate = isNumeric.xor(isAlpha);

      expect(predicate('42'), isTrue);
      expect(predicate('abc'), isTrue);
      expect(predicate('a1'), isFalse);
    });

    test('both sides always run', () {
      final right = _Counting(answer: true);

      isNumeric.xor(right.call)('42');

      expect(right.calls, 1);
    });
  });

  group('PredicateX.negated', () {
    test('inverts', () {
      expect(isNumeric.negated('abc'), isTrue);
      expect(isNumeric.negated('42'), isFalse);
    });

    test('negating twice restores the original', () {
      expect(isNumeric.negated.negated('42'), isTrue);
    });
  });

  group('PredicateX.on', () {
    test('retargets a String predicate at a field of another type', () {
      final hasValidEmail = isEmail.on(
        (Map<String, String> row) => row['email']!,
      );

      expect(hasValidEmail({'email': 'user@example.com'}), isTrue);
      expect(hasValidEmail({'email': 'nope'}), isFalse);
    });

    test('composes with the other combinators after retargeting', () {
      final rows = [
        {'email': 'a@example.com'},
        {'email': 'bad'},
      ];
      final invalid =
          isEmail.on((Map<String, String> row) => row['email']!).negated;

      expect(rows.where(invalid).single, {'email': 'bad'});
    });
  });

  group('PredicateX.everyIn and anyIn', () {
    test('apply the predicate across a collection', () {
      const values = ['1', '2', 'x'];

      expect(isNumeric.anyIn(values), isTrue);
      expect(isNumeric.everyIn(values), isFalse);
      expect(isNumeric.everyIn(const ['1', '2']), isTrue);
    });

    test('everyIn passes and anyIn fails on an empty collection', () {
      expect(isNumeric.everyIn(const []), isTrue);
      expect(isNumeric.anyIn(const []), isFalse);
    });
  });

  test('a realistic rule reads as one expression', () {
    final username = Predicates.all<String>([
      isNotBlank,
      (value) => value.isLength(3, 16),
      isAlphaNumeric.or(isSnakeCase),
    ]);

    expect(username('sun_sreng'), isTrue);
    expect(username('ab'), isFalse);
    expect(username('has spaces'), isFalse);
    expect(username(''), isFalse);
  });
}
