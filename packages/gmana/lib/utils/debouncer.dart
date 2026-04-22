import 'dart:async';

/// Default debounce time in milliseconds.
const kDefaultDebounceTime = 150;

/// A small utility to debounce function execution.
class Debouncer {
  /// Debounce delay in milliseconds.
  final int milliseconds;

  Timer? _timer;

  /// Creates a debouncer with the provided [milliseconds] delay.
  Debouncer({this.milliseconds = kDefaultDebounceTime});

  /// Cancels any pending action.
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
  }

  /// Schedules [action], replacing any pending action.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

/// Extension that debounces a callback inline.
extension DebouncedCallbackX on void Function() {
  /// Runs this callback through a newly created debouncer.
  void debounce({int milliseconds = kDefaultDebounceTime}) {
    final debouncer = Debouncer(milliseconds: milliseconds);
    debouncer.run(call);
  }
}
