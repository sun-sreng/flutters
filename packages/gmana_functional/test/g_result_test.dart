import 'package:gmana_functional/gmana_functional.dart';
import 'package:test/test.dart';

// The combinators are exercised in gmana_utils, which re-exports this type
// under its former names. These cover the type and the bridge from the package
// that declares them.
void main() {
  group('GResult', () {
    test('is exhaustive over GSuccess and GFailure', () {
      String describe(GResult<int, String> result) => switch (result) {
        GSuccess(:final value) => 'ok $value',
        GFailure(:final error) => 'failed $error',
      };

      expect(describe(const GResult.success(1)), 'ok 1');
      expect(describe(const GResult.failure('boom')), 'failed boom');
    });

    test('capture turns a throw into a failure', () {
      final parsed = GResult.capture(() => int.parse('nope'));

      expect(parsed.isFailure, isTrue);
      expect(parsed.errorOrNull, isA<FormatException>());
    });

    test('coexists with the Either-based Result alias and Failure', () {
      const Result<int> either = Right(1);
      const GResult<int, Failure> result = GFailure(Failure('nope'));

      expect(either.isRight(), isTrue);
      expect(result.errorOrNull?.message, 'nope');
    });
  });

  group('Either and GResult bridge', () {
    test('converts in both directions', () {
      const Either<String, int> right = Right(42);
      const Either<String, int> left = Left('error');

      expect(right.toResult(), const GSuccess<int, String>(42));
      expect(left.toResult(), const GFailure<int, String>('error'));
      expect(const GSuccess<int, String>(42).toEither(), right);
      expect(const GFailure<int, String>('error').toEither(), left);
    });

    test('converts futures in both directions', () async {
      final result =
          await Future.value(const Right<String, int>(7)).toResultAsync();
      final either =
          await Future<GResult<int, String>>.value(
            const GFailure('late'),
          ).toEitherAsync();

      expect(result.valueOrNull, 7);
      expect(either.leftOrNull(), 'late');
    });
  });
}
