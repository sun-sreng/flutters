# gmana_flutter

Flutter UI toolkit for production apps: design tokens, widgets, typed form
fields, loading spinners, and Flutter extensions, built on the pure Dart
[`gmana`](https://pub.dev/packages/gmana) package.

```dart
import 'package:gmana_flutter/gmana_flutter.dart';
```

One import gives you this package and everything in `gmana` (functional types,
extensions, predicates, validation, value objects, utilities). The one
exception is the functional `State` monad, which is hidden because it clashes
with Flutter's `State`. Import `package:gmana/functional.dart` with a prefix if
you need it.

Topic libraries are available when you want a narrower import:

```dart
import 'package:gmana_flutter/extensions.dart';
import 'package:gmana_flutter/form.dart';
import 'package:gmana_flutter/spinner.dart';
```

## Requirements

- Dart SDK `^3.7.2`
- Flutter `>=3.29.0`

## Installation

```bash
flutter pub add gmana_flutter
```

## Guides

| Area | Guide |
| --- | --- |
| Flutter extensions | [doc/extensions.md](doc/extensions.md) |
| Form fields and validators | [doc/form.md](doc/form.md) |
| Loading spinners | [doc/spinner.md](doc/spinner.md) |
| Widgets and tokens reference | [doc/api.md](doc/api.md) |
| Pure Dart APIs | [gmana guides](https://pub.dev/packages/gmana) |

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gmana Flutter Demo',
      theme: GColors.lightTheme,
      darkTheme: GColors.darkTheme,
      themeMode: 'system'.toThemeMode(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GAppBar(title: 'Home'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GWaveDotSpinner(size: 28, color: GColors.primary),
            const GGap.vertical(GSpacing.md),
            Text(
              'Ready',
              style: TextStyle(color: GColors.primary.contrastText),
            ),
          ],
        ),
      ),
    );
  }
}
```

## What You Can Use

| Area       | APIs                                                                                                       |
| ---------- | ---------------------------------------------------------------------------------------------------------- |
| Widgets    | `GAppBar`, `GButton`, `GCard`, `GListTile`, `GGap`, `GStarRatingBar`, `GTextField`                          |
| Status UI  | `GTag`, `GBanner`, `GAvatar`, `GEmptyState`                                                                |
| Forms      | `GEmailField`, `GPasswordField`, `GNumberField`, `GTextFormField`, `GConfirmPasswordField`, `GFormSubmitButton` |
| Loading    | `GCircularSpinner`, `GLinearSpinner`, `GDotSpinner`, `GWaveSpinner`, `GWaveDotSpinner`                     |
| Tokens     | `GColors`, `GFontWeight`, `GSpacing`, `GRadius`, `GMotion`, `GTone`                                        |
| Theme      | `ThemeModeX`, `ThemeModes`                                                                         |
| Extensions | `ColorX`, `StringColorX`, `BoxConstraintsX`, `BuildContextResponsiveX`, `BuildContextX`                   |
| Utilities  | `IconDataCodec`, `IconDataX`, `formatLocale`, `parseLocale`, `registerErrorHandlers`                  |

## Theme Setup

Use the built-in themes directly:

```dart
MaterialApp(
  theme: GColors.lightTheme,
  darkTheme: GColors.darkTheme,
  themeMode: ThemeMode.system,
  home: const HomePage(),
);
```

Or keep the selected theme mode as a string:

```dart
final savedTheme = 'dark';

MaterialApp(
  themeMode: savedTheme.toThemeMode(),
  theme: GColors.lightTheme,
  darkTheme: GColors.darkTheme,
  home: const HomePage(),
);
```

Useful theme helpers:

```dart
// ThemeMode extensions
ThemeMode.dark.toKey();    // 'dark'
ThemeMode.dark.toLabel();  // 'Dark Mode'
ThemeMode.dark.toIcon();   // Icons.dark_mode

