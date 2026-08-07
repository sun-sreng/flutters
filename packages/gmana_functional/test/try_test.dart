import 'package:gmana_functional/gmana_functional.dart';
import 'package:test/test.dart';

void main() {
  group('Try monad', () {
    test('wraps success and failure', () {
      final success = Try.of(() => int.parse('42'));
      final failure = Try.of(() => int.parse('invalid'));

      expect(success.isSuccess, isTrue);
      expect(success.getOrNull(), equals(42));
      expect(success.getOrElse(0), equals(42));

      expect(failure.isFailure, isTrue);
      expect(failure.getOrNull(), isNull);
      expect(failure.getOrElse(0), equals(0));
    });

    test('map and flatMap transform Try values', () {
      final success = Try.of(() => 10);
      final mapped = success.map((v) => v * 2);
      expect(mapped.getOrNull(), equals(20));

      final bound = success.flatMap((v) => Try.of(() => v + 5));
      expect(bound.getOrNull(), equals(15));
    });

    test('converts to Option and Either', () {
      final success = Try.of(() => 'ok');
      expect(success.toOption(), equals(const Some('ok')));
      expect(success.toEither().getRight(), equals('ok'));

      final failure = Try.of(() => throw const FormatException('err'));
      expect(failure.toOption().isNone(), isTrue);
      expect(failure.toEither().isLeft(), isTrue);
    });


  });
}
