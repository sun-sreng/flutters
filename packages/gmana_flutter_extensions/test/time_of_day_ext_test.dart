import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

const _nineAm = TimeOfDay(hour: 9, minute: 0);
const _noon = TimeOfDay(hour: 12, minute: 0);
const _fivePm = TimeOfDay(hour: 17, minute: 0);

void main() {
  group('TimeOfDayExtensions.fromMinutes', () {
    test('builds from minutes past midnight', () {
      expect(
        TimeOfDayExtensions.fromMinutes(0),
        const TimeOfDay(hour: 0, minute: 0),
      );
      expect(
        TimeOfDayExtensions.fromMinutes(90),
        const TimeOfDay(hour: 1, minute: 30),
      );
      expect(
        TimeOfDayExtensions.fromMinutes(1439),
        const TimeOfDay(hour: 23, minute: 59),
      );
    });

    test('wraps past a full day', () {
      expect(
        TimeOfDayExtensions.fromMinutes(1500),
        const TimeOfDay(hour: 1, minute: 0),
      );
    });

    test('wraps negative minutes backwards into the day', () {
      expect(
        TimeOfDayExtensions.fromMinutes(-30),
        const TimeOfDay(hour: 23, minute: 30),
      );
    });
  });

  group('TimeOfDayExtensions conversions', () {
    test('inMinutes and asFractionalHours', () {
      const time = TimeOfDay(hour: 13, minute: 30);

      expect(time.inMinutes, 810);
      expect(time.asFractionalHours, 13.5);
      expect(time.sinceMidnight, const Duration(hours: 13, minutes: 30));
    });

    test('isMidnight and isNoon', () {
      expect(const TimeOfDay(hour: 0, minute: 0).isMidnight, isTrue);
      expect(const TimeOfDay(hour: 0, minute: 1).isMidnight, isFalse);
      expect(_noon.isNoon, isTrue);
      expect(const TimeOfDay(hour: 0, minute: 0).isNoon, isFalse);
    });

    test('to24HourString pads both parts', () {
      expect(const TimeOfDay(hour: 9, minute: 5).to24HourString(), '09:05');
      expect(const TimeOfDay(hour: 23, minute: 59).to24HourString(), '23:59');
      expect(const TimeOfDay(hour: 0, minute: 0).to24HourString(), '00:00');
    });

    test('toCustomString keeps the existing 12-hour format', () {
      expect(const TimeOfDay(hour: 13, minute: 5).toCustomString(), '01:05 PM');
      expect(const TimeOfDay(hour: 9, minute: 5).toCustomString(), '09:05 AM');
    });

    test('toDateTime borrows the calendar date', () {
      final result = const TimeOfDay(
        hour: 14,
        minute: 30,
      ).toDateTime(DateTime(2024, 3, 5));

      expect(result, DateTime(2024, 3, 5, 14, 30));
    });

    test('DateTime.timeOfDay drops the date', () {
      expect(
        DateTime(2024, 3, 5, 14, 30, 59).timeOfDay,
        const TimeOfDay(hour: 14, minute: 30),
      );
    });
  });

  group('TimeOfDayExtensions comparison', () {
    test('compareTo orders within the day', () {
      expect(_nineAm.compareTo(_fivePm), lessThan(0));
      expect(_fivePm.compareTo(_nineAm), greaterThan(0));
      expect(_noon.compareTo(_noon), 0);
    });

    test('sorts a list', () {
      final times = [_fivePm, _nineAm, _noon]..sort((a, b) => a.compareTo(b));
      expect(times, [_nineAm, _noon, _fivePm]);
    });

    test('isBefore, isAfter, isAtSameTimeAs', () {
      expect(_nineAm.isBefore(_noon), isTrue);
      expect(_noon.isBefore(_nineAm), isFalse);
      expect(_fivePm.isAfter(_noon), isTrue);
      expect(
        _noon.isAtSameTimeAs(const TimeOfDay(hour: 12, minute: 0)),
        isTrue,
      );
      expect(_noon.isAtSameTimeAs(_nineAm), isFalse);
    });

    test('isBetween is inclusive for a same-day range', () {
      expect(_noon.isBetween(_nineAm, _fivePm), isTrue);
      expect(_nineAm.isBetween(_nineAm, _fivePm), isTrue);
      expect(_fivePm.isBetween(_nineAm, _fivePm), isTrue);
      expect(
        const TimeOfDay(hour: 8, minute: 0).isBetween(_nineAm, _fivePm),
        isFalse,
      );
    });

    test('isBetween handles a range spanning midnight', () {
      const tenPm = TimeOfDay(hour: 22, minute: 0);
      const twoAm = TimeOfDay(hour: 2, minute: 0);

      expect(
        const TimeOfDay(hour: 23, minute: 30).isBetween(tenPm, twoAm),
        isTrue,
      );
      expect(
        const TimeOfDay(hour: 1, minute: 0).isBetween(tenPm, twoAm),
        isTrue,
      );
      expect(_noon.isBetween(tenPm, twoAm), isFalse);
    });
  });

  group('TimeOfDayExtensions spans', () {
    test('difference is signed and does not wrap', () {
      expect(
        const TimeOfDay(hour: 13, minute: 0).difference(_nineAm),
        const Duration(hours: 4),
      );
      expect(
        _nineAm.difference(const TimeOfDay(hour: 13, minute: 0)),
        const Duration(hours: -4),
      );
    });

    test('durationUntil is forward-only and wraps past midnight', () {
      expect(
        const TimeOfDay(
          hour: 23,
          minute: 0,
        ).durationUntil(const TimeOfDay(hour: 1, minute: 0)),
        const Duration(hours: 2),
      );
      expect(_nineAm.durationUntil(_fivePm), const Duration(hours: 8));
      expect(_noon.durationUntil(_noon), Duration.zero);
    });
  });

  group('TimeOfDayExtensions arithmetic', () {
    test('addMinutes wraps past midnight', () {
      expect(
        const TimeOfDay(hour: 23, minute: 0).addMinutes(90),
        const TimeOfDay(hour: 0, minute: 30),
      );
      expect(_nineAm.addMinutes(45), const TimeOfDay(hour: 9, minute: 45));
    });

    test('subtractMinutes wraps backwards past midnight', () {
      expect(
        const TimeOfDay(hour: 0, minute: 15).subtractMinutes(30),
        const TimeOfDay(hour: 23, minute: 45),
      );
    });

    test('addHours wraps past midnight', () {
      expect(
        const TimeOfDay(hour: 23, minute: 0).addHours(3),
        const TimeOfDay(hour: 2, minute: 0),
      );
    });

    test('add takes a Duration and drops sub-minute precision', () {
      expect(
        const TimeOfDay(
          hour: 10,
          minute: 0,
        ).add(const Duration(hours: 2, minutes: 30, seconds: 59)),
        const TimeOfDay(hour: 12, minute: 30),
      );
    });
  });

  group('TimeOfDayExtensions rounding and clamping', () {
    test('roundToNearest rounds both directions', () {
      expect(
        const TimeOfDay(hour: 9, minute: 22).roundToNearest(15),
        const TimeOfDay(hour: 9, minute: 15),
      );
      expect(
        const TimeOfDay(hour: 9, minute: 23).roundToNearest(15),
        const TimeOfDay(hour: 9, minute: 30),
      );
      expect(_nineAm.roundToNearest(15), _nineAm);
    });

    test('roundToNearest can wrap to the next day', () {
      expect(
        const TimeOfDay(hour: 23, minute: 55).roundToNearest(30),
        const TimeOfDay(hour: 0, minute: 0),
      );
    });

    test('roundToNearest rejects a non-positive interval', () {
      expect(() => _nineAm.roundToNearest(0), throwsArgumentError);
      expect(() => _nineAm.roundToNearest(-5), throwsArgumentError);
    });

    test('clampTo constrains to a window', () {
      expect(
        const TimeOfDay(hour: 8, minute: 0).clampTo(_nineAm, _fivePm),
        _nineAm,
      );
      expect(
        const TimeOfDay(hour: 18, minute: 0).clampTo(_nineAm, _fivePm),
        _fivePm,
      );
      expect(_noon.clampTo(_nineAm, _fivePm), _noon);
    });

    test('clampTo rejects an inverted window', () {
      expect(() => _noon.clampTo(_fivePm, _nineAm), throwsArgumentError);
    });
  });
}
