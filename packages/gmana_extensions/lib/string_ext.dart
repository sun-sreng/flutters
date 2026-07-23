import 'dart:convert';

final RegExp _alphaRegExp = RegExp(r'^[a-zA-Z]+$');
final RegExp _alphanumericRegExp = RegExp(r'^[a-zA-Z0-9]+$');
final RegExp _camelBoundaryRegExp = RegExp(r'([a-z])([A-Z])');
final RegExp _emailRegExp = RegExp(
  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
);
final RegExp _slugHyphenRegExp = RegExp(r'-+');
final RegExp _slugUnsafeRegExp = RegExp(r'[^a-z0-9\-]');
final RegExp _whitespaceRegExp = RegExp(r'\s+');
final RegExp _wordSeparatorRegExp = RegExp(r'[\s_\-]+');

/// Extension on nullable [String] providing safe fallback and mapping methods.
extension StringNullableX on String? {
  /// Returns true if the string is null or entirely whitespace.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Returns true if the string is null or strictly empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns the string, or an empty string `""` if null.
  String get orEmpty => this ?? '';

  /// Coerces blank strings to `null`. Symmetric with [StringX.blankToNull].
  String? get orNull => (this == null || this!.trim().isEmpty) ? null : this;

  /// Applies [transform] only if non-null and non-blank.
  String? mapNotBlank(String Function(String) transform) {
    final s = orNull;
    return s != null ? transform(s) : null;
  }
}

/// Main extension on String providing comprehensive conversion and formatting tools.
extension StringX on String {
  /// Returns `null` if blank, otherwise `this`. Useful for form validation chains.
  /// ```dart
  /// nameController.text.blankToNull ?? 'Anonymous'
  /// ```
  String? get blankToNull => isBlank ? null : this;

  /// Returns true if the string only contains letters.
  bool get isAlpha => _alphaRegExp.hasMatch(this);

  /// Returns true if the string only contains letters and numbers.
  bool get isAlphanumeric => _alphanumericRegExp.hasMatch(this);

  /// Returns true if the string is purely whitespace or empty.
  bool get isBlank => trim().isEmpty;

  /// Returns true if the string is a valid email format.
  bool get isEmail => _emailRegExp.hasMatch(trim());

  /// Returns true if the string contains non-whitespace characters.
  bool get isNotBlank => trim().isNotEmpty;

  /// Returns true if the string represents a valid number.
  bool get isNumeric => double.tryParse(this) != null;

  /// Returns true if the string is a valid URL.
  bool get isUrl {
    final uri = Uri.tryParse(trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  /// Decodes JSON, returns `null` on failure instead of throwing.
  dynamic get jsonDecodeOrNull {
    try {
      return jsonDecode(this);
    } catch (_) {
      return null;
    }
  }

  /// Estimates the reading time in minutes (225 words per minute).
  int get readingTimeMinutes {
    final trimmed = trim();
    if (trimmed.isEmpty) return 0;
    return (trimmed.split(_whitespaceRegExp).length / 225).ceil();
  }

  /// Removes all whitespace, including internal.
  String get removeWhitespace => replaceAll(_whitespaceRegExp, '');

  /// Reverses the string (Unicode-safe via runes).
  String get reversed => String.fromCharCodes(runes.toList().reversed);

  /// Parses string as boolean (`'true'` evaluates to `true`, else `false`).
  bool get toBool => trim().toLowerCase() == 'true';

  /// `'Hello World'` -> `'helloWorld'`
  String get toCamelCase {
    final words = _words;
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.toSentenceCase).join();
  }

  /// Parses to [double], returns `null` on failure.
  double? get toDoubleOrNull => double.tryParse(this);

  /// Parses to [double], returns `0.0` on failure.
  double get toDoubleOrZero => double.tryParse(this) ?? 0.0;

  /// Parses `"SS"`, `"MM:SS"`, or `"HH:MM:SS"` into a [Duration], returns null on failure.
  Duration? get toDurationOrNull {
    try {
      return toDuration();
    } on FormatException {
      return null;
    }
  }

  /// Parses to [int], returns `null` on failure.
  int? get toIntOrNull => int.tryParse(this);

  /// Parses to [int], returns `0` on failure.
  int get toIntOrZero => int.tryParse(this) ?? 0;

  /// `'Hello World'` / `'helloWorld'` -> `'hello-world'`
  String get toKebabCase => _words.map((w) => w.toLowerCase()).join('-');

  /// `'hello world'` -> `'HELLO_WORLD'`
  String get toScreamingSnakeCase => toSnakeCase.toUpperCase();

  /// Capitalizes only the first character.
  String get toSentenceCase {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// URL-safe slug: lowercased, spaces->hyphens, non-alphanumeric stripped.
  /// `'Hello World! 2024'` -> `'hello-world-2024'`
  String get toSlug =>
      toLowerCase()
          .replaceAll(_whitespaceRegExp, '-')
          .replaceAll(_slugUnsafeRegExp, '')
          .replaceAll(_slugHyphenRegExp, '-')
          .trimHyphens();

  /// `'Hello World'` / `'helloWorld'` -> `'hello_world'`
  String get toSnakeCase => _words.map((w) => w.toLowerCase()).join('_');

  /// Capitalizes the first letter of each whitespace-delimited word.
  String get toTitleCase => trim()
      .split(_whitespaceRegExp)
      .where((w) => w.isNotEmpty)
      .map((w) => w.toSentenceCase)
      .join(' ');

  /// Parses string to [Uri], returns `null` on failure.
  Uri? get toUriOrNull => Uri.tryParse(this);

  /// Splits on whitespace, underscores, hyphens, and camelCase boundaries.
  List<String> get _words =>
      trim()
          .replaceAllMapped(_camelBoundaryRegExp, (m) => '${m[1]} ${m[2]}')
          .split(_wordSeparatorRegExp)
          .where((w) => w.isNotEmpty)
          .toList();

  /// Counts non-overlapping occurrences of [pattern].
  int countOccurrences(String pattern) {
    if (pattern.isEmpty) return 0;
    var count = 0;
    var start = 0;
    while (true) {
      final index = indexOf(pattern, start);
      if (index == -1) break;
      count++;
      start = index + pattern.length;
    }
    return count;
  }

  /// Passes if length falls within [[min], [max]] after trimming.
  bool hasLengthBetween(int min, int max) {
    if (min < 0) {
      throw ArgumentError.value(min, 'min', 'must not be negative');
    }
    if (max < min) {
      throw ArgumentError.value(
        max,
        'max',
        'must be greater than or equal to min',
      );
    }

    final l = trim().length;
    return l >= min && l <= max;
  }

  /// Repeats this string [count] times.
  /// ```dart
  /// '-'.repeat(10); // '----------'
  /// ```
  String repeat(int count) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'must not be negative');
    }

