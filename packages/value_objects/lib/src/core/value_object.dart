import 'package:fpdart/fpdart.dart';
import 'validation_error.dart';

/// Base class for value objects.
/// T is the primitive type being wrapped.
abstract class ValueObject<T> {
  const ValueObject();

  Either<ValidationError, T> get value;

  bool get isValid => value.isRight();
  bool get isInvalid => value.isLeft();

  T? get valueOrNull => value.fold((_) => null, (r) => r);
  ValidationError? get errorOrNull => value.fold((l) => l, (_) => null);

  /// Override this for sensitive data like passwords
  bool get isSensitive => false;
}
