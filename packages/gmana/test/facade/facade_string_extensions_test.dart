import 'package:gmana/gmana.dart';
import 'package:test/test.dart';

// gmana_extensions and gmana_predicates both declare these members on String.
// This file fails to compile, rather than fails at runtime, if the facade ever
// exports both declarations again.
void main() {
  test('String classification members resolve through the facade', () {
    const text = 'user@example.com';
    const date = '2024-01-31';

    expect(text.isEmail, isTrue);
    expect(text.isUrl(), isFalse);
    expect(text.isAlpha, isFalse);
    expect('42'.isNumeric, isTrue);
    expect(text.containsIgnoreCase('USER'), isTrue);

    expect(date.isDate, isTrue);
    expect(date.isPast, isTrue);
    expect(date.isFuture, isFalse);
    expect(date.isToday, isFalse);
    expect(date.isWeekday, isTrue);
    expect(date.isWeekend, isFalse);
    expect(date.isLeapYear, isTrue);
    expect(date.isAfter('2024-01-01'), isTrue);
    expect(date.isBefore('2024-02-01'), isTrue);
    expect(date.isBetween('2024-01-01', '2024-02-01'), isTrue);
  });

  test('nullable String classification resolves through the facade', () {
    String? missing;

    expect(missing.isNullOrEmpty, isTrue);
    expect(''.isNullOrEmpty, isTrue);
    expect('value'.isNullOrEmpty, isFalse);
  });
}
