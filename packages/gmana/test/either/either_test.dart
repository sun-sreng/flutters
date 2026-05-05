import 'package:gmana/gmana.dart' hide isNull;
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('map and flatMap transform Right values', () {
      final Either<String, int> result = Right<String, int>(21)
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
  });
}
