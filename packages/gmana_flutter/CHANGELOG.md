# Changelog

## 0.0.9 - 2026-04-24

- compatibility: re-export spinner widgets from the new `gmana_spinner` package.
- internal: update `GElevatedButton` to use `GWaveDotSpinner` from `gmana_spinner`.
- breaking: remove old direct spinner forwarding files; use the canonical
  `g_dot_spinner.dart`, `g_wave_dot_spinner.dart`, and `g_bar_wave_spinner.dart`
  paths from `gmana_spinner`.

## 0.0.8 - 2026-04-23

- breaking: make `registerErrorHandlers` opt into custom error UI instead of replacing `ErrorWidget.builder` by default
- feat: add `GStarRatingBar` as the canonical prefixed rating widget and deprecate `StarRatingBar`
- feat: expand `GFieldConfig` with common `TextFormField` options for focus, decoration, validation mode, save/submit callbacks, text style, and line constraints
- polish: remove corrupted source comment separators from Flutter extension and color helper files
- breaking: rename canonical spinner widgets to `GCircularSpinner`, `GLinearSpinner`, and `GWaveSpinner`
- breaking: remove deprecated spinner aliases and add widget tests for the public form/spinner surface
- breaking: require Flutter 3.29 or newer to match the package's Dart SDK and modern Flutter API usage
- breaking: remove the duplicate `ResponsiveContext.screenSize` extension member; use `ContextExt.screenSize` instead
- polish: expand the main `gmana_flutter.dart` export surface for design tokens, responsive/context helpers, icon serialization, locale helpers, and string/time extensions
- doc: refresh README examples so the primary import and color APIs are copy-pasteable

## 0.0.7

- doc: update README.md

## 0.0.6

- doc: add dart doc

## 0.0.5

- Add TextForm validation

## 0.0.4

Refactor form field structure and add new field components with validation

## 0.0.3

- Add ColorExtensionExampleApp and enhance theme mode functionality
- Introduced ColorExtensionExampleApp to demonstrate color manipulation features.
- Updated theme mode handling in ThemeModeExampleApp to use named routes.
- Added MaterialColor creation method in ColorService for better color management.
- Refactored theme mode service to include methods for retrieving theme keys and converting ThemeMode to keys.

## 0.0.2

- Update color extension methods for improved hex conversion and opacity handling

## 0.0.1

- Initial release.
