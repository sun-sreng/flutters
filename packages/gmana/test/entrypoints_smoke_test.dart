import 'package:gmana/extensions.dart';
import 'package:gmana/functional.dart';
import 'package:gmana/utilities.dart';
import 'package:gmana/validation.dart';
import 'package:test/test.dart';

void main() {
  test('focused entrypoints expose the curated API surface', () {
    final either = const Right<String, int>(21).map((value) => value * 2);
    final requiredRule = Validators.required(message: 'Required');
    final debouncer = Debouncer(milliseconds: 1);
    final throttler = Throttler(milliseconds: 1);

    expect(either.getRight(), 42);
    expect('hello world'.toTitleCase, 'Hello World');
    expect('user@example.com'.isValidEmail, isTrue);
    expect(requiredRule(''), 'Required');
    expect(GSpacing.md, 12);
    expect(
      waveVerticalOffset(
        value: 0,
        verticalShift: 10,
        amplitude: 5,
        phaseShift: 0,
        waveLength: 20,
      ),
      closeTo(10, 0.000001),
    );

    debouncer.dispose();
    throttler.dispose();
  });
}
