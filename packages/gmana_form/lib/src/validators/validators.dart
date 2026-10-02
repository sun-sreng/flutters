import '../models/field_config.dart' show GFormValidator;

/// Runs [validators] in order and returns the first message produced.
///
/// `null` entries are skipped, so optional validators can be inlined:
///
/// ```dart
/// validator: combineValidators([
///   GValidators.required(),
///   GValidators.minLength(8),
///   isAdmin ? GValidators.pattern(adminPattern, message: '…') : null,
/// ]);
/// ```
GFormValidator combineValidators(List<GFormValidator?> validators) {
  return (value) {
    for (final validator in validators) {
      final message = validator?.call(value);
      if (message != null) return message;
    }
    return null;
  };
}

/// Reusable `FormField.validator` building blocks.
///
/// Only [required] objects to an empty value. Every other validator lets an
/// empty input pass, so they compose onto optional fields without forcing
/// them to be filled in — put [required] first when you do want it enforced.
abstract final class GValidators {
  /// Fails when the value is null, empty, or only whitespace.
  static GFormValidator required({String message = 'This field is required'}) =>
      (value) => (value == null || value.trim().isEmpty) ? message : null;

  /// Fails when a non-empty value is shorter than [length] characters.
  static GFormValidator minLength(int length, {String? message}) {
    _checkNonNegative(length, 'length');

    return (value) {
      if (value == null || value.isEmpty) return null;
      return value.length < length
          ? (message ?? 'Must be at least $length characters')
          : null;
    };
  }

  /// Fails when the value is longer than [length] characters.
  static GFormValidator maxLength(int length, {String? message}) {
    _checkNonNegative(length, 'length');

    return (value) {
      if (value == null || value.isEmpty) return null;
      return value.length > length
          ? (message ?? 'Must be at most $length characters')
          : null;
    };
  }

  /// Fails when a non-empty value does not match [regExp].
  static GFormValidator pattern(RegExp regExp, {required String message}) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return regExp.hasMatch(value) ? null : message;
    };
  }

  /// Fails when the value differs from whatever [other] returns.
  ///
  /// [other] is a callback rather than a value so the comparison reads the
  /// *current* contents of the other field, not a stale snapshot.
  ///
  /// ```dart
  /// GValidators.matches(() => passwordController.text);
  /// ```
  static GFormValidator matches(
    String Function() other, {
    String message = 'Values do not match',
    bool trim = false,
  }) {
    return (value) {
      final left = trim ? (value ?? '').trim() : (value ?? '');
      final right = trim ? other().trim() : other();
      return left == right ? null : message;
    };
  }

  /// Fails when a non-empty value is not one of [allowed].
  static GFormValidator oneOf(Iterable<String> allowed, {String? message}) {
    final options = allowed.toList(growable: false);

    return (value) {
      if (value == null || value.isEmpty) return null;
      return options.contains(value)
          ? null
          : (message ?? 'Must be one of: ${options.join(', ')}');
    };
  }

  /// Fails when a non-empty value does not parse as a number.
  static GFormValidator numeric({String message = 'Enter a valid number'}) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return num.tryParse(value) == null ? message : null;
    };
  }

  /// Fails when a non-empty numeric value falls outside `[min, max]`.
  ///
  /// A value that does not parse as a number is reported with [message] too,
  /// so this can stand alone without [numeric].
  static GFormValidator range({num? min, num? max, String? message}) {
    if (min != null && max != null && min > max) {
      throw ArgumentError.value(
        max,
        'max',
        'must be greater than or equal to min',
      );
    }

    return (value) {
      if (value == null || value.isEmpty) return null;

      final parsed = num.tryParse(value);
      if (parsed == null) return message ?? 'Enter a valid number';
      if (min != null && parsed < min) {
        return message ?? 'Must be at least $min';
      }
      if (max != null && parsed > max) {
        return message ?? 'Must be at most $max';
      }
      return null;
    };
  }

  /// Fails when [predicate] returns `false` for a non-empty value.
  ///
  /// The escape hatch for one-off rules that do not deserve their own helper.
  static GFormValidator satisfies(
    bool Function(String value) predicate, {
    required String message,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return predicate(value) ? null : message;
    };
  }
}

void _checkNonNegative(int value, String name) {
  if (value < 0) {
    throw ArgumentError.value(value, name, 'must not be negative');
  }
}
