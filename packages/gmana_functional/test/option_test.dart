import 'package:gmana_functional/gmana_functional.dart';
import 'package:test/test.dart';

void main() {
  group('Option, Some, None', () {
    test('Option.fromNullable builds Some or None', () {
      final some = Option<int>.fromNullable(42);
      final none = Option<int>.fromNullable(null);

      expect(some.isSome(), isTrue);
      expect(some.isNone(), isFalse);
      expect(none.isNone(), isTrue);
      expect(none.isSome(), isFalse);
    });

    test('map and flatMap transform Some values and ignore None', () {
      const some = Some(10);
      const none = None<int>();

      expect(some.map((x) => x * 2), const Some(20));
      expect(none.map((x) => x * 2), const None<int>());

      expect(some.flatMap((x) => Some(x + 5)), const Some(15));
      expect(none.flatMap((x) => Some(x + 5)), const None<int>());
    });

    test('fold and getOrElse evaluate expected branches', () {
      const some = Some('hello');
      const none = None<String>();

      expect(some.fold(() => 'empty', (val) => 'val:$val'), 'val:hello');
      expect(none.fold(() => 'empty', (val) => 'val:$val'), 'empty');

      expect(some.getOrElse(() => 'fallback'), 'hello');
      expect(none.getOrElse(() => 'fallback'), 'fallback');
    });

    test('toEither converts Option to Either correctly', () {
      const some = Some(42);
      const none = None<int>();

      expect(some.toEither(() => 'err'), const Right<String, int>(42));
      expect(none.toEither(() => 'err'), const Left<String, int>('err'));
    });

    test('value equality and toString representation', () {
      expect(const Some(42), const Some(42));
      expect(const None<int>(), const None<int>());
      expect(const Some(42).toString(), 'Some(42)');
      expect(const None<int>().toString(), 'None');
    });
  });
}
