import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

void main() {
  test('AlignmentX opposite, withX, withY', () {
    const align = Alignment.topLeft; // Alignment(-1.0, -1.0)

    expect(align.opposite, equals(Alignment.bottomRight)); // Alignment(1.0, 1.0)
    expect(align.withX(0.5), equals(const Alignment(0.5, -1.0)));
    expect(align.withY(0.0), equals(const Alignment(-1.0, 0.0)));
  });
}
