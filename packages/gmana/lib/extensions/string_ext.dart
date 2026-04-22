import 'dart:convert';

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

// ─── Nullable ─────────────────────────────────────────────────────────────

/// Main extension on String providing comprehensive conversion and formatting tools.
extension StringX on String {
  // ── Parsing ───────────────────────────────────────────────────────────────

  /// Returns `null` if blank, otherwise `this`. Useful for form validation chains.
  /// ```dart
  /// nameController.text.blankToNull ?? 'Anonymous'
  /// ```
  String? get blankToNull => isBlank ? null : this;

  /// Returns true if the string only contains letters.
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Returns true if the string only contains letters and numbers.
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// Returns true if the string is purely whitespace or empty.
  bool get isBlank => trim().isEmpty;

  /// Returns true if the string is a valid email format.
  bool get isEmail => RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(trim());

  /// Returns true if the string contains non-whitespace characters.
  bool get isNotBlank => trim().isNotEmpty;

  /// Returns true if the string represents a valid number.
  bool get isNumeric => double.tryParse(this) != null;

  // ── Duration ─────────────────────────────────────────────────────────────

  /// Returns true if the string is a valid URL.
  bool get isUrl => Uri.tryParse(this)?.hasAbsolutePath ?? false;

  /// Decodes JSON, returns `null` on failure instead of throwing.
  dynamic get jsonDecodeOrNull {
    try {
      return jsonDecode(this);
    } catch (_) {
      return null;
    }
  }

  // ── Case formatting ───────────────────────────────────────────────────────

  /// Estimates the reading time in minutes (225 words per minute).
  int get readingTimeMinutes {
    final trimmed = trim();
    if (trimmed.isEmpty) return 0;
    return (trimmed.split(RegExp(r'\s+')).length / 225).ceil();
  }

  /// Removes all whitespace, including internal.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Reverses the string (Unicode-safe via runes).
  String get reversed => String.fromCharCodes(runes.toList().reversed);

  /// Parses string as boolean (`'true'` evaluates to `true`, else `false`).
  bool get toBool => trim().toLowerCase() == 'true';

  /// `'Hello World'` → `'helloWorld'`
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

  // ── Slug / identifiers ────────────────────────────────────────────────────

  /// Parses `"SS"`, `"MM:SS"`, or `"HH:MM:SS"` into a [Duration], returns null on failure.
  Duration? get toDurationOrNull {
    try {
      return toDuration();
    } on FormatException {
      return null;
    }
  }

  // ── Truncation ────────────────────────────────────────────────────────────

  /// Parses to [int], returns `null` on failure.
  int? get toIntOrNull => int.tryParse(this);

  /// Parses to [int], returns `0` on failure.
  int get toIntOrZero => int.tryParse(this) ?? 0;

  // ── Validation ────────────────────────────────────────────────────────────

  /// `'Hello World'` / `'helloWorld'` → `'hello-world'`
  String get toKebabCase => _words.map((w) => w.toLowerCase()).join('-');

  /// `'hello world'` → `'HELLO_WORLD'`
  String get toScreamingSnakeCase => toSnakeCase.toUpperCase();

  /// Capitalizes only the first character.
  String get toSentenceCase {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// URL-safe slug: lowercased, spaces→hyphens, non-alphanumeric stripped.
  /// `'Hello World! 2024'` → `'hello-world-2024'`
  String get toSlug =>
      toLowerCase()
          .replaceAll(RegExp(r'\s+'), '-')
          .replaceAll(RegExp(r'[^a-z0-9\-]'), '')
          .replaceAll(RegExp(r'-+'), '-')
          .trim();

  /// `'Hello World'` / `'helloWorld'` → `'hello_world'`
  String get toSnakeCase => _words.map((w) => w.toLowerCase()).join('_');

  /// Capitalizes the first letter of each whitespace-delimited word.
  String get toTitleCase => trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w.toSentenceCase)
      .join(' ');

  // ── Whitespace / blank ────────────────────────────────────────────────────

  /// Parses string to [Uri], returns `null` on failure.
  Uri? get toUriOrNull => Uri.tryParse(this);

  /// Splits on whitespace, underscores, hyphens, and camelCase boundaries.
  List<String> get _words =>
      trim()
          .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
          .split(RegExp(r'[\s_\-]+'))
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

  // ── Reading time ──────────────────────────────────────────────────────────

  /// Passes if length falls within [[min], [max]] after trimming.
  bool hasLengthBetween(int min, int max) {
    final l = trim().length;
    return l >= min && l <= max;
  }

  // ── Misc ──────────────────────────────────────────────────────────────────

  /// Repeats this string [count] times.
  /// ```dart
  /// '-'.repeat(10); // '----------'
  /// ```
  String repeat(int count) => List.filled(count, this).join();

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
    assert(
      maxLength > ellipsis.length,
      'maxLength must exceed ellipsis length',
    );
    if (length <= maxLength) return this;
    return substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Truncates at a word boundary instead of mid-word.
  String truncateWords(int maxLength, {String ellipsis = '...'}) {
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
  String wrap(String prefix, [String? suffix]) =>
      '$prefix$this${suffix ?? prefix}';
}
