import 'package:gmana_flutter/gmana_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'color_lab_widgets.dart';

class StatsPanel extends StatelessWidget {
  final Color adjustedColor;

  final Color contrastText;
  final double contrastRatio;
  final double opacity;
  const StatsPanel({
    super.key,
    required this.adjustedColor,
    required this.contrastText,
    required this.contrastRatio,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final passesAA = contrastText.meetsWcagAA(adjustedColor);
    final passesAAA = contrastText.meetsWcagAAA(adjustedColor);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            StatTile(label: 'RGB', value: adjustedColor.toHexRGB()),
            StatTile(label: 'ARGB', value: adjustedColor.toHexARGB()),
            StatTile(
              label: 'Contrast',
              value: contrastRatio.toStringAsFixed(2),
            ),
            StatTile(label: 'Text', value: contrastText.toHexRGB()),
            StatTile(label: 'Opacity', value: opacity.toStringAsFixed(2)),
            StatTile(label: 'AA', value: passesAA ? 'Pass' : 'Fail'),
            StatTile(label: 'AAA', value: passesAAA ? 'Pass' : 'Fail'),
          ],
        ),
      ),
    );
  }
}
