/// Re-exports runtime utilities from `gmana_utils`.
///
/// NOTE: `Result` and `Failure` from `gmana_utils` are hidden to prevent collisions
/// with `gmana_functional`'s `Failure` and `Result<T>`. Use `GResult`, `GSuccess`,
/// and `GFailure` when working with `gmana_utils` two-track results.
library;

export 'package:gmana_utils/gmana_utils.dart' hide Failure, Result;
