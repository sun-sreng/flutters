import '../../value_objects/date/date_range_validation_issue.dart';
import '../../value_objects/money/money_validation_issue.dart';
import '../date/date_validation_issue.dart';
import '../email/email_validation_issue.dart';
import '../identifier/identifier_validation_issue.dart';
import '../network/network_validation_issue.dart';
import '../number/number_validator.dart';
import '../password/confirm_password_validator.dart';
import '../password/password_validator.dart';
import '../phone/phone_validation_issue.dart';
import '../text/text_validation_issue.dart';
import '../url/url_validation_issue.dart';
import 'validation_issue.dart';

/// Default English message for any issue produced by this package.
///
/// Dispatches to the resolver of the issue's family, such as
/// [resolveEmailValidationIssue]. Issues from other sources fall back to their
/// [ValidationIssue.code].
String resolveValidationIssue(ValidationIssue issue) {
  return switch (issue) {
    ConfirmPasswordValidationIssue() => resolveConfirmPasswordValidationIssue(
      issue,
    ),
    DateRangeValidationIssue() => resolveDateRangeValidationIssue(issue),
    DateValidationIssue() => resolveDateValidationIssue(issue),
    EmailValidationIssue() => resolveEmailValidationIssue(issue),
    IdentifierValidationIssue() => resolveIdentifierValidationIssue(issue),
    MoneyValidationIssue() => resolveMoneyValidationIssue(issue),
    NetworkValidationIssue() => resolveNetworkValidationIssue(issue),
    NumberValidationIssue() => resolveNumberValidationIssue(issue),
    PasswordValidationIssue() => resolvePasswordValidationIssue(issue),
    PhoneValidationIssue() => resolvePhoneValidationIssue(issue),
    TextValidationIssue() => resolveTextValidationIssue(issue),
    UrlValidationIssue() => resolveUrlValidationIssue(issue),
    _ => issue.code,
  };
}
