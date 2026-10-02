/// Re-exports runtime utilities from `gmana_utils`.
///
/// NOTE: the deprecated `Result` and `Failure` aliases from `gmana_utils` are
/// hidden to prevent collisions with `gmana_functional`'s `Failure` and
/// `Result<T>`. The two-track result type itself is `GResult`, `GSuccess`, and
/// `GFailure`, declared in `gmana_functional` and re-exported by `gmana_utils`.
/// `GmanaStreamTimingX` is hidden to prevent extension collision with `StreamX` from `gmana_extensions`.
library;

export 'package:gmana_utils/gmana_utils.dart'
    hide Failure, GmanaStreamTimingX, Result;
