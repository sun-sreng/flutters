/// Extension methods for [RegExp].
extension RegExpX on RegExp {
  /// Returns `true` if all items in [inputs] match this regular expression.
  bool matchesAll(Iterable<String> inputs) {
    return inputs.every(hasMatch);
  }

  /// Returns `true` if any item in [inputs] matches this regular expression.
  bool matchesAny(Iterable<String> inputs) {
    return inputs.any(hasMatch);
  }

  /// Returns matched group string at [group] index for the first match in [input], or `null`.
  String? firstGroup(String input, [int group = 0]) {
    final match = firstMatch(input);
    if (match == null) return null;
    return match.group(group);
  }
}
