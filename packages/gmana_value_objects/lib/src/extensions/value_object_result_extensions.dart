import 'package:gmana_functional/gmana_functional.dart';

import '../core/validation_error.dart';
import '../presentation/validation_error_messages.dart';

/// Value-object validation vocabulary for an [Either] result.
///
/// These aliases complement the general-purpose [Either] API with names that
/// read naturally at validation boundaries. They apply whenever the left side
/// is a [ValidationError], including every value object's `tryParse` result and
/// every validator in this package.
extension GmanaValueObjectResultX<E extends ValidationError, T>
    on Either<E, T> {
  /// Whether validation succeeded.
  bool get isValid => isRight();

  /// Whether validation failed.
  bool get isInvalid => isLeft();

  /// The validation error, or `null` when validation succeeded.
  E? get errorOrNull => leftOrNull();

  /// The validated value, or `null` when validation failed.
  ///
  /// If [T] is nullable, a successful `null` is indistinguishable from a
  /// failure through this getter alone. Use [isValid] when that distinction
  /// matters.
  T? get valueOrNull => rightOrNull();

  /// Resolves the validation error to a message, or returns `null` on success.
  ///
  /// [messages] is consulted only for a failure. By default, the package's
  /// English messages are used. Exceptions thrown by a custom resolver
  /// propagate to the caller.
  String? messageOrNull([
    ValidationErrorMessages messages = const DefaultValidationErrorMessages(),
  ]) => fold<String?>((error) => messages.getMessage(error), (_) => null);
}
