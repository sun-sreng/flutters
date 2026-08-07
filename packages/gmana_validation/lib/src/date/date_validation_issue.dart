import '../core/validation_issue.dart';

/// Default English messages for date validation issues.
String resolveDateValidationIssue(DateValidationIssue issue) {
  return issue.defaultMessage;
}

/// Base type for date validation failures.
sealed class DateValidationIssue extends ValidationIssue {
  /// Creates a date validation issue.
  const DateValidationIssue();

  /// Default English message.
  String get defaultMessage;
}

/// Date input is empty.
final class DateEmptyIssue extends DateValidationIssue {
  /// Creates an empty date issue.
  const DateEmptyIssue();

  @override
  String get code => 'date.empty';

  @override
  String get defaultMessage => 'Date is required';
}

/// Input could not be parsed as a valid ISO 8601 date.
final class DateInvalidFormatIssue extends DateValidationIssue {
  /// Creates an invalid format issue.
  const DateInvalidFormatIssue();

  @override
  String get code => 'date.invalidFormat';

  @override
  String get defaultMessage => 'Invalid date format';
}

/// Date is not in the past.
final class DateNotPastIssue extends DateValidationIssue {
  /// Creates a not-past issue.
  const DateNotPastIssue();

  @override
  String get code => 'date.notPast';

  @override
  String get defaultMessage => 'Date must be in the past';
}

/// Date is not in the future.
final class DateNotFutureIssue extends DateValidationIssue {
  /// Creates a not-future issue.
  const DateNotFutureIssue();

  @override
  String get code => 'date.notFuture';

  @override
  String get defaultMessage => 'Date must be in the future';
}

/// Date does not match today's UTC date.
final class DateNotTodayIssue extends DateValidationIssue {
  /// Creates a not-today issue.
  const DateNotTodayIssue();

  @override
  String get code => 'date.notToday';

  @override
  String get defaultMessage => 'Date must be today';
}

/// Date is not a weekday.
final class DateNotWeekdayIssue extends DateValidationIssue {
  /// Creates a not-weekday issue.
  const DateNotWeekdayIssue();

  @override
  String get code => 'date.notWeekday';

  @override
  String get defaultMessage => 'Date must be a weekday (Monday–Friday)';
}

/// Date is not a weekend.
final class DateNotWeekendIssue extends DateValidationIssue {
  /// Creates a not-weekend issue.
  const DateNotWeekendIssue();

  @override
  String get code => 'date.notWeekend';

  @override
  String get defaultMessage => 'Date must be a weekend (Saturday or Sunday)';
}

/// Date is not in a leap year.
final class DateNotLeapYearIssue extends DateValidationIssue {
  /// Creates a not-leap-year issue.
  const DateNotLeapYearIssue();

  @override
  String get code => 'date.notLeapYear';

  @override
  String get defaultMessage => 'Date must be in a leap year';
}

/// Input does not match 24-hour time format.
final class DateInvalidTimeIssue extends DateValidationIssue {
  /// Creates an invalid time issue.
  const DateInvalidTimeIssue();

  @override
  String get code => 'date.invalidTime';

  @override
  String get defaultMessage => 'Invalid time format (expected HH:mm or HH:mm:ss)';
}

/// Date is before configured minDate.
final class DateBeforeMinIssue extends DateValidationIssue {
  /// Configured minimum date.
  final DateTime minDate;

  /// Creates a before-min issue.
  const DateBeforeMinIssue(this.minDate);

  @override
  String get code => 'date.beforeMin';

  @override
  String get defaultMessage => 'Date must not be before ${minDate.toIso8601String()}';
}

/// Date is after configured maxDate.
final class DateAfterMaxIssue extends DateValidationIssue {
  /// Configured maximum date.
  final DateTime maxDate;

  /// Creates an after-max issue.
  const DateAfterMaxIssue(this.maxDate);

  @override
  String get code => 'date.afterMax';

  @override
  String get defaultMessage => 'Date must not be after ${maxDate.toIso8601String()}';
}
