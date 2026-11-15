// ignore_for_file: public_member_api_docs

import 'package:gmana_flutter/gmana_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'extensions_widgets/color_card.dart';
import 'extensions_widgets/details_panel.dart';
import 'extensions_widgets/info_chip.dart';

/// Flutter extension demos: breakpoints, colors, time, icons, and snackbars.
///
/// The theme mode is owned by the showcase app, so this page only reports it.
class ExtensionsDemoPage extends StatelessWidget {
  const ExtensionsDemoPage({super.key, required this.themeMode});

  final ThemeMode themeMode;

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
      appBar: AppBar(title: const Text('Flutter extensions')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.resolve(
            mobile: 1,
            tablet: 2,
            desktop: 3,
            widescreen: 4,
          );

          return ListView(
            padding: EdgeInsets.all(context.responsive(mobile: 16, tablet: 24)),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  InfoChip(
                    icon: Icons.devices,
                    label: constraints.breakpoint.name,
                  ),
                  InfoChip(
                    icon: Icons.aspect_ratio,
                    label:
                        '${context.screenWidth.round()} x '
                        '${context.screenHeight.round()}',
                  ),
                  InfoChip(
                    icon: Icons.schedule,
                    label:
                        const TimeOfDay(hour: 13, minute: 5).toCustomString(),
                  ),
                  InfoChip(
                    icon: themeMode.toIcon(),
                    label: themeMode.toLabel(),
                  ),
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
              DetailsPanel(
                baseColor: color,
                restoredIcon: IconDataCodec.parse(Icons.home.toJsonString()),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      context.showSuccessSnackBar(
                        message: 'Shown with BuildContext.showSuccessSnackBar',
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Success'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.showWarningSnackBar(
                        message: 'This uses the warning snackbar helper',
                      );
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
