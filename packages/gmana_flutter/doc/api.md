# gmana_flutter API Guide

Import the full public API:

```dart
import 'package:gmana_flutter/gmana_flutter.dart';
```

Form APIs are re-exported for compatibility. New code can import the focused
package directly:

```dart
import 'package:gmana_form/gmana_form.dart';
```

Flutter extension APIs are re-exported for compatibility. New code that only
needs extensions can import the focused package directly:

```dart
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';
```

This package builds on `gmana`, so validator config classes such as
`PasswordValidationConfig` come from:

```dart
import 'package:gmana/validation.dart';
```

## Themes And Design Tokens

```dart
MaterialApp(
  theme: GColors.lightTheme,
  darkTheme: GColors.darkTheme,
  themeMode: 'system'.toThemeMode(),
);
```

| API                                                               | Use it for                                          |
| ----------------------------------------------------------------- | --------------------------------------------------- |
| `GColors.primary`, `primaryDark`, `primaryLight`, `primarySwatch` | Brand colors.                                       |
| `GColors.error`, `success`, `warning`, `info` and `on*` colors    | Semantic status colors.                             |
| `GColors.background`, `surface`, `outline` and dark variants      | Neutral surfaces and borders.                       |
| `GColors.lightTheme`, `GColors.darkTheme`                         | Ready-to-use Material 3 themes.                     |
| `GFontWeight.thin` through `black`                                | Named `FontWeight` constants from `w100` to `w900`. |
| `GSpacing.xxxs` through `xxxlg`, `padding*`, `vSpace`, `hSpace`   | Spacing scale and `EdgeInsets` builders.            |
| `GRadius.xs` through `xl`, `pill`, `all`, `top`, `shape`          | Corner-radius scale and `BorderRadius` builders.    |
| `GMotion.xfast` through `xslow`, `standard`, `enter`, `exit`      | Animation duration and curve tokens.                |
| `GTone` + `GToneScheme`                                           | Semantic intent resolved to accent/container colors.|

`GTone` is the shared status vocabulary used by `GTag` and `GBanner`. It
resolves the semantic `GColors` tokens for the ambient theme:

```dart
final colors = GTone.warning.resolve(context);
colors.accent;      // solid, high emphasis
colors.onAccent;    // readable on accent
colors.container;   // low-emphasis tint
colors.onContainer; // readable on container
```

Light mode uses the hand-tuned `GColors.*Container` tokens. Dark mode derives
a tint from the accent instead, because those light containers are unreadable
on a dark surface.

## Color Utilities

```dart
final color = '#F57224'.toColor();
final textColor = color.contrastText;
final lighter = color.lighten(0.12);
```

| API                                                                        | Use it for                                                |
| -------------------------------------------------------------------------- | --------------------------------------------------------- |
| `String.toColor()`                                                         | Parse `#RGB`, `#RRGGBB`, or `AARRGGBB`-style hex strings. |
| `String.toColorWithOpacity(opacity)`                                       | Parse hex and apply opacity.                              |
| `ColorExt.complementary`, `splitComplementary`, `triadic`, `analogous()`   | Generate color harmonies.                                 |
| `contrastText`, `contrastRatio(other)`                                     | Choose readable foregrounds and measure contrast.         |
| `isDark`, `isLight`, `meetsWcagAA(background)`, `meetsWcagAAA(background)` | Accessibility checks.                                     |
| `greyscale`, `saturate(amount)`, `desaturate(amount)`                      | Adjust saturation.                                        |
| `lighten(amount)`, `darken(amount)`, `tint(amount)`, `shade(amount)`       | Adjust lightness and mix with white/black.                |
| `mix(other, t)`                                                            | Blend two colors.                                         |
| `toHexRGB()`, `toHexARGB()`                                                | Serialize colors.                                         |
| `toMaterialColor()`                                                        | Build a Material swatch.                                  |
| `withAlphaOpacity(opacity)`                                                | Apply opacity through alpha.                              |
| `ColorService.*`                                                           | Static versions of the same color operations.             |

## Responsive Layout

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final columns = constraints.resolve(mobile: 1, tablet: 2, desktop: 4);
    return Text('Columns: $columns');
  },
);

