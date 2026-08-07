import 'package:gmana_functional/gmana_functional.dart';
import 'package:test/test.dart';

Either<String, int> right(int value) => Right<String, int>(value);
Either<String, int> left(String value) => Left<String, int>(value);

void main() {
  group('Either.cond', () {
    test('picks the branch matching the condition', () {
      expect(Either.cond(true, () => 'no', () => 1), right(1));
      expect(Either.cond(false, () => 'no', () => 1), left('no'));
    });

    test('only evaluates the branch it needs', () {
      var trueCalls = 0;
      var falseCalls = 0;

      Either.cond(true, () {
        falseCalls++;
        return 'no';
      }, () {
        trueCalls++;
        return 1;
      });

      expect(trueCalls, 1);
      expect(falseCalls, 0);
    });
  });

  group('Either.fromNullable', () {
    test('lifts a value into Right', () {
      expect(Either.fromNullable(5, () => 'missing'), right(5));
    });

    test('turns null into Left', () {
      expect(Either.fromNullable<String, int>(null, () => 'missing'),
          left('missing'));
    });
  });

  group('Either.sequence', () {
    test('collects every Right value', () {
      expect(
        Either.sequence([right(1), right(2), right(3)]),
        Right<String, List<int>>([1, 2, 3]),
      );
    });

    test('short-circuits on the first Left', () {
      expect(
        Either.sequence([right(1), left('first'), left('second')]),
        Left<String, List<int>>('first'),
      );
    });

    test('an empty collection is a Right of nothing', () {
      expect(
        Either.sequence(<Either<String, int>>[]),
        Right<String, List<int>>([]),
      );
    });

    test('stops evaluating after the first Left', () {
      var visited = 0;
      Iterable<Either<String, int>> items() sync* {
        visited++;
        yield left('stop');
        visited++;
        yield right(2);
      }

      Either.sequence(items());
      expect(visited, 1);
    });
  });

  group('Either.traverse', () {
    test('maps then sequences', () {
      final result = Either.traverse<String, String, int>(
        ['1', '2'],
        (text) => Either.fromNullable(int.tryParse(text), () => 'bad: $text'),
      );

      expect(result, Right<String, List<int>>([1, 2]));
    });

    test('reports the first failure', () {
      final result = Either.traverse<String, String, int>(
        ['1', 'x', 'y'],
        (text) => Either.fromNullable(int.tryParse(text), () => 'bad: $text'),
      );

      expect(result, Left<String, List<int>>('bad: x'));
    });
  });

  group('Either recovery', () {
    test('orElse replaces a Left with another Either', () {
      expect(left('boom').orElse((_) => right(0)), right(0));
      expect(left('boom').orElse((_) => left('worse')), left('worse'));
      expect(right(1).orElse((_) => right(0)), right(1));
    });

    test('orElse passes the left value to the recovery', () {
      expect(left('boom').orElse((l) => right(l.length)), right(4));
    });

    test('orElseWith can change the left type', () {
      final Either<int, int> recovered =
          left('boom').orElseWith((l) => Left<int, int>(l.length));

      expect(recovered, Left<int, int>(4));
      expect(right(7).orElseWith((l) => Left<int, int>(0)), Right<int, int>(7));
    });

    test('recover always produces a Right', () {
      expect(left('boom').recover((l) => l.length), right(4));
      expect(right(1).recover((_) => 99), right(1));
    });

    test('flatMapLeft chains on the failure side', () {
      final Either<int, int> chained =
          left('boom').flatMapLeft((l) => Left<int, int>(l.length));

      expect(chained, Left<int, int>(4));
      expect(
        right(3).flatMapLeft((l) => Left<int, int>(0)),
        Right<int, int>(3),
      );
    });
  });

  group('Either.filterOrElse', () {
    test('demotes a Right that fails the test', () {
      expect(
        right(-1).filterOrElse((n) => n > 0, (n) => 'not positive: $n'),
        left('not positive: -1'),
      );
    });

    test('keeps a Right that passes', () {
      expect(right(5).filterOrElse((n) => n > 0, (_) => 'nope'), right(5));
    });

    test('leaves a Left alone', () {
      expect(left('boom').filterOrElse((n) => n > 0, (_) => 'nope'),
          left('boom'));
    });
  });

  group('Either combining', () {
    test('zip pairs two Rights', () {
      final result = right(1).zip(Right<String, String>('a'));
      expect(result, Right<String, (int, String)>((1, 'a')));
    });

    test('zip reports the first Left, this side winning', () {
      expect(
        left('mine').zip(Left<String, String>('theirs')),
        Left<String, (int, String)>('mine'),
      );
      expect(
        right(1).zip(Left<String, String>('theirs')),
        Left<String, (int, String)>('theirs'),
      );
    });

    test('zipWith combines through a function', () {
      final result = right(2).zipWith(
        Right<String, int>(3),
        (a, b) => a * b,
      );

      expect(result, right(6));
    });
  });

  group('Either conversion', () {
    test('getOrDefault', () {
      expect(right(1).getOrDefault(99), 1);
      expect(left('boom').getOrDefault(99), 99);
    });

    test('toOption discards the left value', () {
      expect(right(1).toOption(), Some(1));
      expect(left('boom').toOption(), None<int>());
    });

    test('toList', () {
      expect(right(1).toList(), [1]);
      expect(left('boom').toList(), isEmpty);
    });
  });

  group('IterableEitherX', () {
    test('sequence mirrors Either.sequence', () {
      expect(
        [right(1), right(2)].sequence(),
        Right<String, List<int>>([1, 2]),
      );
      expect(
        [right(1), left('bad')].sequence(),
        Left<String, List<int>>('bad'),
      );
    });

    test('lefts and rights split the collection', () {
      final items = [right(1), left('a'), right(2), left('b')];

      expect(items.lefts, ['a', 'b']);
      expect(items.rights, [1, 2]);
    });

    test('partitionEithers reports every failure, unlike sequence', () {
      final items = [right(1), left('a'), right(2), left('b')];
      final (lefts, rights) = items.partitionEithers();

      expect(lefts, ['a', 'b']);
      expect(rights, [1, 2]);
    });

    test('partitionEithers on an empty collection', () {
      final (lefts, rights) = <Either<String, int>>[].partitionEithers();

      expect(lefts, isEmpty);
      expect(rights, isEmpty);
    });

    test('allRight and anyLeft', () {
      expect([right(1), right(2)].allRight, isTrue);
      expect([right(1), left('a')].allRight, isFalse);
      expect([right(1), left('a')].anyLeft, isTrue);
      expect([right(1), right(2)].anyLeft, isFalse);
      expect(<Either<String, int>>[].allRight, isTrue);
      expect(<Either<String, int>>[].anyLeft, isFalse);
    });
  });

  group('FutureEitherX', () {
    Future<Either<String, int>> futureRight(int value) async => right(value);
    Future<Either<String, int>> futureLeft(String value) async => left(value);

    test('map transforms the right value', () async {
      expect(await futureRight(2).map((n) => n * 3), right(6));
      expect(await futureLeft('boom').map((n) => n * 3), left('boom'));
    });

    test('map accepts an async transform', () async {
      expect(
        await futureRight(2).map((n) async => n * 3),
        right(6),
      );
    });

    test('mapLeft transforms the left value', () async {
      expect(
        await futureLeft('boom').mapLeft((l) => l.length),
        Left<int, int>(4),
      );
      expect(
        await futureRight(1).mapLeft((l) => l.length),
        Right<int, int>(1),
      );
    });

    test('flatMap chains another fallible step', () async {
      expect(
        await futureRight(2).flatMap((n) async => right(n + 1)),
        right(3),
      );
      expect(
        await futureRight(2).flatMap((n) async => left('rejected')),
        left('rejected'),
      );
      expect(
        await futureLeft('boom').flatMap((n) async => right(n)),
        left('boom'),
      );
    });

    test('fold collapses both sides', () async {
      expect(
        await futureRight(2).fold((l) => 'L:$l', (r) => 'R:$r'),
        'R:2',
      );
      expect(
        await futureLeft('boom').fold((l) => 'L:$l', (r) => 'R:$r'),
        'L:boom',
      );
    });

    test('getOrElse, getOrDefault, and getOrNull', () async {
      expect(await futureRight(2).getOrElse((_) => 0), 2);
      expect(await futureLeft('boom').getOrElse((l) => l.length), 4);
      expect(await futureLeft('boom').getOrDefault(9), 9);
      expect(await futureRight(2).getOrNull(), 2);
      expect(await futureLeft('boom').getOrNull(), isNull);
    });

    test('tap and tapLeft observe without changing the value', () async {
      final seen = <String>[];

      final result = await futureRight(2)
          .tap((r) => seen.add('right:$r'))
          .tapLeft((l) => seen.add('left:$l'));

      expect(result, right(2));
      expect(seen, ['right:2']);

      seen.clear();
      await futureLeft('boom')
          .tap((r) => seen.add('right:$r'))
          .tapLeft((l) => seen.add('left:$l'));
      expect(seen, ['left:boom']);
    });

    test('orElseWith recovers asynchronously', () async {
      expect(
        await futureLeft('boom').orElseWith((_) async => right(0)),
        right(0),
      );
      expect(
        await futureRight(1).orElseWith((_) async => right(0)),
        right(1),
      );
    });

    test('isRight and isLeft', () async {
      expect(await futureRight(1).isRight, isTrue);
      expect(await futureRight(1).isLeft, isFalse);
      expect(await futureLeft('boom').isLeft, isTrue);
    });

    test('chains read as one pipeline', () async {
      final label = await futureRight(20)
          .map((n) => n + 1)
          .flatMap((n) async => n.isOdd ? right(n) : left('even'))
          .map((n) => 'value $n')
          .getOrElse((failure) => 'failed: $failure');

      expect(label, 'value 21');
    });
  });
}
