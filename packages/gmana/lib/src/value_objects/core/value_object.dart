import 'package:meta/meta.dart';

/// Base class for single-value domain value objects.
///
/// A [ValueObject] is **always valid**: if you are holding an instance, its
/// [value] has already passed validation. Construct instances through each
/// type's smart constructors:
///
/// - `T.tryParse(input)` returns `Either<Error, T>` for untrusted input.
/// - `T(input)` throws `ValueObjectException` for trusted literals.
///
/// This makes illegal states unrepresentable — a function that accepts an
/// `Email` can never receive an invalid one.
///
/// Equality is structural: two value objects of the same concrete type that
/// wrap equal [value]s are equal, so they behave correctly as map keys and set
/// members.
@immutable
abstract class ValueObject<T> {
  /// Creates a [ValueObject].
  const ValueObject();

  /// The validated underlying value.
  T get value;

  /// Whether this value is sensitive (for example, a password).
  ///
  /// When `true`, [value] is redacted from [toString] so it does not leak into
  /// logs or error output.
  bool get isSensitive => false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueObject<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() =>
      isSensitive ? '$runtimeType(***)' : '$runtimeType($value)';
}
