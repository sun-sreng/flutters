/// Functional extensions on [Map] and nullable [Map] types.
extension MapX<K, V> on Map<K, V> {
  /// Returns a new map containing only entries whose key satisfies [test].
  Map<K, V> whereKeys(bool Function(K key) test) {
    final result = <K, V>{};
    for (final entry in entries) {
      if (test(entry.key)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Returns a new map containing only entries whose value satisfies [test].
  Map<K, V> whereValues(bool Function(V value) test) {
    final result = <K, V>{};
    for (final entry in entries) {
      if (test(entry.value)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Returns a new map containing only entries satisfying [test].
  Map<K, V> where(bool Function(K key, V value) test) {
    final result = <K, V>{};
    for (final entry in entries) {
      if (test(entry.key, entry.value)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Returns a new map with keys transformed by [transform].
  Map<K2, V> mapKeys<K2>(K2 Function(K key, V value) transform) {
    final result = <K2, V>{};
    for (final entry in entries) {
      result[transform(entry.key, entry.value)] = entry.value;
    }
    return result;
  }

  /// Returns a new map with values transformed by [transform].
  Map<K, V2> mapValues<V2>(V2 Function(K key, V value) transform) {
    final result = <K, V2>{};
    for (final entry in entries) {
      result[entry.key] = transform(entry.key, entry.value);
    }
    return result;
  }

  /// Returns a new map with inverted key-value pairs (values become keys and vice versa).
  /// If duplicate values exist, the last key overrides previous keys.
  Map<V, K> invert() {
    final result = <V, K>{};
    for (final entry in entries) {
      result[entry.value] = entry.key;
    }
    return result;
  }

  /// Merges [other] into a new map.
  /// If keys collide, [combine] resolves the merged value (defaults to [other]'s value).
  Map<K, V> merge(
    Map<K, V> other, {
    V Function(V existing, V incoming)? combine,
  }) {
    final result = Map<K, V>.of(this);
    for (final entry in other.entries) {
      if (result.containsKey(entry.key) && combine != null) {
        result[entry.key] = combine(result[entry.key] as V, entry.value);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

/// Extension on [Map] with nullable values providing null-filtering utilities.
extension MapNullableValuesX<K, V extends Object> on Map<K, V?> {
  /// Removes null values, returning `Map<K, V>`.
  Map<K, V> get whereNotNullValues {
    final result = <K, V>{};
    for (final entry in entries) {
      if (entry.value != null) {
        result[entry.key] = entry.value!;
      }
    }
    return result;
  }

  /// Alias for [whereNotNullValues].
  Map<K, V> compact() => whereNotNullValues;
}

/// Extension on nullable [Map] values providing safe defaults.
extension MapNullableX<K, V> on Map<K, V>? {
  /// Returns `true` if the map is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns `true` if the map is non-null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns this map or an empty map `{}` if null.
  Map<K, V> get orEmpty => this ?? <K, V>{};
}
