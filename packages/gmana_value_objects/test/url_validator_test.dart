import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('UrlValue and UrlValidator', () {
    test('UrlValue constructs trusted values and throws on error', () {
      final url = UrlValue('https://example.com/api');
      expect(url.value.host, 'example.com');
      expect(url.toString(), 'UrlValue(https://example.com/api)');

      expect(() => UrlValue('invalid-url'), throwsA(isA<ValueObjectException>()));
    });

    test('UrlValue.tryParse returns Either', () {
      final res1 = UrlValue.tryParse('https://google.com');
      expect(res1.isRight(), isTrue);

      final res2 = UrlValue.tryParse('   ');
      expect(res2.isLeft(), isTrue);
      expect(res2.fold((e) => e, (_) => null), isA<UrlEmpty>());
    });

    test('UrlValidator respects scheme configuration', () {
      const validator = UrlValidator(
        UrlValidationConfig(allowedSchemes: {'https'}),
      );

      final res = validator.validate('http://example.com');
      expect(res.isLeft(), isTrue);
      expect(res.fold((e) => e, (_) => null), isA<UrlDisallowedScheme>());
    });
  });
}
