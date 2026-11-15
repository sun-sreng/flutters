import 'package:gmana/functional.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('map and flatMap transform Right values', () {
      final Either<String, int> result = const Right<String, int>(21)
          .map((value) => value * 2)
          .flatMap((value) => Right<String, int>(value + 1));

      expect(result, const Right<String, int>(43));
      expect(result.getRight(), 43);
    });

    test('map and flatMap preserve Left values', () {
      const result = Left<String, int>('boom');

      expect(result.map((value) => value * 2), const Left<String, int>('boom'));
      expect(
        result.flatMap((value) => Right<String, int>(value * 2)),
        const Left<String, int>('boom'),
      );
    });

    test('mapLeft, bimap, and swap transform the appropriate side', () {
      const left = Left<String, int>('boom');
      const right = Right<String, int>(21);

      expect(
        left.mapLeft((value) => value.toUpperCase()),
        const Left<String, int>('BOOM'),
      );
      expect(right.mapLeft((value) => value.length), const Right<int, int>(21));
      expect(
        left.bimap((value) => value.length, (value) => value * 2),
        const Left<int, int>(4),
      );
      expect(
        right.bimap((value) => value.length, (value) => value * 2),
        const Right<int, int>(42),
      );
      expect(left.swap(), const Right<int, String>('boom'));
      expect(right.swap(), const Left<int, String>(21));
    });

    test(
      'fold, nullable accessors, and fallback access behave as expected',
      () {
        const left = Left<String, int>('boom');
        const right = Right<String, int>(21);

        expect(
          left.fold((value) => 'error: $value', (value) => '$value'),
          'error: boom',
        );
        expect(
          right.fold((value) => 'error: $value', (value) => '$value'),
          '21',
        );
        expect(left.leftOrNull(), 'boom');
        expect(left.rightOrNull(), isNull);
        expect(right.leftOrNull(), isNull);
        expect(right.rightOrNull(), 21);
        expect(left.getOrNull(), isNull);
        expect(right.getOrNull(), 21);
        expect(left.getOrElse((value) => value.length), 4);
        expect(right.getOrElse((value) => value.length), 21);
      },
    );

    test('predicates inspect Right values without unwrapping', () {
      const left = Left<String, int>('boom');
      const right = Right<String, int>(21);

      expect(left.contains(21), isFalse);
      expect(right.contains(21), isTrue);
      expect(right.contains(42), isFalse);
      expect(left.exists((value) => value > 20), isFalse);
      expect(right.exists((value) => value > 20), isTrue);
      expect(left.all((value) => value > 20), isTrue);
      expect(right.all((value) => value > 20), isTrue);
      expect(right.all((value) => value > 30), isFalse);
    });

    test('tap and tapLeft run side effects for the matching side', () {
      const left = Left<String, int>('boom');
      const right = Right<String, int>(21);
      final events = <String>[];

      expect(
        right
            .tap((value) => events.add('right:$value'))
            .tapLeft((value) => events.add('left:$value')),
        right,
      );
      expect(
        left
            .tap((value) => events.add('right:$value'))
            .tapLeft((value) => events.add('left:$value')),
        left,
      );
      expect(events, ['right:21', 'left:boom']);
    });

    test(
      'async helpers transform Right values and preserve Left values',
      () async {
        const left = Left<String, int>('boom');
        const right = Right<String, int>(21);

        expect(
          await right.mapAsync((value) async => value * 2),
          const Right<String, int>(42),
        );
        expect(
          await left.mapAsync((value) async => value * 2),
          const Left<String, int>('boom'),
        );
        expect(
          await right.flatMapAsync(
            (value) async => Right<String, int>(value + 1),
          ),
          const Right<String, int>(22),
        );
        expect(
          await left.flatMapAsync(
            (value) async => Right<String, int>(value + 1),
          ),
          const Left<String, int>('boom'),
        );
        expect(
          await right.foldAsync(
            (value) async => 'left:$value',
            (value) async => 'right:$value',
          ),
          'right:21',
        );
        expect(
          await left.foldAsync(
            (value) async => 'left:$value',
            (value) async => 'right:$value',
          ),
          'left:boom',
        );
      },
    );

    test('invalid side access throws StateError', () {
      const left = Left<String, int>('boom');
      const right = Right<String, int>(21);

      expect(left.getRight, throwsA(isA<StateError>()));
      expect(right.getLeft, throwsA(isA<StateError>()));
    });

    test('value semantics and string representation are stable', () {
      expect(const Left<String, int>('boom'), const Left<String, int>('boom'));
      expect(const Right<String, int>(21), const Right<String, int>(21));
      expect(
        const Left<String, int>('boom').hashCode,
        const Left<String, int>('boom').hashCode,
      );
      expect(
        const Right<String, int>(21).hashCode,
        const Right<String, int>(21).hashCode,
      );
      expect(const Left<String, int>('boom').toString(), 'Left(boom)');
      expect(const Right<String, int>(21).toString(), 'Right(21)');
    });

    group('equality agrees with hashCode', () {
      test('equal list values hash the same', () {
        // Distinct, non-const lists, so equality cannot come from identity.
        final a = Right<String, List<int>>(List.of(const [1, 2]));
        final b = Right<String, List<int>>(List.of(const [1, 2]));

        expect(a, b);
        expect(a.hashCode, b.hashCode);
        expect({a, b}, hasLength(1));
        expect(a, isNot(Right<String, List<int>>(List.of(const [2, 1]))));
      });

      test('Left compares list values the same way as Right', () {
        final a = Left<List<int>, String>(List.of(const [1, 2]));
        final b = Left<List<int>, String>(List.of(const [1, 2]));

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('equality is symmetric across type arguments', () {
        const Either<String, int> wide = Right(1);
        const Right<Never, int> narrow = Right(1);
        const Either<String, int> wideLeft = Left('e');
        const Left<String, Never> narrowLeft = Left('e');

        expect(wide == narrow, narrow == wide);
        expect(wide == narrow, isTrue);
        expect(wide.hashCode, narrow.hashCode);
        expect(wideLeft == narrowLeft, narrowLeft == wideLeft);
        expect(wideLeft == narrowLeft, isTrue);
        expect(wideLeft.hashCode, narrowLeft.hashCode);
      });

      test('Left and Right never equal each other', () {
        const Either<int, int> left = Left(1);
        const Either<int, int> right = Right(1);

        expect(left == right, isFalse);
        expect(right == left, isFalse);
      });
    });

    test('Either.tryCatch handles exceptions safely', () {
      final success = Either.tryCatch<String, int>(
        () => 42,
        (e, _) => e.toString(),
      );
      final failure = Either.tryCatch<String, int>(
        () => throw const FormatException('Invalid number'),
        (e, _) => 'Error: $e',
      );

      expect(success, const Right<String, int>(42));
      expect(failure.isLeft(), isTrue);
      expect(failure.fold((l) => l, (_) => ''), contains('FormatException'));
    });

    test('Either.tryCatchAsync handles async exceptions safely', () async {
      final success = await Either.tryCatchAsync<String, int>(
        () async => 100,
        (e, _) => e.toString(),
      );
      final failure = await Either.tryCatchAsync<String, int>(
        () async => throw StateError('Failed async'),
        (e, _) => 'Error: $e',
      );

      expect(success, const Right<String, int>(100));
      expect(failure.isLeft(), isTrue);
      expect(failure.fold((l) => l, (_) => ''), contains('Bad state'));
    });
  });
}
