import '../../validation/core/validation_issue.dart';

/// Thrown by a value object's constructor when the input is invalid.
///
/// The non-throwing `tryParse` factories return the same [issue] as a `Left`.
final class ValueObjectException implements Exception {
  /// Creates an exception for [issue].
  const ValueObjectException(this.issue);

  /// Why the input was rejected.
  final ValidationIssue issue;

  @override
  String toString() => 'ValueObjectException(${issue.code})';
}
