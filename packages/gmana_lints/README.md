# gmana_lints

Production-ready lint rules for Dart and Flutter packages in the gmana
ecosystem. Built on top of [`package:lints/recommended.yaml`][lints] and
calibrated for **library authors** publishing to pub.dev — strict on the
things consumers care about, quiet on stylistic preferences.

[lints]: https://pub.dev/packages/lints

## What it enforces

- **Library correctness** — `library_private_types_in_public_api`,
  `implementation_imports`, `depend_on_referenced_packages`,
  `secure_pubspec_urls`.
- **Documentation** — `public_member_api_docs`, `package_api_docs`,
  `comment_references` (so pub.dev gives you full points).
- **Type safety** — `strict-casts`, `strict-inference`, `strict-raw-types`;
  `type_annotate_public_apis`, `always_declare_return_types`,
  `avoid_dynamic_calls`.
- **Async safety** — `unawaited_futures`, `discarded_futures`,
  `cancel_subscriptions`, `close_sinks`, `avoid_slow_async_io`.
- **Error handling** — `only_throw_errors`, `use_rethrow_when_possible`,
  `throw_in_finally`.
- **Const correctness** — `prefer_const_*` family.
- **API hygiene** — `avoid_positional_boolean_parameters`, `avoid_print`,
  `avoid_setters_without_getters`, `no_runtimeType_toString`.
- **Modern Dart** — `use_super_parameters`, `use_enums`.
- **Flutter-specific** (no-ops on pure-Dart code) —
  `use_key_in_widget_constructors`, `sized_box_for_whitespace`,
  `avoid_unnecessary_containers`, `use_colored_box`, `use_decorated_box`.

## What it intentionally does **not** enforce

These either fight legitimate API design or generate noise without
catching real bugs:

- `require_trailing_commas`, `directives_ordering`,
  `avoid_redundant_argument_values`, `prefer_int_literals`,
  `unnecessary_raw_strings`, `cascade_invocations`,
  `omit_local_variable_types`, `avoid_returning_this` (breaks fluent APIs),
  `always_put_required_named_parameters_first`.

If you want them in a specific package, enable them locally on top of the
shared include.

## Usage

Add to your `dev_dependencies`:

```yaml
dev_dependencies:
  gmana_lints: ^0.1.0
```

Then point your `analysis_options.yaml` at the shared config:

```yaml
include: package:gmana_lints/analysis_options.yaml
```

That's it. The package has no runtime API.

### Overriding rules

`analysis_options.yaml` is mergeable. Add per-package overrides under the
same `include:` to disable a rule or relax a severity:

```yaml
include: package:gmana_lints/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false

analyzer:
  errors:
    todo: ignore
```

## CI

To fail builds on info-level findings, run analyzer with `--fatal-infos`:

```sh
dart analyze --fatal-infos --fatal-warnings .
```

## License

MIT
