import 'package:meta/meta.dart';

/// Base class for all validation errors.
/// Extend this in your domain-specific error types.
@immutable
abstract class ValidationError {
  const ValidationError();
}
