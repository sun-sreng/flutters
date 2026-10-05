import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('GmanaResultX', () {
    test('getOrElseGet computes a fallback only for a failure', () {
      var calls = 0;
      const success = GResult<int, String>.success(7);
      const failure = GResult<int, String>.failure('missing');

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
      const success = GResult<int, String>.success(4);
      const failure = GResult<int, String>.failure('failed');

      final untouched = success.recover((error) {
        calls++;
        return error.length;
      });
      final recovered = failure.recover((error) {
        calls++;
        return error.length;
      });

      expect(identical(untouched, success), isTrue);
      expect(recovered, const GResult<int, String>.success(6));
      expect(calls, 1);
    });

    test('recoverWith can replace a failure with either result branch', () {
      var calls = 0;
      const success = GResult<int, String>.success(4);
      const failure = GResult<int, String>.failure('failed');

      final untouched = success.recoverWith((error) {
        calls++;
        return GResult<int, String>.success(error.length);
      });
      final stillFailed = failure.recoverWith((error) {
        calls++;
        return GResult<int, String>.failure(error.toUpperCase());
      });

      expect(identical(untouched, success), isTrue);
      expect(stillFailed, const GResult<int, String>.failure('FAILED'));
      expect(calls, 1);
    });

    test('inspectSuccess observes its branch and returns the same result', () {
      var seen = 0;
      const success = GResult<int, String>.success(9);
      const failure = GResult<int, String>.failure('no');

      final returnedSuccess = success.inspectSuccess((value) => seen = value);
      final returnedFailure = failure.inspectSuccess((_) => fail('not called'));

      expect(seen, 9);
      expect(identical(returnedSuccess, success), isTrue);
      expect(identical(returnedFailure, failure), isTrue);
    });

    test('inspectFailure observes its branch and returns the same result', () {
      String? seen;
      const success = GResult<int, String>.success(9);
      const failure = GResult<int, String>.failure('no');

      final returnedSuccess = success.inspectFailure((_) => fail('not called'));
      final returnedFailure = failure.inspectFailure((error) => seen = error);

      expect(seen, 'no');
      expect(identical(returnedSuccess, success), isTrue);
      expect(identical(returnedFailure, failure), isTrue);
    });

    test('inspect callback errors propagate', () {
      const result = GResult<int, String>.success(1);

      expect(
        () => result.inspectSuccess((_) => throw StateError('observer')),
        throwsStateError,
      );
    });

    test('mapAsync accepts synchronous and asynchronous transforms', () async {
      const result = GResult<int, String>.success(3);

      final syncMapped = await result.mapAsync((value) => value * 2);
      final asyncMapped = await result.mapAsync(
        (value) async => value.toString(),
      );

      expect(syncMapped, const GResult<int, String>.success(6));
      expect(asyncMapped, const GResult<String, String>.success('3'));
    });

    test('mapAsync skips a failure and propagates transform errors', () async {
      const failure = GResult<int, String>.failure('no');
      var calls = 0;

      final unchanged = await failure.mapAsync((value) {
        calls++;
        return value * 2;
      });

      expect(unchanged, const GResult<int, String>.failure('no'));
      expect(calls, 0);
      await expectLater(
        const GResult<int, String>.success(
          1,
        ).mapAsync((_) => throw StateError('transform')),
        throwsStateError,
      );
    });

    test(
      'flatMapAsync accepts synchronous and asynchronous transforms',
      () async {
        const result = GResult<int, String>.success(3);

        final syncMapped = await result.flatMapAsync(
          (value) => GResult<String, String>.success('$value!'),
        );
        final asyncMapped = await result.flatMapAsync(
          (value) async => GResult<double, String>.success(value / 2),
        );

        expect(syncMapped, const GResult<String, String>.success('3!'));
        expect(asyncMapped, const GResult<double, String>.success(1.5));
      },
    );

    test(
      'flatMapAsync skips a failure and propagates transform errors',
      () async {
        const failure = GResult<int, String>.failure('no');
        var calls = 0;

        final unchanged = await failure.flatMapAsync((value) {
          calls++;
          return GResult<int, String>.success(value * 2);
        });

        expect(unchanged, const GResult<int, String>.failure('no'));
        expect(calls, 0);
        await expectLater(
          const GResult<int, String>.success(
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

        expect(success, const GResult<int, Object>.success(5));
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
      expect(result, GResult<int, String>.failure('mapped: $error'));
    });

    test('toResultWith does not call the mapper for a value', () async {
      final result = await Future.value(
        5,
      ).toResultWith<String>((_, _) => fail('not called'));

      expect(result, const GResult<int, String>.success(5));
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
        const GResult<int, String>.success(2),
      ).mapResult((value) => value * 3);
      final asyncMapped = await Future.value(
        const GResult<int, String>.success(2),
      ).mapResult((value) async => '$value!');

      expect(syncMapped, const GResult<int, String>.success(6));
      expect(asyncMapped, const GResult<String, String>.success('2!'));
    });

    test('mapResult skips a Result failure', () async {
      var calls = 0;
      final result = await Future.value(
        const GResult<int, String>.failure('failed'),
      ).mapResult((value) {
        calls++;
        return value * 2;
      });

      expect(result, const GResult<int, String>.failure('failed'));
      expect(calls, 0);
    });

    test('flatMapResult accepts sync and async transforms', () async {
      final syncMapped = await Future.value(
        const GResult<int, String>.success(2),
      ).flatMapResult((value) => GResult<String, String>.success('$value!'));
      final asyncMapped = await Future.value(
        const GResult<int, String>.success(2),
      ).flatMapResult(
        (value) async => GResult<double, String>.success(value / 2),
      );

      expect(syncMapped, const GResult<String, String>.success('2!'));
      expect(asyncMapped, const GResult<double, String>.success(1));
    });

    test('flatMapResult skips a Result failure', () async {
      var calls = 0;
      final result = await Future.value(
        const GResult<int, String>.failure('failed'),
      ).flatMapResult((value) {
        calls++;
        return GResult<int, String>.success(value * 2);
      });

      expect(result, const GResult<int, String>.failure('failed'));
      expect(calls, 0);
    });

    test(
      'whenResult selects one branch and supports async callbacks',
      () async {
        var successCalls = 0;
        var failureCalls = 0;

        final success = await Future.value(
          const GResult<int, String>.success(2),
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
          const GResult<int, String>.failure('no'),
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
        Future<GResult<int, String>>.error(
          StateError('source'),
        ).mapResult((value) => value * 2),
        throwsStateError,
      );
      await expectLater(
        Future.value(
          const GResult<int, String>.success(1),
        ).flatMapResult<int>((_) => throw ArgumentError('transform')),
        throwsArgumentError,
      );
    });
  });

  group('GmanaIterableResultX', () {
    test('sequenceResults preserves success order and handles empty input', () {
      final result =
          <GResult<int, String>>[
            const GResult<int, String>.success(3),
            const GResult<int, String>.success(1),
            const GResult<int, String>.success(2),
          ].sequenceResults();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, [3, 1, 2]);

      final empty = <GResult<int, String>>[].sequenceResults();
      expect(empty.isSuccess, isTrue);
      expect(empty.valueOrNull, isEmpty);
    });

    test('sequenceResults stops consuming at the first failure', () {
      var visited = 0;

      Iterable<GResult<int, String>> results() sync* {
        visited++;
        yield const GResult<int, String>.success(1);
        visited++;
        yield const GResult<int, String>.failure('first');
        visited++;
        yield const GResult<int, String>.failure('second');
      }

      expect(
        results().sequenceResults(),
        const GResult<List<int>, String>.failure('first'),
      );
      expect(visited, 2);
    });

    test('partitionResults consumes once and preserves branch order', () {
      var iterations = 0;
      var visited = 0;

      Iterable<GResult<int, String>> results() sync* {
        iterations++;
        for (final result in <GResult<int, String>>[
          const GResult<int, String>.failure('a'),
          const GResult<int, String>.success(3),
          const GResult<int, String>.failure('b'),
          const GResult<int, String>.success(1),
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
      final partition = <GResult<int, String>>[].partitionResults();

      expect(partition.successes, isEmpty);
      expect(partition.failures, isEmpty);
    });
  });
}
