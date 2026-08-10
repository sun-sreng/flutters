import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('GmanaResultX', () {
    test('getOrElseGet computes a fallback only for a failure', () {
      var calls = 0;
      const success = Result<int, String>.success(7);
      const failure = Result<int, String>.failure('missing');

      expect(
        success.getOrElseGet((error) {
          calls++;
          return error.length;
        }),
        7,
      );
      expect(calls, 0);

      expect(
        failure.getOrElseGet((error) {
          calls++;
          return error.length;
        }),
        7,
      );
      expect(calls, 1);
    });

    test('recover transforms only a failure into a success', () {
      var calls = 0;
      const success = Result<int, String>.success(4);
      const failure = Result<int, String>.failure('failed');

      final untouched = success.recover((error) {
        calls++;
        return error.length;
      });
      final recovered = failure.recover((error) {
        calls++;
        return error.length;
      });

      expect(identical(untouched, success), isTrue);
      expect(recovered, const Result<int, String>.success(6));
      expect(calls, 1);
    });

    test('recoverWith can replace a failure with either result branch', () {
      var calls = 0;
      const success = Result<int, String>.success(4);
      const failure = Result<int, String>.failure('failed');

      final untouched = success.recoverWith((error) {
        calls++;
        return Result<int, String>.success(error.length);
      });
      final stillFailed = failure.recoverWith((error) {
        calls++;
        return Result<int, String>.failure(error.toUpperCase());
      });

      expect(identical(untouched, success), isTrue);
      expect(stillFailed, const Result<int, String>.failure('FAILED'));
      expect(calls, 1);
    });

    test('inspectSuccess observes its branch and returns the same result', () {
      var seen = 0;
      const success = Result<int, String>.success(9);
      const failure = Result<int, String>.failure('no');

      final returnedSuccess = success.inspectSuccess((value) => seen = value);
      final returnedFailure = failure.inspectSuccess((_) => fail('not called'));

      expect(seen, 9);
      expect(identical(returnedSuccess, success), isTrue);
      expect(identical(returnedFailure, failure), isTrue);
    });

    test('inspectFailure observes its branch and returns the same result', () {
      String? seen;
      const success = Result<int, String>.success(9);
      const failure = Result<int, String>.failure('no');

      final returnedSuccess = success.inspectFailure((_) => fail('not called'));
      final returnedFailure = failure.inspectFailure((error) => seen = error);

      expect(seen, 'no');
      expect(identical(returnedSuccess, success), isTrue);
      expect(identical(returnedFailure, failure), isTrue);
    });

    test('inspect callback errors propagate', () {
      const result = Result<int, String>.success(1);

      expect(
        () => result.inspectSuccess((_) => throw StateError('observer')),
        throwsStateError,
      );
    });

    test('mapAsync accepts synchronous and asynchronous transforms', () async {
      const result = Result<int, String>.success(3);

      final syncMapped = await result.mapAsync((value) => value * 2);
      final asyncMapped = await result.mapAsync(
        (value) async => value.toString(),
      );

      expect(syncMapped, const Result<int, String>.success(6));
      expect(asyncMapped, const Result<String, String>.success('3'));
    });

    test('mapAsync skips a failure and propagates transform errors', () async {
      const failure = Result<int, String>.failure('no');
      var calls = 0;

      final unchanged = await failure.mapAsync((value) {
        calls++;
        return value * 2;
      });

      expect(unchanged, const Result<int, String>.failure('no'));
      expect(calls, 0);
      await expectLater(
        const Result<int, String>.success(
          1,
        ).mapAsync((_) => throw StateError('transform')),
        throwsStateError,
      );
    });

    test(
      'flatMapAsync accepts synchronous and asynchronous transforms',
      () async {
        const result = Result<int, String>.success(3);

        final syncMapped = await result.flatMapAsync(
          (value) => Result<String, String>.success('$value!'),
        );
        final asyncMapped = await result.flatMapAsync(
          (value) async => Result<double, String>.success(value / 2),
        );

        expect(syncMapped, const Result<String, String>.success('3!'));
        expect(asyncMapped, const Result<double, String>.success(1.5));
      },
    );

    test(
      'flatMapAsync skips a failure and propagates transform errors',
      () async {
        const failure = Result<int, String>.failure('no');
        var calls = 0;

        final unchanged = await failure.flatMapAsync((value) {
          calls++;
          return Result<int, String>.success(value * 2);
        });

        expect(unchanged, const Result<int, String>.failure('no'));
        expect(calls, 0);
        await expectLater(
          const Result<int, String>.success(
            1,
          ).flatMapAsync<int>((_) => throw StateError('transform')),
          throwsStateError,
        );
      },
    );
  });

  group('GmanaFutureToResultX', () {
    test(
      'toResult converts values and errors to the matching branch',
      () async {
        final error = StateError('failed');

        final success = await Future.value(5).toResult();
        final failure = await Future<int>.error(error).toResult();

        expect(success, const Result<int, Object>.success(5));
        expect(failure.isFailure, isTrue);
        expect(identical(failure.errorOrNull, error), isTrue);
      },
    );

    test('toResultWith maps an error and receives its stack trace', () async {
      final error = StateError('failed');
      final sourceStack = StackTrace.fromString('source-stack');
      StackTrace? seenStack;

      final result = await Future<int>.error(error, sourceStack).toResultWith((
        seenError,
        stackTrace,
      ) {
        expect(identical(seenError, error), isTrue);
        seenStack = stackTrace;
        return 'mapped: $seenError';
      });

      expect(seenStack.toString(), sourceStack.toString());
      expect(result, Result<int, String>.failure('mapped: $error'));
    });

    test('toResultWith does not call the mapper for a value', () async {
      final result = await Future.value(
        5,
      ).toResultWith<String>((_, _) => fail('not called'));

      expect(result, const Result<int, String>.success(5));
    });

    test('toResultWith propagates mapper errors', () async {
      await expectLater(
        Future<int>.error(
          StateError('source'),
        ).toResultWith<String>((_, _) => throw ArgumentError('mapper')),
        throwsArgumentError,
      );
    });
  });

  group('GmanaFutureResultX', () {
    test('mapResult accepts sync and async transforms', () async {
      final syncMapped = await Future.value(
        const Result<int, String>.success(2),
      ).mapResult((value) => value * 3);
      final asyncMapped = await Future.value(
        const Result<int, String>.success(2),
      ).mapResult((value) async => '$value!');

      expect(syncMapped, const Result<int, String>.success(6));
      expect(asyncMapped, const Result<String, String>.success('2!'));
    });

    test('mapResult skips a Result failure', () async {
      var calls = 0;
      final result = await Future.value(
        const Result<int, String>.failure('failed'),
      ).mapResult((value) {
        calls++;
        return value * 2;
      });

      expect(result, const Result<int, String>.failure('failed'));
      expect(calls, 0);
    });

    test('flatMapResult accepts sync and async transforms', () async {
      final syncMapped = await Future.value(
        const Result<int, String>.success(2),
      ).flatMapResult((value) => Result<String, String>.success('$value!'));
      final asyncMapped = await Future.value(
        const Result<int, String>.success(2),
      ).flatMapResult(
        (value) async => Result<double, String>.success(value / 2),
      );

      expect(syncMapped, const Result<String, String>.success('2!'));
      expect(asyncMapped, const Result<double, String>.success(1));
    });

    test('flatMapResult skips a Result failure', () async {
      var calls = 0;
      final result = await Future.value(
        const Result<int, String>.failure('failed'),
      ).flatMapResult((value) {
        calls++;
        return Result<int, String>.success(value * 2);
      });

      expect(result, const Result<int, String>.failure('failed'));
      expect(calls, 0);
    });

    test(
      'whenResult selects one branch and supports async callbacks',
      () async {
        var successCalls = 0;
        var failureCalls = 0;

        final success = await Future.value(
          const Result<int, String>.success(2),
        ).whenResult(
          onSuccess: (value) async {
            successCalls++;
            return 'value: $value';
          },
          onFailure: (error) {
            failureCalls++;
            return 'error: $error';
          },
        );
        final failure = await Future.value(
          const Result<int, String>.failure('no'),
        ).whenResult(
          onSuccess: (value) {
            successCalls++;
            return 'value: $value';
          },
          onFailure: (error) async {
            failureCalls++;
            return 'error: $error';
          },
        );

        expect(success, 'value: 2');
        expect(failure, 'error: no');
        expect(successCalls, 1);
        expect(failureCalls, 1);
      },
    );

    test('source future and transform errors propagate', () async {
      await expectLater(
        Future<Result<int, String>>.error(
          StateError('source'),
        ).mapResult((value) => value * 2),
        throwsStateError,
      );
      await expectLater(
        Future.value(
          const Result<int, String>.success(1),
        ).flatMapResult<int>((_) => throw ArgumentError('transform')),
        throwsArgumentError,
      );
    });
  });

  group('GmanaIterableResultX', () {
    test('sequenceResults preserves success order and handles empty input', () {
      final result =
          <Result<int, String>>[
            const Result<int, String>.success(3),
            const Result<int, String>.success(1),
            const Result<int, String>.success(2),
          ].sequenceResults();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, [3, 1, 2]);

      final empty = <Result<int, String>>[].sequenceResults();
      expect(empty.isSuccess, isTrue);
      expect(empty.valueOrNull, isEmpty);
    });

    test('sequenceResults stops consuming at the first failure', () {
      var visited = 0;

      Iterable<Result<int, String>> results() sync* {
        visited++;
        yield const Result<int, String>.success(1);
        visited++;
        yield const Result<int, String>.failure('first');
        visited++;
        yield const Result<int, String>.failure('second');
      }

      expect(
        results().sequenceResults(),
        const Result<List<int>, String>.failure('first'),
      );
      expect(visited, 2);
    });

    test('partitionResults consumes once and preserves branch order', () {
      var iterations = 0;
      var visited = 0;

      Iterable<Result<int, String>> results() sync* {
        iterations++;
        for (final result in <Result<int, String>>[
          const Result<int, String>.failure('a'),
          const Result<int, String>.success(3),
          const Result<int, String>.failure('b'),
          const Result<int, String>.success(1),
        ]) {
          visited++;
          yield result;
        }
      }

      final partition = results().partitionResults();

      expect(partition.successes, [3, 1]);
      expect(partition.failures, ['a', 'b']);
      expect(iterations, 1);
      expect(visited, 4);
    });

    test('partitionResults returns two empty lists for empty input', () {
      final partition = <Result<int, String>>[].partitionResults();

      expect(partition.successes, isEmpty);
      expect(partition.failures, isEmpty);
    });
  });
}
