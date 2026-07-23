import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('NumDurationExtension', () {
    test('seconds creates correct Duration', () {
      expect(5.seconds, equals(const Duration(seconds: 5)));
    });

    test('minutes creates correct Duration', () {
      expect(2.minutes, equals(const Duration(minutes: 2)));
    });
  });

  group('HumanizedDuration', () {
    test('toHuman formats short durations', () {
      expect(const Duration(seconds: 5).toHuman(), equals('5.0s'));
    });

    test('isZero returns true for zero duration', () {
      expect(HumanizedDuration(Duration.zero).isZero, isTrue);
    });

    test('toHHMMSS formats correctly', () {
      expect(
        const Duration(hours: 1, minutes: 2, seconds: 3).toHHMMSS(),
        equals('01:02:03'),
      );
    });
  });

  group('NumX', () {
    test('celsiusToFahrenheit converts correctly', () {
      expect(0.celsiusToFahrenheit, equals(32.0));
      expect(100.celsiusToFahrenheit, equals(212.0));
    });

    test('isBetween returns correct result', () {
      expect(5.isBetween(1, 10), isTrue);
      expect(0.isBetween(1, 10), isFalse);
    });
  });

  group('IntX', () {
    test('digits returns individual digits', () {
      expect(1234.digits, equals([1, 2, 3, 4]));
    });

    test('to generates inclusive range', () {
      expect(1.to(5).toList(), equals([1, 2, 3, 4, 5]));
    });
  });

  group('StringX', () {
    test('toTitleCase capitalizes words', () {
      expect('hello world'.toTitleCase, equals('Hello World'));
    });

    test('toSnakeCase converts correctly', () {
      expect('helloWorld'.toSnakeCase, equals('hello_world'));
    });

    test('isBlank returns true for whitespace', () {
      expect('   '.isBlank, isTrue);
      expect('hi'.isBlank, isFalse);
    });
  });

  group('StringNullableX', () {
    test('orEmpty returns empty string for null', () {
      const String? value = null;
      expect(value.orEmpty, equals(''));
    });

    test('isNullOrBlank returns true for null', () {
      const String? value = null;
      expect(value.isNullOrBlank, isTrue);
    });
  });

  group('IterableNumX', () {
    test('sum returns correct total', () {
      expect([1, 2, 3].sum(), equals(6));
    });

    test('average returns correct mean', () {
      expect([1.0, 2.0, 3.0].average, equals(2.0));
    });
  });

  group('IterableX', () {
    test('chunked splits correctly', () {
      expect(
        [1, 2, 3, 4, 5].chunked(2).toList(),
        equals([
          [1, 2],
          [3, 4],
          [5],
        ]),
      );
    });

    test('groupBy groups correctly', () {
      final result = [1, 2, 3, 4].groupBy((e) => e.isEven ? 'even' : 'odd');
      expect(result['even'], equals([2, 4]));
      expect(result['odd'], equals([1, 3]));
    });
  });

  group('StreamX', () {
    test('whereNotNull filters nulls', () async {
      final stream = Stream.fromIterable([1, null, 2, null, 3]);
      final result = await stream.whereNotNull<int>().toList();
      expect(result, equals([1, 2, 3]));
    });
  });
}
