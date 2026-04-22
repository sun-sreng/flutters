import 'package:gmana/math/wave_vertical_offset.dart';
import 'package:test/test.dart';

void main() {
  test('waveVerticalOffset computes the expected wave position', () {
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
  });
}
