import 'dart:async';

import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  test('Debouncer runs only the latest action', () async {
    final debounce = Debouncer(milliseconds: 20);
    var count = 0;

    debounce.run(() => count += 1);
    debounce.run(() => count += 10);

    expect(debounce.isPending, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(count, 10);
    expect(debounce.isPending, isFalse);
    debounce.dispose();
  });

  test('Debouncer flush executes pending action immediately', () {
    final debounce = Debouncer(duration: const Duration(milliseconds: 100));
    var count = 0;

    debounce.run(() => count = 42);
    expect(debounce.isPending, isTrue);

    debounce.flush();
    expect(count, 42);
    expect(debounce.isPending, isFalse);
  });

  test('Debouncer cancel stops pending action', () async {
    final debounce = Debouncer.duration(const Duration(milliseconds: 30));
    var count = 0;

    debounce.run(() => count = 100);
    debounce.cancel();

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(count, 0);
  });

  test('Debouncer validates delay', () {
    expect(() => Debouncer(milliseconds: 0), throwsArgumentError);
    expect(() => Debouncer(milliseconds: -1), throwsArgumentError);
  });
}
