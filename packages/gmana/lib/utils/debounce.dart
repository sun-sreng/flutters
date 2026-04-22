import 'debouncer.dart' show Debouncer;

export 'debouncer.dart'
    show DebouncedCallbackX, Debouncer, kDefaultDebounceTime;

/// Backward-compatible alias for [Debouncer].
@Deprecated('Use Debouncer instead.')
typedef Debounce = Debouncer;