// ThemeModes — all methods are static
ThemeModes.fromKey('light');                                        // ThemeMode.light
ThemeModes.getThemeKeys();                                          // ['system', 'light', 'dark']
ThemeModes.getThemeKeys().map(ThemeModes.getLabelFromKey).toList(); // ['System Mode', 'Light Mode', 'Dark Mode']
```

## Forms

The field widgets wrap `TextFormField` with consistent defaults and the typed
validators from `gmana`. See [doc/form.md](doc/form.md) for every field,
`GForm`, `GFormController`, and `GValidators`.

```dart
import 'package:flutter/material.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({super.key});

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          GEmailField(
            controller: emailController,
            label: 'Email',
          ),
          const GGap.vertical(GSpacing.md),
          GPasswordField(
            controller: passwordController,
            validationConfig: PasswordValidationConfig.strong(),
          ),
          const GGap.vertical(GSpacing.md),
          GConfirmPasswordField(
            controller: confirmPasswordController,
            passwordController: passwordController,
          ),
          const GGap.vertical(GSpacing.xlg),
          GButton(
            label: 'Create account',
            fullWidth: true,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                context.showSuccessSnackBar(message: 'Account form is valid');
              }
            },
          ),
        ],
      ),
    );
  }
}
```

For custom `TextFormField` configuration, use `GConfiguredTextFormField`:

```dart
GConfiguredTextFormField(
  config: GTextFieldConfig(
    controller: controller,
    label: 'Display name',
    hint: 'Enter your name',
    prefixIcon: Icons.person,
    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
  ),
);
```

## Loading Indicators

Use the lightweight indicators anywhere a normal widget is accepted:

```dart
const GCircularSpinner();
const GLinearSpinner();
const GDotSpinner(color: Colors.blue);
const GWaveDotSpinner(size: 24, color: Colors.blue);
```

## Widgets

`gmana_flutter` provides core curated widgets:

```dart
// Buttons
GButton(
  label: 'Submit',
  onPressed: () => print('Submitted'),
  variant: GButtonVariant.primary,
  isLoading: false,
);

// Cards
GCard(
  onTap: () => print('Tapped'),
  child: Text('Card Content'),
);

// Input Fields
GTextField(
  label: 'Password',
  enablePasswordToggle: true,
  enableClearButton: true,
);

// Spacing
const GGap.vertical(GSpacing.md);
const GGap.horizontal(GSpacing.lg);
const GGap(GSpacing.sm);
```

`GButton` has size presets, a destructive variant, and a trailing icon slot:

```dart
GButton(
  label: 'Delete account',
  variant: GButtonVariant.danger,
  size: GButtonSize.large,
  tooltip: 'This cannot be undone',
  onPressed: confirmDelete,
);

GButton(
  label: 'Next',
  size: GButtonSize.small,
  trailingIcon: const Icon(Icons.arrow_forward, size: 16),
  onPressed: goNext,
);
```

`GStarRatingBar` is read-only until you give it a callback:

```dart
GStarRatingBar(
  ratingValue: rating,
  starSize: 32,
  onRatingChanged: (value) => setState(() => rating = value),
);
```

## Design Tokens

Radius and motion tokens keep components visually consistent:

```dart
GRadius.xs;     // 4  — chips, tags
GRadius.sm;     // 8  — buttons, inputs
GRadius.md;     // 12 — cards
GRadius.pill;   // fully rounded

GRadius.all(GRadius.md);      // BorderRadius
GRadius.top(GRadius.lg);      // top corners only
GRadius.start(GRadius.sm);    // direction-aware
GRadius.shape(GRadius.md);    // RoundedRectangleBorder

GMotion.fast;       // 150ms
GMotion.normal;     // 250ms
GMotion.standard;   // Curves.easeInOut

AnimatedContainer(
  duration: GMotion.normal,
  curve: GMotion.standard,
  decoration: BoxDecoration(borderRadius: GRadius.all()),
  child: child,
);
```

`GSpacing` also covers single sides and RTL-aware insets:

```dart
GSpacing.paddingOnly(left: GSpacing.md, bottom: GSpacing.sm);
GSpacing.paddingDirectional(start: GSpacing.lg, end: GSpacing.xs);
```

## Semantic Tones

`GTone` is the shared vocabulary behind the status widgets. It resolves the
`GColors` semantic tokens for the current theme — light mode uses the
hand-tuned containers, dark mode derives a readable tint instead.

```dart
final colors = GTone.warning.resolve(context);

Container(
  color: colors.container,
  child: Text('Careful', style: TextStyle(color: colors.onContainer)),
);

GTone.error.icon;   // Icons.error_outline
GTone.success.icon; // Icons.check_circle_outline
```

## Status And Placeholder Widgets

### Tags

```dart
const GTag(label: 'Active', tone: GTone.success);
const GTag(label: 'Overdue', tone: GTone.error, filled: true);
const GTag(label: 'Beta', icon: Icons.science, compact: true);
GTag(label: 'Filter', onTap: applyFilter);
```

### Banners

```dart
const GBanner(
  tone: GTone.warning,
  title: 'Payment overdue',
  message: 'Update your card to keep the subscription active.',
);

GBanner(
  tone: GTone.error,
  message: 'Could not reach the server.',
  onDismiss: hideBanner,
  actions: [
    GButton(label: 'Retry', size: GButtonSize.small, onPressed: retry),
  ],
);
```

### Avatars

```dart
GAvatar(name: 'Ada Lovelace');                  // 'AL' on a stable tint
GAvatar(image: NetworkImage(url), name: 'Ada'); // falls back if it fails
GAvatar(name: 'Ada', size: 56, square: true);
GAvatar(
  name: 'Ada',
  badge: const Icon(Icons.circle, size: 10, color: Colors.green),
);

