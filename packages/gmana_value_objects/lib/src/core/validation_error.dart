import 'package:meta/meta.dart';

/// Base class for all validation errors.
/// Extend this in your domain-specific error types.
@immutable
abstract class ValidationError {
  /// Creates a base [ValidationError].
  const ValidationError();

  /// Stable machine-readable code for this error.
  ///
  /// Built-in errors derive this from the class name, for example
  /// `EmailInvalidFormat` becomes `email_invalid_format`.
  String get code => _toSnakeCase(runtimeType.toString());

  static String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'(?<=[a-z0-9])([A-Z])'),
          (match) => '_${match.group(1)}',
        )
        .toLowerCase();
  }
}