final padding = context.responsive(
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);
```

| API                                                                               | Use it for                              |
| --------------------------------------------------------------------------------- | --------------------------------------- |
| `Breakpoint.mobile`, `tablet`, `desktop`, `widescreen`                            | Semantic screen sizes.                  |
| `Breakpoint.isMobile`, `isTablet`, `isDesktop`, `isWidescreen`                    | Exclusive breakpoint checks.            |
| `Breakpoint.isAtLeastTablet`, `isAtLeastDesktop`                                  | Cumulative breakpoint checks.           |
| `Breakpoint.when(...)`, `maybeWhen(...)`                                          | Branch by breakpoint.                   |
| `Breakpoints.mobile`, `tablet`, `desktop`, `widescreen`                           | Width thresholds.                       |
| `BoxConstraints.breakpoint`                                                       | Resolve constraints to a breakpoint.    |
| `BoxConstraints.resolve(...)`                                                     | Choose values by breakpoint.            |
| `BoxConstraints.deflate(insets)`                                                  | Subtract padding from constraints.      |
| `tightenMaxSize(size)`                                                            | Clamp max constraints to a size.        |
| `largestSize`, `smallestSize`, `isTight`, `isUnboundedWidth`, `isUnboundedHeight` | Constraint inspection.                  |
| `BuildContext.breakpoint`, `responsive(...)`                                      | Resolve values from `MediaQuery` width. |
| `BuildContext.isMobile`, `isTablet`, `isDesktop`, `isWidescreen`                  | Context breakpoint checks.              |

## BuildContext Shortcuts

```dart
context.showSuccessSnackBar(message: 'Saved');
await context.push(const SettingsPage());
```

| API                                                                                                 | Use it for                            |
| --------------------------------------------------------------------------------------------------- | ------------------------------------- |
| `mediaQuery`, `screenSize`, `screenWidth`, `screenHeight`                                           | Access screen metrics.                |
| `safeAreaPadding`, `topSafeArea`, `bottomSafeArea`, `viewInsets`, `viewPadding`                     | Access safe-area and keyboard insets. |
| `devicePixelRatio`, `textScaleFactor`, `isLandscape`, `isPortrait`                                  | Device and orientation checks.        |
| `theme`, `colorScheme`, `textTheme`                                                                 | Theme access.                         |
| `navigator`, `canPop`, `push(widget)`, `pushReplacement(widget)`                                    | Basic navigation.                     |
| `pushAndRemoveUntil(widget, predicate: ...)`, `pop([result])`, `popToRoot()`, `popUntil(predicate)` | Stack navigation.                     |
| `scaffoldMessenger`, `showSnackBar(...)`, `hideSnackBar()`                                          | Snackbar control.                     |
| `showSuccessSnackBar`, `showErrorSnackBar`, `showWarningSnackBar`                                   | Status snackbars.                     |
| `showAppDialog(dialog: ...)`, `showConfirmDialog(...)`                                              | Dialog helpers.                       |
| `showAppBottomSheet(child: ...)`                                                                    | Modal bottom sheet helper.            |
| `hasFocus`, `requestFocus(node)`, `unfocus()`                                                       | Focus helpers.                        |

## Theme Mode Helpers

```dart
final mode = 'dark'.toThemeMode();
final icon = ThemeMode.system.toIcon();
final label = ThemeMode.light.toLabel();
```

| API                                                       | Use it for                                           |
| --------------------------------------------------------- | ---------------------------------------------------- |
| `ThemeModeService.fromKey(key)`                           | Convert `system`, `light`, or `dark` to `ThemeMode`. |
| `getKey(mode)`                                            | Convert `ThemeMode` to storage key.                  |
| `getLabel(mode)`, `getLabelFromKey(key)`                  | Display labels.                                      |
| `getIcon(mode)`, `getIconFromKey(key)`                    | Display icons.                                       |
| `getThemeKeys()`                                          | List valid storage keys.                             |
| `ThemeMode.toIcon()`, `toLabel()`                         | Extension shortcuts.                                 |
| `String.toThemeMode()`, `toThemeIcon()`, `toThemeLabel()` | Extension shortcuts from stored keys.                |

## Forms

```dart
final formKey = GlobalKey<FormState>();
final email = TextEditingController();
final password = TextEditingController();
final confirm = TextEditingController();

