# gmana_flutter

<p align="center">
  A comprehensive Flutter utility package designed to accelerate UI development and enforce consistency across applications. 
</p>

---

> **Note:** This package is built specifically for **Flutter**. For pure Dart functional programming utilities, validation logic, and extensions, please see the core [gmana](https://pub.dev/packages/gmana) package.

## 🚀 Installation

Add `gmana_flutter` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  gmana_flutter: ^0.0.7 # Please check pub.dev for the latest version
```

Or install it via CLI:

```bash
flutter pub add gmana_flutter
```

---

## 🎨 Features Overview

`gmana_flutter` provides branded `G*` widgets, customized form helpers, theme management logic, and UI-aware extensions to speed up development.

- [**Custom Widgets**](#custom-widgets) (`SizedBoxHeight`, `StarRatingBar`, `GAppBar`)
- [**Form Fields & Buttons**](#form-controls) (`GEmailField`, `GPasswordField`, `GElevatedButton`)
- [**Loading Spinners**](#loading-spinners) (`GCircularSpinner`, `GSpinnerDot`, `GSpinnerWaveDot`)
- [**Theme & Color Services**](#services--extensions) (`ThemeModeService`, `ColorService`)
- [**Flutter Extensions**](#services--extensions) (`ColorExt`, `ThemeModeExt`)

---

## 🧩 Custom Widgets

Standardized UI components built for reusability.

```dart
import 'package:gmana_flutter/gmana_flutter.dart';

// GAppBar avoids boilerplate and centers titles beautifully
Scaffold(
  appBar: GAppBar(
    title: 'Profile',
    centerTitle: true,
  ),
  body: Column(
    children: [
      // Standardize your vertical spacing (uses design system tokens)
      const SizedBoxHeight(spacing: 24.0),

      // Feature-rich star rating bars
      StarRatingBar(
        ratingValue: 4.5,
        starSize: 20.0,
        enableHalfStar: true,
      ),
    ],
  )
)
```

---

## 📝 Form Controls

Ready-to-use form fields that wrap robust validation out of the box (when paired with `gmana`'s text validators).

```dart
Column(
  children: [
    GEmailField(
      controller: emailController,
      labelText: 'Email Address',
      onChanged: (val) => print(val),
    ),
    const SizedBoxHeight(),
    GPasswordField(
      controller: passwordController,
      onChanged: (val) => print(val),
    ),
    const SizedBoxHeight(),
    GElevatedButton(
      isLoading: false,
      onPressed: () => submitForm(),
      text: 'Submit',
    ),
  ],
)
```

---

## ⏳ Loading Spinners

Ditch raw Material loaders for stylized, branded loading indicators.

```dart
// Easily throw in pre-built spinners across your app
const GCircularSpinner();
const GSpinnerDot(color: Colors.blue);
const GLinearSpinner();
const GSpinnerWaveDot(size: 24, color: Colors.blue);
```

---

## 🛠 Services & Extensions

### Colors & Contrast Engine

Ensure your text is always readable over dynamic background colors!

```dart
final primaryColor = Color(0xFF0055FF);

print(primaryColor.isDark); // true
print(primaryColor.toHex()); // "#0055FF"

// Automatically returns white/black depending on what's safe
final safeTextColor = primaryColor.contrastText;

// Easily lighten/darken UI elements
final hoverColor = primaryColor.lighten(0.1);
final activeColor = primaryColor.darken(0.2);
```

### Theme Mode Management

Provides strongly typed `ThemeMode` parsers and human-readable tags for your Settings pages.

```dart
// Convert ThemeModes to Icons or Strings easily
ThemeMode.dark.toIcon(); // Icons.dark_mode
ThemeMode.dark.toLabel(); // "Dark Mode"

// Convert from strings (useful when reading from SharedPreferences/SecureStorage)
'light'.toThemeMode(); // ThemeMode.light
'system'.toThemeIcon(); // Icons.brightness_6
```

---

## 🎯 Putting it all together

```dart
import 'package:flutter/material.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gmana_flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: 'system'.toThemeMode(), // Handled elegantly by gmana_flutter
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GAppBar(title: 'Welcome'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GSpinnerWaveDot(size: 24, color: Colors.blue),
            const SizedBoxHeight(),
            Text('Processing Theme Settings...',
              style: TextStyle(
                // Auto-contrast!
                color: Theme.of(context).primaryColor.contrastText
              )
            ),
          ],
        ),
      ),
    );
  }
}
```

```dart
Duration(hours: 1, minutes: 3, seconds: 7).toClockString()      // "1:03:07"
Duration(minutes: 4, seconds: 2).toClockString()                // "4:02"
Duration(hours: 2, minutes: 3).toHumanizedString()              // "2 hours 3 minutes"
Duration(seconds: 45).toHumanizedString()                       // "45 seconds"
Duration(minutes: 5).toRelativeString()                         // "in 5 minutes"
Duration(minutes: -3).toRelativeString()                        // "3 minutes ago"
Duration(seconds: 3).toRelativeString()                         // "just now"
Duration(hours: 2, minutes: 3).toCompactString()                // "2h 3m"
Duration(minutes: 1, milliseconds: 500).toVerboseString()       // "1m 0s 500ms"
```

```dart
// Serialize
final json = Icons.home.toJsonString();

// Parse — null-safe, caller decides fallback
final icon = IconDataExt.tryParse(json);             // IconData?
final icon = IconDataExt.parse(json);                // Icons.question_mark on failure
final icon = IconDataExt.parse(json, fallback: Icons.error); // custom fallback

// In a widget
Icon(IconDataExt.tryParse(storedString) ?? Icons.broken_image)
```
