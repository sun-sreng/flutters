/// Re-exports runtime utilities from `gmana_utils`.
///
/// The two-track result type is `GResult`, `GSuccess`, and `GFailure`,
/// declared in `gmana_functional` and re-exported by `gmana_utils`.
/// `GmanaStreamTimingX` is hidden to prevent extension collision with `StreamX` from `gmana_extensions`.
library;

export 'package:gmana_utils/gmana_utils.dart' hide GmanaStreamTimingX;