Form(
  key: formKey,
  child: Column(
    children: [
      GEmailField(controller: email, labelText: 'Email'),
      GPasswordField(controller: password),
      GConfirmPasswordField(
        controller: confirm,
        passwordController: password,
      ),
      GElevatedButton(
        isLoading: false,
        text: 'Create account',
        onPressed: () => formKey.currentState?.validate(),
      ),
    ],
  ),
);
```

| API                                            | Use it for                                                                  |
| ---------------------------------------------- | --------------------------------------------------------------------------- |
| `GFieldConfig`                                 | Shared configuration for text-form-field wrappers.                          |
| `GConfiguredTextFormField`                     | Render a `TextFormField` from `GFieldConfig`.                               |
| `GObscurableTextFormField`                     | Text field with password visibility toggle.                                 |
| `VisibilityToggle`                             | Reusable show/hide icon button.                                             |
| `GEmailField`                                  | Email input with keyboard type, icon, and `EmailValidator`.                 |
| `GPasswordField`                               | Password input with visibility toggle and `PasswordValidator`.              |
| `GConfirmPasswordField`                        | Confirmation input that compares against a password controller.             |
| `GNumberField`                                 | Numeric input with keyboard/input-formatters from `NumberValidationConfig`. |
| `GTextField`                                   | Text input with `TextValidator`.                                            |
| `GElevatedButton`                              | Elevated button that swaps text for `GWaveDotSpinner` while loading.        |
| `ConfirmPasswordValidationConfig`              | Configure required confirmation and whitespace trimming.                    |
| `ConfirmPasswordValidator.validate(...)`       | Validate password/confirmation pairs.                                       |
| `resolveConfirmPasswordValidationIssue(issue)` | Convert confirm-password issues to English messages.                        |

## Widgets

```dart
Scaffold(
  appBar: const GAppBar(title: 'Profile'),
  body: Column(
    children: const [
      SizedBoxHeight(),
      GStarRatingBar(ratingValue: 4.5),
    ],
  ),
);
```

| API              | Use it for                                                                       |
| ---------------- | -------------------------------------------------------------------------------- |
| `GAppBar`        | App bar with title, actions, colors, optional `bottom`, and `showBackButton`.    |
| `GButton`        | Variants (`primary`/`secondary`/`outline`/`text`/`danger`), sizes, loading state. |
| `GCard`          | Surface container with optional border, tap, and long-press.                     |
| `GListTile`      | List tile with leading icon, title, subtitle, trailing label/widget, and arrow.   |
| `GTextField`     | Text input with clear button, password toggle, formatters, and helper text.      |
| `SizedBoxHeight` | Vertical spacing using `GSpacing.md` by default.                                 |
| `GStarRatingBar` | Star rating display; interactive when `onRatingChanged` is supplied.             |

## Status And Placeholder Widgets

```dart
Column(
  children: [
    const GBanner(
      tone: GTone.warning,
      title: 'Payment overdue',
      message: 'Update your card to keep the subscription active.',
    ),
    const SizedBoxHeight(),
    Row(
      children: [
        GAvatar(name: 'Ada Lovelace'),
        const SizedBoxWidth(),
        const GTag(label: 'Active', tone: GTone.success),
      ],
    ),
  ],
);
```

| API                | Use it for                                                          |
| ------------------ | --------------------------------------------------------------------- |
| `GTag`             | Compact status pill. Tone-aware, optionally filled, icon, or tappable. |
| `GBanner`          | Inline alert with title, actions, and dismissal.                       |
| `GAvatar`          | Image → initials → icon fallback, with a stable per-name tint.        |
| `GAvatar.tintFor`  | The deterministic tint for a name, for matching surrounding chrome.    |
| `GEmptyState`      | Icon/illustration + title + message + action placeholder.              |

`GTag` is not Material's `Badge` (which overlays a child) nor `Chip` (which
carries selection affordances) — it is the standalone status pill. `GBanner`
is the lightweight inline counterpart to the scaffold-owned `MaterialBanner`.

## Loading Indicators

```dart
const GCircularSpinner();
const GLinearSpinner();
GDotSpinner(color: Colors.blue);
GWaveDotSpinner(size: 32, color: Colors.orange);
GWaveSpinner(color: Colors.orange, child: const Icon(Icons.sync));
```

| API                                | Use it for                                                   |
| ---------------------------------- | ------------------------------------------------------------ |
| `GCircularSpinner`                 | Centered circular Material progress indicator.               |
| `GLinearSpinner`                   | Linear Material progress indicator.                          |
| `GDotSpinner`                      | Animated pulsing dot loader.                                 |
| `GWaveDotSpinner`                  | Wave-like animated dot loader.                               |
| `GWaveSpinner`                     | Circular spinner with animated wave fill and optional child. |
| `DotAnimationConfig.forIndex(...)` | Build staggered dot animation intervals.                     |
| `DelayedAnimationTween`            | Tween with delayed sine-wave easing.                         |

## Serialization And Locale Helpers

```dart
final encoded = Icons.home.toJsonString();
final icon = IconDataExt.parse(encoded);

final localeText = fromLocale(const Locale('en', 'US')); // en_US
final locale = toLocale('km_KH');
```

| API                                        | Use it for                                                     |
| ------------------------------------------ | -------------------------------------------------------------- |
| `IconDataExt.tryParse(source)`             | Parse serialized icon JSON or return `null`.                   |
| `IconDataExt.parse(source, fallback: ...)` | Parse serialized icon JSON or return fallback.                 |
| `IconData.toJsonString()`                  | Serialize icon data to JSON.                                   |
| `IconData.isSerializable`                  | Check whether icon serialization round-trips.                  |
| `fromLocale(locale)`                       | Convert a `Locale` to `language[_script][_country]` text.      |
| `toLocale(text)`                           | Convert locale text back to a `Locale`, defaulting to `en_US`. |
| `registerErrorHandlers()`                  | Install basic Flutter/platform error handlers and error UI.    |
