import '../../../functional.dart';

/// Maps a typed validation issue into a user-facing message.
typedef ValidationMessageResolver<TIssue extends ValidationIssue> =
    String Function(TIssue issue);

/// Canonical result shape for validators.
typedef ValidationResult<TIssue extends ValidationIssue, TValue> =
    Either<TIssue, TValue>;

/// Base contract for typed validation failures.
abstract class ValidationIssue {
  /// Creates a validation issue.
  const ValidationIssue();

  /// Machine-readable issue code.
  String get code;
}
