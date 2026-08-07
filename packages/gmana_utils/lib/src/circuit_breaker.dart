import 'dart:async';

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

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  int _halfOpenSuccessCount = 0;
  DateTime? _openedAt;

  /// Creates a [CircuitBreaker].
  CircuitBreaker({
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(seconds: 30),
    this.halfOpenSuccessThreshold = 1,
  })  : assert(failureThreshold > 0, 'failureThreshold must be > 0'),
        assert(
          halfOpenSuccessThreshold > 0,
          'halfOpenSuccessThreshold must be > 0',
        );

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
      if (DateTime.now().difference(_openedAt!) >= resetTimeout) {
        _state = CircuitState.halfOpen;
        _halfOpenSuccessCount = 0;
      }
    }
  }

  /// Runs [action] guarded by the circuit breaker.
  ///
  /// Throws [CircuitBreakerOpenException] if circuit is currently open.
  Future<T> run<T>(Future<T> Function() action) async {
    _evaluateStateTransition();

    if (_state == CircuitState.open) {
      final elapsed = DateTime.now().difference(_openedAt!);
      final remaining = resetTimeout - elapsed;
      throw CircuitBreakerOpenException(
        'Circuit breaker is OPEN.',
        remaining.isNegative ? Duration.zero : remaining,
      );
    }

    try {
      final result = await action();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
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
    _state = CircuitState.open;
    _openedAt = DateTime.now();
    _failureCount = 0;
    _halfOpenSuccessCount = 0;
  }

  /// Manually resets the circuit breaker to [CircuitState.closed].
  void reset() {
    _state = CircuitState.closed;
    _failureCount = 0;
    _halfOpenSuccessCount = 0;
    _openedAt = null;
  }
}
