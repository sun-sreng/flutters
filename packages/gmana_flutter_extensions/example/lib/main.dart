// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

import 'widgets/color_card.dart';
import 'widgets/details_panel.dart';
import 'widgets/info_chip.dart';

void main() {
  runApp(const ExtensionsExampleApp());
}

ThemeMode _nextThemeMode(ThemeMode current) {
  return switch (current) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  };
}

class ExampleHome extends StatelessWidget {
  final ThemeMode themeMode;

  final ValueChanged<ThemeMode> onThemeModeChanged;
  const ExampleHome({super.key, required this.themeMode, required this.onThemeModeChanged});

  @override
  Widget build(BuildContext context) {
    final color = '#FF5500'.toColor();
    final swatches = [
      (label: 'Base', color: color),
      (label: 'Tint', color: color.tint(0.35)),
      (label: 'Shade', color: color.shade(0.35)),
      (label: 'Complement', color: color.complementary),
      (label: 'Greyscale', color: color.greyscale),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('gmana_flutter_extensions'),
        actions: [
          IconButton(
            tooltip: themeMode.toLabel(),
            icon: Icon(themeMode.toIcon()),
            onPressed: () => onThemeModeChanged(_nextThemeMode(themeMode)),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.resolve(mobile: 1, tablet: 2, desktop: 3, widescreen: 4);

          return ListView(
            padding: EdgeInsets.all(context.responsive(mobile: 16, tablet: 24)),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  InfoChip(icon: Icons.devices, label: constraints.breakpoint.name),
                  InfoChip(
                    icon: Icons.aspect_ratio,
                    label:
                        '${context.screenWidth.round()} x '
                        '${context.screenHeight.round()}',
                  ),
                  InfoChip(icon: Icons.schedule, label: const TimeOfDay(hour: 13, minute: 5).toCustomString()),
                  InfoChip(icon: themeMode.toIcon(), label: themeMode.toLabel()),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.6,
                ),
                itemCount: swatches.length,
                itemBuilder: (context, index) {
                  final swatch = swatches[index];
                  return ColorCard(label: swatch.label, color: swatch.color);
                },
              ),
              const SizedBox(height: 24),
              DetailsPanel(baseColor: color, restoredIcon: IconDataExt.parse(Icons.home.toJsonString())),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      context.showSuccessSnackBar(message: 'Shown with BuildContext.showSuccessSnackBar');
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Success'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.showWarningSnackBar(message: 'This uses the warning snackbar helper');
                    },
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Warning'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExtensionsExampleApp extends StatefulWidget {
  const ExtensionsExampleApp({super.key});

  @override
  State<ExtensionsExampleApp> createState() => _ExtensionsExampleAppState();
}

class _ExtensionsExampleAppState extends State<ExtensionsExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: '#3B82F6'.toColor())),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: '#3B82F6'.toColor(), brightness: Brightness.dark),
      ),
      home: ExampleHome(themeMode: _themeMode, onThemeModeChanged: (mode) => setState(() => _themeMode = mode)),
    );
  }
}
