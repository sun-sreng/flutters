import 'throttler.dart' show Throttler, kDefaultThrottleDuration;

export 'throttler.dart'
    show ThrottledCallbackX, Throttler, kDefaultThrottleDuration;

/// Backward-compatible alias for [kDefaultThrottleDuration].
@Deprecated('Use kDefaultThrottleDuration instead.')
const kDefaultThrottlerDuration = kDefaultThrottleDuration;

/// Backward-compatible alias for [Throttler].
@Deprecated('Use Throttler instead.')
typedef Throttle = Throttler;
