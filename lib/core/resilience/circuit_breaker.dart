enum CircuitState { closed, open, halfOpen }

class CircuitBreaker {
  final int failureThreshold;
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  CircuitBreaker({
    this.failureThreshold = 3,
    this.resetTimeout = const Duration(seconds: 15),
  });

  CircuitState get state {
    if (_state == CircuitState.open && _lastFailureTime != null) {
      if (DateTime.now().difference(_lastFailureTime!) > resetTimeout) {
        _state = CircuitState.halfOpen;
      }
    }
    return _state;
  }

  bool get canExecute => state != CircuitState.open;

  void recordSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
  }

  void recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
    }
  }

  Future<T> execute<T>({
    required Future<T> Function() action,
    required T fallback,
  }) async {
    if (!canExecute) return fallback;
    try {
      final result = await action();
      recordSuccess();
      return result;
    } catch (_) {
      recordFailure();
      return fallback;
    }
  }
}
