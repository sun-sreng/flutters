import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('RegExpX', () {
    final digitReg = RegExp(r'^\d+$');

    test('matchesAll and matchesAny', () {
      expect(digitReg.matchesAll(['123', '456', '789']), isTrue);
      expect(digitReg.matchesAll(['123', 'abc', '789']), isFalse);

      expect(digitReg.matchesAny(['abc', '456', 'xyz']), isTrue);
      expect(digitReg.matchesAny(['abc', 'def']), isFalse);
    });

    test('firstGroup', () {
      final reg = RegExp(r'user_(\d+)');
      expect(reg.firstGroup('user_123', 1), equals('123'));
      expect(reg.firstGroup('no_match', 1), isNull);
    });
  });
}
