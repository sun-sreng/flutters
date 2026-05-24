import 'package:flutter/material.dart' show TextFormField, FormField;
import 'package:gmana_validation/gmana_validation.dart';

/// Converts a canonical validator into a Flutter-style form validator.
///
/// The returned function matches Flutter's `FormField.validator` signature
/// (`String? Function(String?)`), making it easy to wire typed validators
/// into any [TextFormField] or [FormField].
///
/// Example:
/// ```dart
/// TextFormField(
///   validator: asFormValidator(
///     validate: EmailValidator().validate,
///     resolve: resolveEmailValidationIssue,
///   ),
/// )
/// ```
String? Function(String?)
asFormValidator<TIssue extends ValidationIssue, TValue>({
  required ValidationResult<TIssue, TValue> Function(String input) validate,
  required ValidationMessageResolver<TIssue> resolve,
  String? Function(String?)? validatorOverride,
}) {
  return (value) {
    final message = validate(value ?? '').fold(resolve, (_) => null);
    if (message != null) {
      return message;
    }
    return validatorOverride?.call(value);
  };
}
