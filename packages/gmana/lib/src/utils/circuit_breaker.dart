import 'dart:async';

import 'package:clock/clock.dart';

/// States of a [CircuitBreaker].
enum CircuitState {
  /// Normal operation: calls pass through.
  closed,

  /// Tripped state: calls fail immediately.
  open,

  /// Trial state: test call to check if target system has recovered.
  halfOpen,
}

/// Exception thrown when a call is executed while [CircuitBreaker] is open.
class CircuitBreakerOpenException implements Exception {
  /// Message explaining the open state.
  final String message;

  /// Time remaining before circuit enters half-open trial state.
  final Duration remainingTimeout;

  /// Creates a [CircuitBreakerOpenException].
  const CircuitBreakerOpenException(this.message, this.remainingTimeout);

  @override
  String toString() =>
      'CircuitBreakerOpenException: $message (Reset in ${remainingTimeout.inMilliseconds}ms)';
}

/// Guards operations against cascading failures by tripping open when failure threshold is reached.
class CircuitBreaker {
  /// Consecutive failures before opening the circuit.
  final int failureThreshold;

  /// Duration to remain open before transitioning to half-open state.
  final Duration resetTimeout;

  /// Successful trial executions required in half-open state to re-close circuit.
  final int halfOpenSuccessThreshold;

  /// Called whenever the circuit moves to a different state.
  ///
  /// Useful for logging or metrics. Exceptions thrown by the callback
  /// propagate to whoever triggered the transition.
  final void Function(CircuitState state)? onStateChange;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  int _halfOpenSuccessCount = 0;
  bool _halfOpenProbeInFlight = false;
  DateTime? _openedAt;

  /// Creates a [CircuitBreaker].
  CircuitBreaker({
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(seconds: 30),
    this.halfOpenSuccessThreshold = 1,
    this.onStateChange,
  }) : assert(failureThreshold > 0, 'failureThreshold must be > 0'),
       assert(
         halfOpenSuccessThreshold > 0,
         'halfOpenSuccessThreshold must be > 0',
       );

  /// Consecutive failures recorded since the last success or state change.
  ///
  /// Reaching [failureThreshold] while closed trips the circuit open.
  int get failureCount => _failureCount;

  /// Current state of the circuit breaker.
  CircuitState get state {
    _evaluateStateTransition();
    return _state;
  }

  /// Returns `true` if circuit is in [CircuitState.closed].
  bool get isClosed => state == CircuitState.closed;

  /// Returns `true` if circuit is in [CircuitState.open].
  bool get isOpen => state == CircuitState.open;

  /// Returns `true` if circuit is in [CircuitState.halfOpen].
  bool get isHalfOpen => state == CircuitState.halfOpen;

  void _evaluateStateTransition() {
    if (_state == CircuitState.open && _openedAt != null) {
      if (clock.now().difference(_openedAt!) >= resetTimeout) {
        _halfOpenSuccessCount = 0;
        _setState(CircuitState.halfOpen);
      }
    }
  }

  /// Moves to [next], notifying [onStateChange] only on an actual change.
  void _setState(CircuitState next) {
    if (_state == next) return;
    _state = next;
    onStateChange?.call(next);
  }

  /// Runs [action] guarded by the circuit breaker.
  ///
  /// Throws [CircuitBreakerOpenException] if the circuit is currently open, or
  /// if the circuit is half-open and a trial call is already in flight. Only
  /// one half-open trial runs at a time, so a recovering dependency receives a
  /// single probe rather than the full concurrent load.
  Future<T> run<T>(Future<T> Function() action) async {
    _evaluateStateTransition();

    if (_state == CircuitState.open) {
      final elapsed = clock.now().difference(_openedAt!);
      final remaining = resetTimeout - elapsed;
      throw CircuitBreakerOpenException(
        'Circuit breaker is OPEN.',
        remaining.isNegative ? Duration.zero : remaining,
      );
    }

    var isTrialCall = false;
    if (_state == CircuitState.halfOpen) {
      if (_halfOpenProbeInFlight) {
        throw const CircuitBreakerOpenException(
          'Circuit breaker is HALF-OPEN and a trial call is already in flight.',
          Duration.zero,
        );
      }
      _halfOpenProbeInFlight = true;
      isTrialCall = true;
    }

    try {
      final result = await action();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    } finally {
      if (isTrialCall) _halfOpenProbeInFlight = false;
    }
  }

  void _onSuccess() {
    if (_state == CircuitState.halfOpen) {
      _halfOpenSuccessCount++;
      if (_halfOpenSuccessCount >= halfOpenSuccessThreshold) {
        reset();
      }
    } else if (_state == CircuitState.closed) {
      _failureCount = 0;
    }
  }

  void _onFailure() {
    _failureCount++;
    if (_state == CircuitState.closed) {
      if (_failureCount >= failureThreshold) {
        _tripOpen();
      }
    } else if (_state == CircuitState.halfOpen) {
      _tripOpen();
    }
  }

  void _tripOpen() {
    _openedAt = clock.now();
    _failureCount = 0;
    _halfOpenSuccessCount = 0;
    _setState(CircuitState.open);
  }

  /// Manually resets the circuit breaker to [CircuitState.closed].
  void reset() {
    _failureCount = 0;
    _halfOpenSuccessCount = 0;
    _halfOpenProbeInFlight = false;
    _openedAt = null;
    _setState(CircuitState.closed);
  }
}
