/// Production-ready lint rules for the gmana workspace.
///
/// This package exposes a single shared `analysis_options.yaml`. It has no
/// runtime API. To use it, add `gmana_lints` to your `dev_dependencies` and
/// reference the config from your package's `analysis_options.yaml`:
///
/// ```yaml
/// include: package:gmana_lints/analysis_options.yaml
/// ```
library;
