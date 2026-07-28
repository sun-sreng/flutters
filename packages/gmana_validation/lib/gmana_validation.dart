/// Pure Dart typed validators with Either-based results.
///
/// Provides configurable validators for email, password, text, number,
/// URL, and phone inputs, each returning sealed issue types for exhaustive
/// error handling.
library;

// Core types
export 'src/core/validation_issue.dart';

// Email
export 'src/email/email_disposable.dart' show kDefaultDisposableDomains;
export 'src/email/email_validation_config.dart';
export 'src/email/email_validation_issue.dart';
export 'src/email/email_validator.dart';

// Number
export 'src/number/number_validator.dart';

// Password
export 'src/password/password_strength.dart';
export 'src/password/password_validator.dart';

// Phone
export 'src/phone/phone_validation_config.dart';
export 'src/phone/phone_validation_issue.dart';
export 'src/phone/phone_validator.dart';

// Text
export 'src/text/text_validation_config.dart';
export 'src/text/text_validation_issue.dart';
export 'src/text/text_validator.dart';

// URL
export 'src/url/url_validation_config.dart';
export 'src/url/url_validation_issue.dart';
export 'src/url/url_validator.dart';
