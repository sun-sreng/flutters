import 'validation_error.dart';

/// Thrown when a value object's throwing constructor receives invalid input.
///
/// Throwing constructors (for example `Email(input)`) are intended for trusted
/// literals where invalid input is a programming error. For untrusted input,
/// prefer the `tryParse` smart constructors, which surface the failure as a
/// [ValidationError] inside an `Either` instead of throwing.
final class ValueObjectException implements Exception {
  /// The validation error describing why construction failed.
  final ValidationError error;

  /// Creates a [ValueObjectException] wrapping [error].
  const ValueObjectException(this.error);

  @override
  String toString() => 'ValueObjectException(${error.code})';
}
