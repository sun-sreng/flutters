import 'package:gmana/gmana.dart';
import 'package:test/test.dart';

void main() {
  group('PhoneValue and PhoneValidator', () {
    test('PhoneValue constructs trusted values and throws on error', () {
      final phone = PhoneValue('+1 (415) 555-2671');
      expect(phone.value, '+14155552671');
      expect(phone.toString(), 'PhoneValue(+14155552671)');

      expect(() => PhoneValue(''), throwsA(isA<ValueObjectException>()));
    });

    test('PhoneValue.tryParse returns Either', () {
      final res1 = PhoneValue.tryParse('+14155552671');
      expect(res1.isRight(), isTrue);

      final res2 = PhoneValue.tryParse('');
      expect(res2.isLeft(), isTrue);
      expect(res2.fold((e) => e, (_) => null), isA<PhoneEmptyIssue>());
    });
  });
}
