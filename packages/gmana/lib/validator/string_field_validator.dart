/// Interface for validators that operate on string input values.
abstract class StringFieldValidator {
  /// Returns an error message when [value] is invalid, otherwise `null`.
  String? validate(String? value);
}
