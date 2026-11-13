import 'package:gmana_flutter/gmana_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'color_lab_widgets.dart';

class PreviewPanel extends StatelessWidget {
  final Color adjustedColor;

  final Color baseColor;
  final Color contrastText;
  final Color complementary;
  final List<Color> analogous;
  final (Color, Color) splitComplementary;
  final (Color, Color) triadic;
  const PreviewPanel({
    super.key,
    required this.adjustedColor,
    required this.baseColor,
    required this.contrastText,
    required this.complementary,
    required this.analogous,
    required this.splitComplementary,
    required this.triadic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: adjustedColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live preview',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: contrastText.withAlpha(220),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    adjustedColor.toHexRGB(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: contrastText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Recommended text color: ${contrastText.toHexRGB()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: contrastText.withAlpha(220),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Palette relationships', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'The adjusted swatch is shown alongside common harmony calculations from the extension helpers.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PaletteChip(label: 'Base', color: baseColor),
                PaletteChip(label: 'Adjusted', color: adjustedColor),
                PaletteChip(label: 'Complementary', color: complementary),
                PaletteChip(label: 'Split A', color: splitComplementary.$1),
                PaletteChip(label: 'Split B', color: splitComplementary.$2),
                PaletteChip(label: 'Triad A', color: triadic.$1),
                PaletteChip(label: 'Triad B', color: triadic.$2),
                for (var i = 0; i < analogous.length; i++)
                  PaletteChip(label: 'Analog ${i + 1}', color: analogous[i]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
