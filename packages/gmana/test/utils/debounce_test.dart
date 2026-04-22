import 'dart:async';

import 'package:gmana/utils/debouncer.dart';
import 'package:test/test.dart';

void main() {
  test('Debouncer runs only the latest action', () async {
    final debounce = Debouncer(milliseconds: 20);
    var count = 0;

    debounce.run(() => count += 1);
    debounce.run(() => count += 10);

    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(count, 10);
    debounce.dispose();
  });
}
