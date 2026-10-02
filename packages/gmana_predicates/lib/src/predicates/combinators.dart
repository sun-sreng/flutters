/// A boolean test over a value of type [T].
///
/// Every predicate in this package is assignable to `Predicate<String>`,
/// so they can be composed with the combinators below:
///
/// ```dart
/// final Predicate<String> username =
///     isAlphaNumeric.and((s) => s.isLength(3, 16));
/// ```
typedef Predicate<T> = bool Function(T value);

/// Combinators for building [Predicate]s out of smaller ones.
///
/// These are static members rather than top-level functions so that names as
/// common as `all`, `any`, and `not` stay out of the global namespace — and,
/// in particular, so they do not clash with the matchers of the same name in
/// `package:test`.
///
/// ```dart
/// final valid = Predicates.all([isNotBlank, isEmail]);
/// ```
abstract final class Predicates {
  /// A predicate that passes only when every predicate in [predicates] passes.
  ///
  /// Short-circuits on the first failure. An empty [predicates] passes
  /// everything, matching the usual reading of "all of nothing".
  static Predicate<T> all<T>(Iterable<Predicate<T>> predicates) {
    final list = List<Predicate<T>>.of(predicates);
    return (value) {
      for (final predicate in list) {
        if (!predicate(value)) return false;
      }
      return true;
    };
  }

  /// A predicate that passes when at least one of [predicates] passes.
  ///
  /// Short-circuits on the first success. An empty [predicates] rejects
  /// everything.
  static Predicate<T> any<T>(Iterable<Predicate<T>> predicates) {
    final list = List<Predicate<T>>.of(predicates);
    return (value) {
      for (final predicate in list) {
        if (predicate(value)) return true;
      }
      return false;
    };
  }

  /// A predicate that passes only when none of [predicates] pass.
  ///
  /// ```dart
  /// final safe = Predicates.none([isBlank, containsProfanity]);
  /// ```
  static Predicate<T> none<T>(Iterable<Predicate<T>> predicates) =>
      any(predicates).negated;

  /// The negation of [predicate].
  static Predicate<T> not<T>(Predicate<T> predicate) => predicate.negated;

  /// A predicate that passes for every value.
  ///
  /// Useful as the identity element when folding a list of optional rules.
  static Predicate<T> alwaysTrue<T>() => (_) => true;

  /// A predicate that passes for no value.
  static Predicate<T> alwaysFalse<T>() => (_) => false;

  /// A predicate that passes when the value equals [expected].
  static Predicate<T> equalTo<T>(T expected) => (value) => value == expected;

  /// A predicate that passes when the value is one of [values].
  ///
  /// The values are copied into a [Set] once, so repeated calls are O(1).
  static Predicate<T> oneOf<T>(Iterable<T> values) {
    final allowed = Set<T>.of(values);
    return allowed.contains;
  }

  /// Lifts [predicate] to accept `null`, answering [whenNull] for it.
  ///
  /// ```dart
  /// final optionalEmail = Predicates.nullable(isEmail, whenNull: true);
  /// optionalEmail(null);              // true — absent is acceptable
  /// optionalEmail('not an email');    // false
  /// ```
  static Predicate<T?> nullable<T>(
    Predicate<T> predicate, {
    bool whenNull = false,
  }) => (value) => value == null ? whenNull : predicate(value);
}

/// Fluent composition for [Predicate]s.
extension PredicateX<T> on Predicate<T> {
  /// A predicate that passes when both this and [other] pass.
  ///
  /// [other] is not evaluated when this predicate fails.
  Predicate<T> and(Predicate<T> other) =>
      (value) => this(value) && other(value);

  /// A predicate that passes when either this or [other] passes.
  ///
  /// [other] is not evaluated when this predicate passes.
  Predicate<T> or(Predicate<T> other) => (value) => this(value) || other(value);

  /// A predicate that passes when exactly one of this and [other] passes.
  ///
  /// Unlike [and] and [or] this cannot short-circuit — both sides always run.
  Predicate<T> xor(Predicate<T> other) =>
      (value) => this(value) != other(value);

  /// The negation of this predicate.
  Predicate<T> get negated => (value) => !this(value);

  /// Retargets this predicate at a [S] by way of [selector].
  ///
  /// Lets a `Predicate<String>` guard a field of a larger object:
  ///
  /// ```dart
  /// final Predicate<User> hasValidEmail = isEmail.on((user) => user.email);
  /// ```
  Predicate<S> on<S>(T Function(S value) selector) =>
      (value) => this(selector(value));

  /// Whether every element of [values] satisfies this predicate.
  ///
  /// An empty [values] passes.
  bool everyIn(Iterable<T> values) => values.every(this);

  /// Whether at least one element of [values] satisfies this predicate.
  bool anyIn(Iterable<T> values) => values.any(this);
}
