/// Pure Dart typed validators and validation-focused extensions.
///
/// Provides configurable validators for common text, numeric, contact,
/// identifier, network, and date/time inputs. Every validator returns an
/// Either-based result with sealed issue types for exhaustive error handling.
library;

export 'predicates.dart';

// Core types
export 'src/validation/core/resolve_validation_issue.dart';
export 'src/validation/core/validation_issue.dart';

// Date
export 'src/validation/date/date_validation_config.dart';
export 'src/validation/date/date_validation_issue.dart';
export 'src/validation/date/date_validator.dart';

// Email
export 'src/validation/email/email_disposable.dart'
    show kDefaultDisposableDomains;
export 'src/validation/email/email_validation_config.dart';
export 'src/validation/email/email_validation_issue.dart';
export 'src/validation/email/email_validator.dart';

// Extensions
export 'src/validation/extensions/string_validation_extensions.dart';
export 'src/validation/extensions/string_validity_extensions.dart';
export 'src/validation/extensions/validation_result_extensions.dart';

// Identifier
export 'src/validation/identifier/identifier_validation_config.dart';
export 'src/validation/identifier/identifier_validation_issue.dart';
export 'src/validation/identifier/identifier_validator.dart';

// Network
export 'src/validation/network/network_validation_config.dart';
export 'src/validation/network/network_validation_issue.dart';
export 'src/validation/network/network_validator.dart';

// Number
export 'src/validation/number/number_validator.dart';

// Password
export 'src/validation/password/confirm_password_validator.dart';
export 'src/validation/password/password_strength.dart';
export 'src/validation/password/password_validator.dart';

// Phone
export 'src/validation/phone/phone_validation_config.dart';
export 'src/validation/phone/phone_validation_issue.dart';
export 'src/validation/phone/phone_validator.dart';

// Text
export 'src/validation/text/text_validation_config.dart';
export 'src/validation/text/text_validation_issue.dart';
export 'src/validation/text/text_validator.dart';

// URL
export 'src/validation/url/url_validation_config.dart';
export 'src/validation/url/url_validation_issue.dart';
export 'src/validation/url/url_validator.dart';
