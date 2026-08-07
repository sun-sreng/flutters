import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Success holds value and checks properties', () {
      const res = Result<int, String>.success(42);

      expect(res.isSuccess, isTrue);
      expect(res.isFailure, isFalse);
      expect(res.valueOrNull, equals(42));
      expect(res.errorOrNull, isNull);
      expect(res.getOrElse(0), equals(42));
    });

    test('Failure holds error and checks properties', () {
      const res = Result<int, String>.failure('error message');

      expect(res.isSuccess, isFalse);
      expect(res.isFailure, isTrue);
      expect(res.valueOrNull, isNull);
      expect(res.errorOrNull, equals('error message'));
      expect(res.getOrElse(0), equals(0));
    });

    test('map and mapError transform results correctly', () {
      const success = Result<int, String>.success(10);
      const failure = Result<int, String>.failure('fail');

      expect(success.map((v) => v * 2).valueOrNull, equals(20));
      expect(failure.map((v) => v * 2).isFailure, isTrue);

      expect(success.mapError((e) => e.toUpperCase()).valueOrNull, equals(10));
      expect(failure.mapError((e) => e.toUpperCase()).errorOrNull, equals('FAIL'));
    });

    test('flatMap binds results', () {
      const success = Result<int, String>.success(5);
      final bound = success.flatMap((v) => Result.success(v * 3));
      expect(bound.valueOrNull, equals(15));
    });

    test('when matches branches', () {
      const success = Result<int, String>.success(100);
      final text = success.when(
        onSuccess: (v) => 'Success: $v',
        onFailure: (e) => 'Failure: $e',
      );
      expect(text, equals('Success: 100'));
    });

    test('capture wraps sync exceptions', () {
      final success = Result.capture(() => 123);
      final failure = Result.capture(() => throw const FormatException('invalid'));

      expect(success.isSuccess, isTrue);
      expect(failure.isFailure, isTrue);
      expect(failure.errorOrNull, isA<FormatException>());
    });

    test('captureAsync wraps async exceptions', () async {
      final success = await Result.captureAsync(() async => 'hello');
      final failure = await Result.captureAsync(() async => throw StateError('err'));

      expect(success.valueOrNull, equals('hello'));
      expect(failure.errorOrNull, isA<StateError>());
    });
  });
}
