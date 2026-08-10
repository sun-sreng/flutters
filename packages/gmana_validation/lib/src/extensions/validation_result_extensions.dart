import '../core/validation_issue.dart';

/// Validation-domain vocabulary for a [ValidationResult].
extension GmanaValidationResultX<TIssue extends ValidationIssue, TValue>
    on ValidationResult<TIssue, TValue> {
  /// Whether validation succeeded.
  bool get isValid => isRight();

  /// Whether validation failed.
  bool get isInvalid => isLeft();

  /// The typed validation issue, or `null` when validation succeeded.
  TIssue? get issueOrNull => leftOrNull();

  /// The validated value, or `null` when validation failed.
  ///
  /// A validator may legitimately succeed with a nullable value. Use [isValid]
  /// when a successful `null` must be distinguished from a failure.
  TValue? get valueOrNull => rightOrNull();

  /// Resolves the validation issue to a message, or returns `null` on success.
  ///
  /// [resolve] is invoked only when validation failed.
  String? messageOrNull(ValidationMessageResolver<TIssue> resolve) =>
      fold<String?>(resolve, (_) => null);
}
