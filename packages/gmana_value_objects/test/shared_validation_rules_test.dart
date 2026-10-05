import 'package:gmana_validation/gmana_validation.dart' as v;
import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('email rules shared with gmana_validation', () {
    test('strict rejects the same disposable domains in both packages', () {
      final strict = EmailValidationConfig.strict();

      expect(strict.disposableDomains, v.kDefaultDisposableDomains);

      for (final domain in ['yopmail.com', 'throwaway.email']) {
        final address = 'user@$domain';

        expect(
          Email.tryParse(address, config: strict).leftOrNull(),
          isA<EmailDisposableDomain>(),
          reason: address,
        );
        expect(
          v.EmailValidator(
            v.EmailValidationConfig.strict(),
          ).validate(address).leftOrNull(),
          isA<v.EmailDisposableDomainIssue>(),
          reason: address,
        );
      }
    });

    test('matchSubdomains controls subdomain matching', () {
      const address = 'user@mail.blocked.com';

      expect(
        Email.tryParse(
          address,
          config: const EmailValidationConfig(blockedDomains: {'blocked.com'}),
        ).leftOrNull(),
        isA<EmailBlockedDomain>(),
      );
      expect(
        Email.tryParse(
          address,
          config: const EmailValidationConfig(
            blockedDomains: {'blocked.com'},
            matchSubdomains: false,
          ),
        ).isRight(),
        isTrue,
      );
    });

    test('rejectDisposable defaults to false and survives copyWith', () {
      const allowing = EmailValidationConfig();

      expect(allowing.rejectDisposable, isFalse);
      expect(
        allowing.copyWith(rejectDisposable: true),
        EmailValidationConfig.strict(),
      );
      expect(
        EmailValidationConfig.strict()
            .copyWith(maxLength: 100)
            .rejectDisposable,
        isTrue,
      );
    });
  });

  group('configs shared with gmana_validation', () {
    test('are the same classes, not copies', () {
      const v.PhoneValidationConfig phone = PhoneValidationConfig();
      const v.UrlValidationConfig url = UrlValidationConfig();
      const v.IdentifierValidationConfig identifier =
          IdentifierValidationConfig();
      const v.NetworkValidationConfig network = NetworkValidationConfig();
      const v.NumberValidationConfig number = NumberValidationConfig();

      expect(phone, const v.PhoneValidationConfig());
      expect(url, const v.UrlValidationConfig());
      expect(identifier, const v.IdentifierValidationConfig());
      expect(network, const v.NetworkValidationConfig());
      expect(number, const v.NumberValidationConfig());
    });
  });

  group('text blacklist matching', () {
    test('matches inside longer words by default', () {
      const config = TextValidationConfig(blacklistedWords: {'bad'});

      expect(
        const TextValidator(config).validate('badminton').leftOrNull(),
        isA<TextContainsBlacklisted>(),
      );
    });

    test('wholeWordBlacklist limits matches to whole words', () {
      const config = TextValidationConfig(
        blacklistedWords: {'bad'},
        wholeWordBlacklist: true,
      );

      expect(
        const TextValidator(config).validate('badminton').isRight(),
        isTrue,
      );
      expect(
        const TextValidator(config).validate('a bad idea').leftOrNull(),
        isA<TextContainsBlacklisted>(),
      );
    });
  });
}
