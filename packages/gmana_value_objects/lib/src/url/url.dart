import 'package:gmana_functional/gmana_functional.dart';
import 'package:meta/meta.dart';

import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import 'url_errors.dart';
import 'url_validation_config.dart';
import 'url_validator.dart';

/// Immutable domain value object representing a validated [Uri].
@immutable
final class UrlValue extends ValueObject<Uri> {
  @override
  final Uri value;

  const UrlValue._(this.value);

  /// Constructs a [UrlValue] from a trusted input string.
  /// Throws [ValueObjectException] if input is invalid.
  factory UrlValue(
    String input, [
    UrlValidationConfig config = const UrlValidationConfig(),
  ]) {
    return tryParse(input, config).fold(
      (error) => throw ValueObjectException(error),
      (url) => url,
    );
  }

  /// Attempts to parse [input] into a [UrlValue].
  /// Returns `Either<UrlError, UrlValue>`.
  static Either<UrlError, UrlValue> tryParse(
    String input, [
    UrlValidationConfig config = const UrlValidationConfig(),
  ]) {
    return UrlValidator(config).validate(input).map(UrlValue._);
  }
}
