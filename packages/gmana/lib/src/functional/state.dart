import 'use_case.dart';

/// The `State<S, A>` monad represents a computation that passes a state `S` along with a result `A`.
final class State<S, A> {
  /// The underlying function that runs the state computation given an initial state [S].
  final (A value, S state) Function(S initialState) _run;

  /// Creates a [State] instance wrapping [_run].
  const State(this._run);

  /// Runs the computation starting from [initialState] and returns both result and new state as a record `(value, state)`.
  (A value, S state) run(S initialState) => _run(initialState);

  /// Runs the computation starting from [initialState] and returns only the computed result value `A`.
  A evalState(S initialState) => _run(initialState).$1;

  /// Runs the computation starting from [initialState] and returns only the final state `S`.
  S execState(S initialState) => _run(initialState).$2;

  /// Transforms the value `A` produced by this state computation into `B` using [fn].
  State<S, B> map<B>(B Function(A value) fn) {
    return State((s) {
      final (val, newState) = _run(s);
      return (fn(val), newState);
    });
  }

  /// Chains another state computation produced by [fn] based on the result `A` of this computation.
  State<S, B> flatMap<B>(State<S, B> Function(A value) fn) {
    return State((s) {
      final (val, newState) = _run(s);
      return fn(val).run(newState);
    });
  }

  /// Creates a [State] that returns current state `S` as its value without modifying state.
  static State<S, S> get<S>() => State((s) => (s, s));

  /// Creates a [State] that sets state to [newState] and returns [Unit].
  static State<S, Unit> set<S>(S newState) => State((_) => (unit, newState));

  /// Creates a [State] that modifies state using [fn] and returns [Unit].
  static State<S, Unit> modify<S>(S Function(S current) fn) =>
      State((s) => (unit, fn(s)));
}
