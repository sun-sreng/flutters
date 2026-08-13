## 0.0.2

Additive release — no existing parameter changed meaning, and a spinner that
sets nothing new looks exactly as it did.

### Added

- **Accessibility.** Every spinner now takes a `semanticsLabel` and, when one
  resolves, wraps itself in a labelled live region. Until now the thirteen
  spinners contributed no semantics at all, so a screen-reader user got no
  indication that anything was loading. There is deliberately no built-in
  default label — the text is user-facing and a package cannot know the app's
  language.

- **`GSpinnerTheme`**, a `ThemeExtension` carrying `color`, `secondaryColor`
  and `semanticsLabel`. Every spinner resolves in the order: argument passed
  to the widget, then this extension, then the widget's own default — so
  installing it never changes a call site that was already explicit. It also
  gives `GCircularSpinner` and `GLinearSpinner` a way off their hardcoded
  purple, which the other eleven spinners never used.

- **`GSpinnerOverlay`**, a scrim-and-spinner overlay for blocking a screen
  during a save or a fetch. It keeps the content laid out (so nothing reflows
  when loading ends), genuinely blocks pointer input, and hides the blocked
  controls from assistive technology while announcing itself.

### Changed

- `GCircularSpinner.color` and `GLinearSpinner.color` are now `Color?` instead
  of `Color`. Passing a color behaves exactly as before, and omitting it still
  yields the legacy purple unless a `GSpinnerTheme` supplies one.

### Fixed

- README: `GDotSpinner` was documented as throwing when given both
  `itemBuilder` and `color`. No such assertion exists — the builder wins and
  `color` is ignored, which is what the class doc always said. The real
  behaviour is now covered by a test.
- README: dropped the claim that `gmana_flutter` re-exports these widgets. It
  does not depend on this package.

### Tests

- 7 → 70, covering theme resolution order, semantics for all thirteen
  spinners, overlay input-blocking, controller ownership and swapping,
  `TickerMode` suspension, constructor assertions, and a full animation cycle
  plus teardown for every animated spinner.

## 0.0.1

- Initial extraction of spinner widgets from `gmana_flutter`.
- Standardize spinner customization, theme-color defaults, controller ownership,
  and public package docs.
- breaking: remove old spinner filenames and aliases in favor of the canonical
  `GDotSpinner`, `GWaveDotSpinner`, and `GBarWaveSpinner` API.
