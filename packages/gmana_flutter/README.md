# gmana_flutter

Flutter UI utilities for production apps: form-field compatibility exports,
loading indicator compatibility exports, theme helpers, extension compatibility
exports, and small design-system tokens.

```dart
import 'package:gmana_flutter/gmana_flutter.dart';
```

## Requirements

- Dart SDK `^3.7.2`
- Flutter `>=3.29.0`

## Installation

```bash
flutter pub add gmana_flutter
```

Loading indicators now live in the focused `gmana_spinner` package and are
re-exported from `gmana_flutter` for compatibility:

```bash
flutter pub add gmana_spinner
```

Form widgets now live in the focused `gmana_form` package and are re-exported
from `gmana_flutter` for compatibility:

```bash
flutter pub add gmana_form
```

Flutter extension methods now live in the focused `gmana_flutter_extensions`
package and are re-exported from `gmana_flutter` for compatibility:

```bash
flutter pub add gmana_flutter_extensions
```

If you use validator configuration classes such as
`PasswordValidationConfig`, add the core package too:

```bash
flutter pub add gmana
```

Manual `pubspec.yaml` setup:

```yaml
dependencies:
  gmana: ^0.2.0
  gmana_flutter_extensions: ^0.0.1
  gmana_form: ^0.0.1
  gmana_flutter: ^0.0.8
  gmana_spinner: ^0.0.1
```

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
            const SizedBoxHeight(),
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
| Widgets    | `GAppBar`, `GListTile`, `SizedBoxHeight`, `GStarRatingBar`                                                 |
| Forms      | `GEmailField`, `GPasswordField`, `GNumberField`, `GTextField`, `GConfirmPasswordField`, `GElevatedButton`  |
| Loading    | `GCircularSpinner`, `GLinearSpinner`, `GDotSpinner`, `GWaveSpinner`, `GWaveDotSpinner`                     |
| Theme      | `GColors`, `GFontWeight`, plus re-exported `ThemeModeExt`, `ThemeModeService`                              |
| Extensions | Re-exported `ColorExt`, `StringColorExtension`, `BreakpointUtils`, `ResponsiveContext`, `ContextExt`       |
| Utilities  | Re-exported `IconDataExt`, `IconDataSerialization`, plus `fromLocale`, `toLocale`, `registerErrorHandlers` |

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

// ThemeModeService — all methods are static
ThemeModeService.fromKey('light');                                        // ThemeMode.light
ThemeModeService.getThemeKeys();                                          // ['system', 'light', 'dark']
ThemeModeService.getThemeKeys().map(ThemeModeService.getLabelFromKey).toList(); // ['System Mode', 'Light Mode', 'Dark Mode']
```

## Forms

The field widgets wrap `TextFormField` with consistent defaults and validators
from the core `gmana` package.

New code can import `package:gmana_form/gmana_form.dart` directly. The same
APIs remain available through `gmana_flutter` for compatibility.

```dart
import 'package:flutter/material.dart';
import 'package:gmana/validation.dart';
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
            labelText: 'Email',
          ),
          const SizedBoxHeight(),
          GPasswordField(
            controller: passwordController,
            validationConfig: PasswordValidationConfig.strong(),
          ),
          const SizedBoxHeight(),
          GConfirmPasswordField(
            controller: confirmPasswordController,
            passwordController: passwordController,
          ),
          const SizedBoxHeight(spacing: 24),
          GElevatedButton(
            text: 'Create account',
            isLoading: false,
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
  config: GFieldConfig(
    controller: controller,
    labelText: 'Display name',
    hintText: 'Enter your name',
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
const SizedBoxHeight(spacing: GSpacing.md);
const SizedBoxWidth(spacing: GSpacing.lg);
GSpacing.vSpace(GSpacing.sm);
GSpacing.hSpace(GSpacing.sm);
```

Use `GWaveSpinner` with explicit bounds:

```dart
const SizedBox(
  width: 48,
  height: 48,
  child: GWaveSpinner(color: GColors.primary),
);
```

`GElevatedButton` can show a spinner while work is running:

```dart
GElevatedButton(
  text: 'Save',
  isLoading: saving,
  onPressed: saving ? null : save,
);
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
final optionalColor = ColorService.tryParseHex('#80F57224');
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

## Snackbars, Navigation, And Dialogs

`ContextExt` gives short helpers for common app actions:

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
final icon = IconDataExt.tryParse(json) ?? Icons.broken_image;
```

Use a fallback when parsing required values:

```dart
final icon = IconDataExt.parse(
  savedIconJson,
  fallback: Icons.help_outline,
);
```

## Locale Helpers

Convert between `Locale` and underscore-separated locale tags:

```dart
final tag = fromLocale(const Locale('en', 'US')); // 'en_US'
final locale = toLocale('km_KH'); // Locale('km', 'KH')
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

The example demonstrates theme switching, color utilities, layout polish, and
the package's UI components.
