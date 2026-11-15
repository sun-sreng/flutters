import '../../../functional.dart';
import 'package:meta/meta.dart';

import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import '../../validation/url/url_validation_config.dart';
import '../../validation/url/url_validation_issue.dart';
import '../../validation/url/url_validator.dart';

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
    return tryParse(
      input,
      config,
    ).fold((error) => throw ValueObjectException(error), (url) => url);
  }

  /// Attempts to parse [input] into a [UrlValue].
  /// Returns `Either<UrlValidationIssue, UrlValue>`.
  static Either<UrlValidationIssue, UrlValue> tryParse(
    String input, [
    UrlValidationConfig config = const UrlValidationConfig(),
  ]) {
    return UrlValidator(config).validate(input).map(UrlValue._);
  }
}
