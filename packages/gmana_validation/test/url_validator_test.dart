import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('UrlValidator', () {
    const validator = UrlValidator();

    test('validates valid http/https URLs', () {
      final res1 = validator.validate('https://example.com/path');
      expect(res1.isRight(), isTrue);
      expect(res1.getOrElse((_) => Uri()).host, 'example.com');

      final res2 = validator.validate('http://localhost:8080');
      expect(res2.isRight(), isTrue);
    });

    test('rejects empty inputs', () {
      final res = validator.validate('   ');
      expect(res.isLeft(), isTrue);
      expect(res.fold((issue) => issue, (_) => null), isA<UrlEmptyIssue>());
    });

    test('rejects invalid format or missing scheme', () {
      final res = validator.validate('example.com');
      expect(res.isLeft(), isTrue);
      expect(
        res.fold((issue) => issue, (_) => null),
        isA<UrlInvalidFormatIssue>(),
      );
    });

    test('rejects disallowed schemes', () {
      const customValidator = UrlValidator(
        UrlValidationConfig(allowedSchemes: {'https'}),
      );

      final res = customValidator.validate('http://example.com');
      expect(res.isLeft(), isTrue);
      expect(
        res.fold((issue) => issue, (_) => null),
        isA<UrlDisallowedSchemeIssue>(),
      );
    });
  });
}
