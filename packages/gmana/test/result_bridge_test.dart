import 'package:gmana/gmana.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('Result and Either Bridge Extensions', () {
    test('Either.toResult maps Right to Success and Left to Failure', () {
      const Either<String, int> successEither = Right(42);
      const Either<String, int> failureEither = Left('error_occurred');

      final successResult = successEither.toResult();
      final failureResult = failureEither.toResult();

      expect(successResult.isSuccess, isTrue);
      expect(successResult.valueOrNull, equals(42));

      expect(failureResult.isFailure, isTrue);
      expect(failureResult.errorOrNull, equals('error_occurred'));
    });

    test('Result.toEither maps Success to Right and Failure to Left', () {
      const GResult<int, String> successResult = GSuccess(100);
      const GResult<int, String> failureResult = GFailure('network_timeout');

      final successEither = successResult.toEither();
      final failureEither = failureResult.toEither();

      expect(successEither.isRight(), isTrue);
      expect(successEither.getRight(), equals(100));

      expect(failureEither.isLeft(), isTrue);
      expect(failureEither.getLeft(), equals('network_timeout'));
    });

    test('Future<Either>.toResultAsync converts asynchronously', () async {
      final futureSuccess = Future.value(const Right<String, int>(99));
      final futureFailure = Future.value(const Left<String, int>('async_fail'));

      final resSuccess = await futureSuccess.toResultAsync();
      final resFailure = await futureFailure.toResultAsync();

      expect(resSuccess.valueOrNull, equals(99));
      expect(resFailure.errorOrNull, equals('async_fail'));
    });

    test('Future<Result>.toEitherAsync converts asynchronously', () async {
      final futureSuccess = Future<GResult<int, String>>.value(
        const GSuccess(777),
      );
      final futureFailure = Future<GResult<int, String>>.value(
        const GFailure('async_err'),
      );

      final eitherSuccess = await futureSuccess.toEitherAsync();
      final eitherFailure = await futureFailure.toEitherAsync();

      expect(eitherSuccess.isRight(), isTrue);
      expect(eitherSuccess.getRight(), equals(777));

      expect(eitherFailure.isLeft(), isTrue);
      expect(eitherFailure.getLeft(), equals('async_err'));
    });

    test(
      'GResult combinators and pattern matching work via gmana umbrella',
      () {
        const GResult<int, String> res = GSuccess(10);

        var inspected = 0;
        final unchanged = res.inspectSuccess((v) => inspected = v);
        expect(unchanged.valueOrNull, equals(10));
        expect(inspected, equals(10));

        const GResult<int, String> failed = GFailure('broken');
        final recovered = failed.recover((err) => 999);
        expect(recovered.valueOrNull, equals(999));

        // Pattern matching with GSuccess and GFailure
        final description = switch (res) {
          GSuccess(:final value) => 'Got $value',
          GFailure(:final error) => 'Failed: $error',
        };
        expect(description, equals('Got 10'));
      },
    );
  });
}
