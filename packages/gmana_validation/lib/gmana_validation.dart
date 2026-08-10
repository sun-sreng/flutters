/// Pure Dart typed validators and validation-focused extensions.
///
/// Provides configurable validators for common text, numeric, contact,
/// identifier, network, and date/time inputs. Every validator returns an
/// Either-based result with sealed issue types for exhaustive error handling.
library;

// Core types
export 'src/core/validation_issue.dart';

// Date
export 'src/date/date_validation_config.dart';
export 'src/date/date_validation_issue.dart';
export 'src/date/date_validator.dart';

// Email
export 'src/email/email_disposable.dart' show kDefaultDisposableDomains;
export 'src/email/email_validation_config.dart';
export 'src/email/email_validation_issue.dart';
export 'src/email/email_validator.dart';

// Extensions
export 'src/extensions/string_validation_extensions.dart';
export 'src/extensions/validation_result_extensions.dart';

// Identifier
export 'src/identifier/identifier_validation_config.dart';
export 'src/identifier/identifier_validation_issue.dart';
export 'src/identifier/identifier_validator.dart';

// Network
export 'src/network/network_validation_config.dart';
export 'src/network/network_validation_issue.dart';
export 'src/network/network_validator.dart';

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
