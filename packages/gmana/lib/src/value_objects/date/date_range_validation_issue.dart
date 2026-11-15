import '../../validation/core/validation_issue.dart';

/// Default English messages for date-range validation issues.
String resolveDateRangeValidationIssue(DateRangeValidationIssue issue) {
  return switch (issue) {
    DateRangeInvalidOrderIssue(:final start, :final end) =>
      'Start date ($start) cannot be after end date ($end)',
  };
}

/// Base type for date-range validation failures.
sealed class DateRangeValidationIssue extends ValidationIssue {
  /// Creates a date-range validation issue.
  const DateRangeValidationIssue();
}

/// The start of the range is after its end.
final class DateRangeInvalidOrderIssue extends DateRangeValidationIssue {
  /// Creates an invalid-order issue.
  const DateRangeInvalidOrderIssue({required this.start, required this.end});

  /// The range start, in UTC.
  final DateTime start;

  /// The range end, in UTC.
  final DateTime end;

  @override
  String get code => 'dateRange.invalidOrder';
}
