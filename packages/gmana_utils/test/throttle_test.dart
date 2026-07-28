import 'dart:async';

import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  test('Throttler suppresses calls during the cooldown window', () async {
    final throttle = Throttler(milliseconds: 20);
    var count = 0;

    throttle.run(() => count += 1);
    expect(throttle.isActive, isTrue);
    throttle.run(() => count += 10);

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(throttle.isActive, isFalse);
    throttle.run(() => count += 100);

    expect(count, 101);
    throttle.dispose();
  });

  test('Throttler cancel resets active cooldown state', () {
    final throttle = Throttler.duration(const Duration(milliseconds: 100));
    var count = 0;

    throttle.run(() => count += 1);
    expect(throttle.isActive, isTrue);

    throttle.cancel();
    expect(throttle.isActive, isFalse);

    throttle.run(() => count += 1);
    expect(count, 2);
  });

  test('Throttler validates delay', () {
    expect(() => Throttler(milliseconds: 0), throwsArgumentError);
    expect(() => Throttler(milliseconds: -1), throwsArgumentError);
  });
}
