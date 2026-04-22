import 'package:gmana/validator/string_field_validator.dart';

/// Validator for email fields, ensuring valid email format.
class EmailFieldValidator implements StringFieldValidator {
  /// Optional extra validation applied after the built-in email checks.
  final String? Function(String?)? additionalValidator;

  /// Creates an email validator.
  const EmailFieldValidator({this.additionalValidator});

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return additionalValidator?.call(value);
  }
}
