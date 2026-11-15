/// The `Reader<R, A>` monad represents a computation that depends on an environment/dependency `R` and produces `A`.
final class Reader<R, A> {
  /// The underlying function that runs the computation given environment [R].
  final A Function(R env) _run;

  /// Creates a [Reader] wrapping [_run].
  const Reader(this._run);

  /// Runs the computation with the provided environment [env].
  A run(R env) => _run(env);

  /// Transforms the result `A` into `B` using [fn].
  Reader<R, B> map<B>(B Function(A a) fn) {
    return Reader((env) => fn(_run(env)));
  }

  /// Chains another [Reader] computation produced by [fn] based on the result `A`.
  Reader<R, B> flatMap<B>(Reader<R, B> Function(A a) fn) {
    return Reader((env) => fn(_run(env)).run(env));
  }

  /// Modifies the environment [R] using [fn] before passing it to this computation.
  Reader<R2, A> local<R2>(R Function(R2 env2) fn) {
    return Reader((env2) => _run(fn(env2)));
  }

  /// Creates a [Reader] that returns the environment `R` itself.
  static Reader<R, R> ask<R>() => Reader((env) => env);
}
