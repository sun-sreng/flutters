import 'package:gmana_functional/gmana_functional.dart';
import 'package:test/test.dart';

class _Age {
  final int value;

  const _Age(this.value);
}

/// A rule that needs no I/O, so it implements [SyncUseCase] rather than
/// wrapping the answer in a [Future].
class _CheckAdult implements SyncUseCase<Unit, _Age> {
  @override
  Result<Unit> call(_Age params) =>
      params.value >= 18
          ? const Right<Failure, Unit>(unit)
          : const Left<Failure, Unit>(
            Failure('Must be 18 or older.', 'under_age'),
          );
}

void main() {
  group('Failure.fromError', () {
    test('uses the error string as the message and keeps the error', () {
      final failure = Failure.fromError(const FormatException('bad input'));

      expect(failure.message, contains('bad input'));
      expect(failure.code, isNull);
      expect(failure.detail<FormatException>('error'), isA<FormatException>());
    });

    test('records the stack trace only when one is supplied', () {
      final trace = StackTrace.current;

      expect(
        Failure.fromError('boom').details.containsKey('stackTrace'),
        isFalse,
      );
      expect(
        Failure.fromError('boom', trace).detail<StackTrace>('stackTrace'),
        trace,
      );
    });

    test('is usable directly as the onError callback of Either.tryCatch', () {
      final result = Either.tryCatch<Failure, int>(
        () => int.parse('not a number'),
        Failure.fromError,
      );

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().message, contains('FormatException'));
    });
  });

  group('Failure.copyWith', () {
    test('replaces only the fields that were passed', () {
      const original = Failure('Original.', 'original_code', {'a': 1});

      final renamed = original.copyWith(message: 'Renamed.');

      expect(renamed.message, 'Renamed.');
      expect(renamed.code, 'original_code');
      expect(renamed.details, {'a': 1});
    });

    test(
      'a null argument keeps the existing value rather than clearing it',
      () {
        const original = Failure('Original.', 'original_code');

        expect(original.copyWith().code, 'original_code');
      },
    );
  });

  group('Failure details', () {
    test('withDetail adds one entry without touching the others', () {
      const original = Failure('Failed.', null, {'field': 'email'});

      final enriched = original.withDetail('attempt', 2);

      expect(enriched.details, {'field': 'email', 'attempt': 2});
      expect(original.details, {'field': 'email'});
    });

    test('withDetails merges, and the new keys win', () {
      const original = Failure('Failed.', null, {'attempt': 1, 'field': 'age'});

      final enriched = original.withDetails({'attempt': 2, 'source': 'form'});

      expect(enriched.details, {
        'attempt': 2,
        'field': 'age',
        'source': 'form',
      });
    });

    test('detail reads a typed entry', () {
      const failure = Failure('Failed.', null, {'attempt': 3});

      expect(failure.detail<int>('attempt'), 3);
    });

    test('detail is null for a missing key or a mismatched type', () {
      const failure = Failure('Failed.', null, {'attempt': 3});

      expect(failure.detail<int>('missing'), isNull);
      expect(failure.detail<String>('attempt'), isNull);
    });

    test('enriched failures still compare by value', () {
      const base = Failure('Failed.', 'code');

      expect(base.withDetail('a', 1), base.withDetail('a', 1));
      expect(base.withDetail('a', 1), isNot(base.withDetail('a', 2)));
      expect(
        base.withDetail('a', 1).hashCode,
        base.withDetail('a', 1).hashCode,
      );
    });
  });

  group('SyncUseCase', () {
    test('returns a Result without a Future', () {
      final checkAdult = _CheckAdult();

      final allowed = checkAdult(const _Age(21));

      expect(allowed, isA<Result<Unit>>());
      expect(allowed.isRight(), isTrue);
      expect(allowed.getRight(), unit);
    });

    test('carries a coded failure on the left', () {
      final result = _CheckAdult()(const _Age(16));

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().code, 'under_age');
    });

    test('composes with the Either combinators', () {
      final message = _CheckAdult()(const _Age(16))
          .map((_) => 'welcome')
          .getOrElse((failure) => failure.message);

      expect(message, 'Must be 18 or older.');
    });
  });
}