// The same tint the avatar picks, for matching chrome
final tint = GAvatar.tintFor('Ada Lovelace');
```

### Empty states

```dart
GEmptyState(
  icon: Icons.inbox_outlined,
  title: 'No messages',
  message: 'When someone writes to you it will show up here.',
  action: GButton(label: 'Refresh', onPressed: reload),
);

const GEmptyState(title: 'Nothing matched', compact: true);
```

Use `GWaveSpinner` with explicit bounds:

```dart
const SizedBox(
  width: 48,
  height: 48,
  child: GWaveSpinner(color: GColors.primary),
);
```

`GButton` shows a spinner while work is running. Inside a `GForm`,
`GFormSubmitButton` drives that state from the form controller:

```dart
GButton(label: 'Save', isLoading: saving, onPressed: save);

GFormSubmitButton(label: 'Save', onSubmit: (values) => repository.save(values));
```

## Color Utilities

Color extensions cover common UI operations:

```dart
const brand = Color(0xFFF57224);

final rgb = brand.toHexRGB(); // '#F57224'
final argb = brand.toHexARGB(); // '#FFF57224'
final textColor = brand.contrastText;
final hover = brand.lighten(0.08);
final pressed = brand.darken(0.12);
final muted = brand.desaturate(0.2);
final complementary = brand.complementary;
final materialSwatch = brand.toMaterialColor();
```

Parse colors from strings:

```dart
final fromFullHex = '#F57224'.toColor();
final fromShortHex = '#F50'.toColor();
final optionalColor = ColorMath.tryParseHex('#80F57224');
```

Check contrast:

```dart
final passesAA = Colors.white.meetsWcagAA(GColors.primary);
final ratio = Colors.white.contrastRatio(GColors.primary);
```

## Responsive Layout

Resolve values from `BoxConstraints`:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final columns = constraints.resolve(
      mobile: 1,
      tablet: 2,
      desktop: 3,
      widescreen: 4,
    );

    return GridView.count(
      crossAxisCount: columns,
      children: const [],
    );
  },
);
```

Resolve values from `BuildContext`:

```dart
final padding = context.responsive(
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
  widescreen: 40.0,
);

final isCompact = context.isMobile;
final size = context.screenSize;
```

## Layout & Responsive Widgets

### GResponsiveBuilder

```dart
GResponsiveBuilder(
  mobile: (context) => MobileLayout(),
  tablet: (context) => TabletLayout(),
  desktop: (context) => DesktopLayout(),
)
```

It switches at the same thresholds as `context.breakpoint`: tablet from
`Breakpoints.tablet` (730) and desktop from `Breakpoints.desktop` (1200). Pass
`mobileBreakpoint` and `tabletBreakpoint` to use others.

### GGrid

```dart
GGrid(
  maxItemWidth: 200,
  spacing: GSpacing.md,
  children: [Card1(), Card2(), Card3()],
)
```

### GGap

```dart
Column(
  children: [
    WidgetA(),
    GGap.vertical(GSpacing.md),
    WidgetB(),
  ],
)
```

### GDivider

```dart
GDivider(label: 'OR')
```


## Snackbars, Navigation, And Dialogs

`BuildContextX` gives short helpers for common app actions:

```dart
context.showSuccessSnackBar(message: 'Saved');
context.showErrorSnackBar(message: 'Unable to save');
context.unfocus();

final confirmed = await context.showConfirmDialog(
  title: 'Delete item?',
  message: 'This action cannot be undone.',
  destructive: true,
);

if (confirmed) {
  context.pop();
}
```

## Icon Serialization

Store Flutter `IconData` values as JSON strings:

```dart
final json = Icons.home.toJsonString();
final icon = IconDataCodec.tryParse(json) ?? Icons.broken_image;
```

Use a fallback when parsing required values:

```dart
final icon = IconDataCodec.parse(
  savedIconJson,
  fallback: Icons.help_outline,
);
```

## Locale Helpers

Convert between `Locale` and underscore-separated locale tags:

```dart
final tag = formatLocale(const Locale('en', 'US')); // 'en_US'
final locale = parseLocale('km_KH'); // Locale('km', 'KH')
```

## Error Handler Setup

Call `registerErrorHandlers()` once in `main()` when you want Flutter framework
errors forwarded through the package's handler setup:

```dart
void main() {
  registerErrorHandlers();
  runApp(const App());
}
```

## Example App

The package includes a Flutter showcase under `example/`.

```bash
cd example
flutter pub get
flutter run
```

The example demonstrates theme switching, color utilities, layout polish, the
package's UI components, and dedicated pages for the Flutter extensions, form
fields, and loading spinners.
