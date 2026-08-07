/// Convenience accessors and immutable builders for [Uri].
extension UriX on Uri {
  /// Whether this URI uses HTTPS.
  bool get isSecure => scheme == 'https';

  /// Whether this URI uses HTTP or HTTPS.
  bool get isHttp => scheme == 'http' || scheme == 'https';

  /// The host with a leading `www.` removed.
  ///
  /// ```dart
  /// Uri.parse('https://www.example.com/a').domain; // 'example.com'
  /// ```
  String get domain => host.startsWith('www.') ? host.substring(4) : host;

  /// The last non-empty path segment, or `null` when the path is empty
  /// or ends in a slash.
  ///
  /// ```dart
  /// Uri.parse('https://x.com/docs/guide.pdf').fileName; // 'guide.pdf'
  /// ```
  String? get fileName {
    if (pathSegments.isEmpty) return null;
    final last = pathSegments.last;
    return last.isEmpty ? null : last;
  }

  /// The extension of [fileName] without the dot, or `null` when absent.
  ///
  /// ```dart
  /// Uri.parse('https://x.com/a/report.tar.gz').fileExtension; // 'gz'
  /// ```
  String? get fileExtension {
    final name = fileName;
    if (name == null) return null;
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return null;
    return name.substring(dot + 1);
  }

  /// Scheme, host, and port only — path, query, and fragment stripped.
  Uri get origin =>
      Uri(scheme: scheme, host: host, port: hasPort ? port : null);

  /// Returns a copy with [parameters] merged into the query string.
  ///
  /// A `null` value removes that key. Values may be a single value or an
  /// `Iterable` for repeated keys.
  ///
  /// ```dart
  /// Uri.parse('https://x.com/s?q=a')
  ///     .withQueryParameters({'page': 2, 'q': null});
  /// // https://x.com/s?page=2
  /// ```
  Uri withQueryParameters(Map<String, Object?> parameters) {
    final merged = <String, dynamic>{...queryParametersAll};

    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        merged.remove(entry.key);
      } else if (value is Iterable) {
        merged[entry.key] = value.map((e) => '$e').toList();
      } else {
        merged[entry.key] = '$value';
      }
    }

    return merged.isEmpty ? withoutQuery : replace(queryParameters: merged);
  }

  /// Returns a copy with the given query [keys] removed.
  Uri withoutQueryParameters(Iterable<String> keys) {
    final remaining = <String, dynamic>{...queryParametersAll}
      ..removeWhere((key, _) => keys.contains(key));
    return remaining.isEmpty
        ? withoutQuery
        : replace(queryParameters: remaining);
  }

  /// Returns a copy with no query string at all.
  Uri get withoutQuery => Uri(
    scheme: scheme.isEmpty ? null : scheme,
    userInfo: userInfo.isEmpty ? null : userInfo,
    host: host.isEmpty ? null : host,
    port: hasPort ? port : null,
    path: path,
    fragment: hasFragment ? fragment : null,
  );

  /// Returns a copy with [segments] appended to the path.
  ///
  /// ```dart
  /// Uri.parse('https://api.dev/v1').appendPath(['users', '42']);
  /// // https://api.dev/v1/users/42
  /// ```
  Uri appendPath(Iterable<String> segments) {
    final existing = pathSegments.where((s) => s.isNotEmpty);
    final added = segments
        .expand((s) => s.split('/'))
        .where((s) => s.isNotEmpty);
    return replace(pathSegments: [...existing, ...added]);
  }
}

/// Safe defaults for nullable [Uri] references.
extension UriNullableX on Uri? {
  /// Whether this URI is null or has an empty string form.
  bool get isNullOrEmpty => this == null || this!.toString().isEmpty;

  /// The string form, or an empty string when null.
  String get orEmpty => this?.toString() ?? '';
}
