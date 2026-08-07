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
final RegExp _htmlTagRegExp = RegExp(r'<[^>]*>');
final RegExp _lineBreakRegExp = RegExp(r'\r\n|\r|\n');

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

  /// Returns this string unless it is null or blank, in which case [fallback].
  ///
  /// ```dart
  /// nickname.ifBlank('Anonymous')
  /// ```
  String ifBlank(String fallback) => orNull ?? fallback;

  /// Returns this string unless it is null or empty, in which case [fallback].
  ///
  /// Unlike [ifBlank], a whitespace-only string is kept.
  String ifEmpty(String fallback) =>
      (this == null || this!.isEmpty) ? fallback : this!;
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

  /// `'hello world'` -> `'HelloWorld'`
  String get toPascalCase => _words.map((w) => w.toSentenceCase).join();

  /// `'hello world'` -> `'hello.world'`
  String get toDotCase => _words.map((w) => w.toLowerCase()).join('.');

  /// Capitalizes only the first character.
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Parses JSON and returns `Map<String, dynamic>` or `null` if invalid or not a Map.
  Map<String, dynamic>? get toJsonMapOrNull {
    final decoded = jsonDecodeOrNull;
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  /// Removes [prefix] if present at the start of this string.
  String removePrefix(String prefix) =>
      startsWith(prefix) ? substring(prefix.length) : this;

  /// Removes [suffix] if present at the end of this string.
  String removeSuffix(String suffix) =>
      endsWith(suffix) ? substring(0, length - suffix.length) : this;

  /// Masks characters with [maskChar], preserving [unmaskedStart] characters at the beginning
  /// and [unmaskedEnd] characters at the end.
  ///
  /// ```dart
  /// '1234567890'.mask(unmaskedStart: 2, unmaskedEnd: 2); // '12******90'
  /// ```
  String mask({
    int unmaskedStart = 0,
    int unmaskedEnd = 0,
    String maskChar = '*',
  }) {
    if (unmaskedStart < 0) {
      throw ArgumentError.value(
        unmaskedStart,
        'unmaskedStart',
        'must not be negative',
      );
    }
    if (unmaskedEnd < 0) {
      throw ArgumentError.value(
        unmaskedEnd,
        'unmaskedEnd',
        'must not be negative',
      );
    }

    if (length <= unmaskedStart + unmaskedEnd) return this;

    final start = substring(0, unmaskedStart);
    final end = substring(length - unmaskedEnd);
    final maskedLength = length - unmaskedStart - unmaskedEnd;
    final masked = maskChar * maskedLength;

    return '$start$masked$end';
  }

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

  // --- Tokenizing ---

  /// Words split on whitespace, underscores, hyphens, and camelCase
  /// boundaries — the same tokenizer the case converters use.
  ///
  /// ```dart
  /// 'user_firstName'.words; // ['user', 'first', 'Name']
  /// ```
  List<String> get words => _words;

  /// Lines split on `\n`, `\r\n`, or `\r`.
  List<String> get lines => split(_lineBreakRegExp);

  /// Up to [max] uppercase initials taken from the leading words.
  ///
  /// ```dart
  /// 'ada lovelace'.initials();        // 'AL'
  /// 'Grace Brewster Hopper'.initials(max: 3); // 'GBH'
  /// ```
  String initials({int max = 2}) {
    if (max < 0) {
      throw ArgumentError.value(max, 'max', 'must not be negative');
    }

    return trim()
        .split(_whitespaceRegExp)
        .where((w) => w.isNotEmpty)
        .take(max)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  /// Splits into consecutive pieces of at most [size] characters.
  ///
  /// ```dart
  /// '4111111111111111'.chunked(4); // ['4111', '1111', '1111', '1111']
  /// ```
  List<String> chunked(int size) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be greater than zero');
    }

    return [
      for (var i = 0; i < length; i += size)
        substring(i, i + size > length ? length : i + size),
    ];
  }

  // --- Case-insensitive comparison ---

  /// Case-insensitive equality.
  bool equalsIgnoreCase(String other) =>
      length == other.length && toLowerCase() == other.toLowerCase();

  /// Case-insensitive [String.contains].
  bool containsIgnoreCase(String other) =>
      toLowerCase().contains(other.toLowerCase());

  /// Case-insensitive [String.startsWith].
  bool startsWithIgnoreCase(String other) =>
      toLowerCase().startsWith(other.toLowerCase());

  /// Case-insensitive [String.endsWith].
  bool endsWithIgnoreCase(String other) =>
      toLowerCase().endsWith(other.toLowerCase());

  /// Swaps the case of every character.
  ///
  /// ```dart
  /// 'Hello'.swapCase; // 'hELLO'
  /// ```
  String get swapCase =>
      split('').map((c) {
        final upper = c.toUpperCase();
        return c == upper ? c.toLowerCase() : upper;
      }).join();

  // --- Padding, affixes, and shaping ---

  /// Prepends [prefix] unless it is already there.
  ///
  /// ```dart
  /// 'example.com'.ensurePrefix('https://'); // 'https://example.com'
  /// ```
  String ensurePrefix(String prefix) =>
      startsWith(prefix) ? this : '$prefix$this';

  /// Appends [suffix] unless it is already there.
  String ensureSuffix(String suffix) =>
      endsWith(suffix) ? this : '$this$suffix';

  /// Pads both sides so the result is [width] characters wide.
  ///
  /// Extra padding goes to the right when the difference is odd.
  ///
  /// ```dart
  /// 'ok'.padCenter(6, '-'); // '--ok--'
  /// ```
  String padCenter(int width, [String padChar = ' ']) {
    if (padChar.length != 1) {
      throw ArgumentError.value(
        padChar,
        'padChar',
        'must be exactly one character',
      );
    }
    if (length >= width) return this;

    final total = width - length;
    final left = total ~/ 2;
    return '${padChar * left}$this${padChar * (total - left)}';
  }

  /// Prefixes every line with [spaces] spaces (or a custom [prefix]).
  String indent(int spaces, {String? prefix}) {
    if (spaces < 0) {
      throw ArgumentError.value(spaces, 'spaces', 'must not be negative');
    }

    final pad = prefix ?? ' ' * spaces;
    return lines.map((line) => line.isEmpty ? line : '$pad$line').join('\n');
  }

  /// Collapses internal whitespace runs to a single space and trims the ends.
  ///
  /// ```dart
  /// '  a   b \n c '.normalizeWhitespace; // 'a b c'
  /// ```
  String get normalizeWhitespace => trim().replaceAll(_whitespaceRegExp, ' ');

  /// Removes anything that looks like an HTML/XML tag.
  ///
  /// This is a display helper, not a sanitizer — never trust the result as
  /// safe markup.
  String get stripHtmlTags => replaceAll(_htmlTagRegExp, '');

  // --- Safe indexing ---

  /// The character at [index], or `null` when out of range.
  String? charAtOrNull(int index) =>
      (index < 0 || index >= length) ? null : this[index];

  /// [String.substring] that clamps out-of-range bounds instead of throwing.
  ///
  /// ```dart
  /// 'abc'.substringSafe(1, 99); // 'bc'
  /// ```
  String substringSafe(int start, [int? end]) {
    if (isEmpty) return this;
    final from = start < 0 ? 0 : (start > length ? length : start);
    final rawTo = end ?? length;
    final to = rawTo > length ? length : (rawTo < from ? from : rawTo);
    return substring(from, to);
  }

  // --- Encoding and parsing ---

  /// UTF-8 Base64 encoding of this string.
  String get toBase64 => base64Encode(utf8.encode(this));

  /// Decodes Base64 (standard or URL-safe) back to a UTF-8 string,
  /// returning `null` when the input is not valid Base64 text.
  String? get fromBase64OrNull {
    try {
      final normalized = base64.normalize(
        trim().replaceAll('-', '+').replaceAll('_', '/'),
      );
      return utf8.decode(base64Decode(normalized));
    } catch (_) {
      return null;
    }
  }

  /// Lenient boolean parsing. Returns `null` when the value is not
  /// recognizable as a boolean.
  ///
  /// Accepts `true/false`, `yes/no`, `y/n`, `on/off`, and `1/0`,
  /// case-insensitively.
  bool? get toBoolOrNull => switch (trim().toLowerCase()) {
    'true' || 'yes' || 'y' || 'on' || '1' => true,
    'false' || 'no' || 'n' || 'off' || '0' => false,
    _ => null,
  };

  // --- Fuzzy matching ---

  /// Levenshtein edit distance to [other].
  ///
  /// ```dart
  /// 'kitten'.levenshteinDistance('sitting'); // 3
  /// ```
  int levenshteinDistance(String other) {
    if (this == other) return 0;
    if (isEmpty) return other.length;
    if (other.isEmpty) return length;

    var previous = List<int>.generate(other.length + 1, (i) => i);
    var current = List<int>.filled(other.length + 1, 0);

    for (var i = 0; i < length; i++) {
      current[0] = i + 1;
      for (var j = 0; j < other.length; j++) {
        final substitutionCost = this[i] == other[j] ? 0 : 1;
        final deletion = previous[j + 1] + 1;
        final insertion = current[j] + 1;
        final substitution = previous[j] + substitutionCost;
        current[j + 1] =
            deletion < insertion
                ? (deletion < substitution ? deletion : substitution)
                : (insertion < substitution ? insertion : substitution);
      }
      final swap = previous;
      previous = current;
      current = swap;
    }
    return previous[other.length];
  }

  /// Similarity to [other] in `[0, 1]`, derived from [levenshteinDistance].
  ///
  /// `1.0` means identical, `0.0` means nothing in common.
  ///
  /// ```dart
  /// 'colour'.similarityTo('color'); // ~0.83
  /// ```
  double similarityTo(String other) {
    if (this == other) return 1;
    final longest = length > other.length ? length : other.length;
    if (longest == 0) return 1;
    return (longest - levenshteinDistance(other)) / longest;
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
