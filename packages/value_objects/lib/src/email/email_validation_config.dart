import 'package:meta/meta.dart';

@immutable
final class EmailValidationConfig {
  final int maxLength;
  final int maxLocalPartLength;
  final int maxDomainLength;
  final Set<String> disposableDomains;
  final Set<String> blockedDomains;
  final bool allowDisposable;
  
  const EmailValidationConfig({
    this.maxLength = 254,
    this.maxLocalPartLength = 64,
    this.maxDomainLength = 253,
    this.disposableDomains = _defaultDisposableDomains,
    this.blockedDomains = const {},
    this.allowDisposable = true,
  });
  
  factory EmailValidationConfig.strict() {
    return const EmailValidationConfig(
      allowDisposable: false,
    );
  }
  
  static const Set<String> _defaultDisposableDomains = {
    'tempmail.com',
    'guerrillamail.com',
    'mailinator.com',
    '10minutemail.com',
    'throwaway.email',
    'temp-mail.org',
  };
}