    return List.filled(count, this).join();
  }

  /// Parses `"SS"`, `"MM:SS"`, or `"HH:MM:SS"` into a [Duration].
  Duration toDuration() {
    final parts = split(':');

    int parse(String s, String label, {int max = 59}) {
      final v = int.tryParse(s.trim());
      if (v == null) throw FormatException('Invalid $label: "$this"');
      if (v < 0 || v > max) {
        throw FormatException('$label out of range: "$this"');
      }
      return v;
    }

    return switch (parts.length) {
      1 => Duration(seconds: parse(parts[0], 'seconds')),
      2 => Duration(
        minutes: parse(parts[0], 'minutes'),
        seconds: parse(parts[1], 'seconds'),
      ),
      3 => Duration(
        hours: parse(parts[0], 'hours', max: 23),
        minutes: parse(parts[1], 'minutes'),
        seconds: parse(parts[2], 'seconds'),
      ),
      _ => throw FormatException('Invalid duration format: "$this"'),
    };
  }

  /// Truncates to [maxLength] chars, appending [ellipsis] if cut.
  /// ```dart
  /// 'Hello World'.truncate(7); // 'Hell...'
  /// ```
  String truncate(int maxLength, {String ellipsis = '...'}) {
    _checkTruncationLength(maxLength, ellipsis);
    if (length <= maxLength) return this;
    return substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Truncates at a word boundary instead of mid-word.
  String truncateWords(int maxLength, {String ellipsis = '...'}) {
    _checkTruncationLength(maxLength, ellipsis);
    if (length <= maxLength) return this;
    final cut = substring(0, maxLength - ellipsis.length);
    final lastSpace = cut.lastIndexOf(' ');
    return (lastSpace > 0 ? cut.substring(0, lastSpace) : cut) + ellipsis;
  }

  /// Wraps the string with [prefix] and [suffix] (defaults to [prefix]).
  /// ```dart
  /// 'world'.wrap('**');        // '**world**'
  /// 'note'.wrap('<', '>');     // '<note>'
  /// ```
  String wrap(String prefix, [String? suffix]) {
    return '$prefix$this${suffix ?? prefix}';
  }

  /// Removes leading and trailing hyphens.
  String trimHyphens() {
    var start = 0;
    var end = length;

    while (start < end && codeUnitAt(start) == 45) {
      start++;
    }
    while (end > start && codeUnitAt(end - 1) == 45) {
      end--;
    }

    return substring(start, end);
  }
}

void _checkTruncationLength(int maxLength, String ellipsis) {
  if (maxLength <= ellipsis.length) {
    throw ArgumentError.value(
      maxLength,
      'maxLength',
      'must be greater than ellipsis length (${ellipsis.length})',
    );
  }
}
