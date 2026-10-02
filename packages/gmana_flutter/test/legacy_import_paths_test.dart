// The pre-`lib/src` library paths must keep resolving until they are removed.
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/design_system/spacing.dart';
import 'package:gmana_flutter/widget/gap.dart';

void main() {
  test('deprecated library paths still export their declarations', () {
    expect(const GGap(GSpacing.sm).size, GSpacing.sm);
  });
}
