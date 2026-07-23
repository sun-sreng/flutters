import 'package:flutter/material.dart';

import 'color_lab_widgets.dart';
import 'tone_mode.dart';

class ControlsPanel extends StatelessWidget {
  const ControlsPanel({
    super.key,
    required this.selectedColorKey,
    required this.colors,
    required this.lightnessAmount,
    required this.opacity,
    required this.toneMode,
    required this.onColorChanged,
    required this.onLightnessChanged,
    required this.onOpacityChanged,
    required this.onToneModeChanged,
  });

  final String selectedColorKey;
  final Map<String, Color> colors;
  final double lightnessAmount;
  final double opacity;
  final ToneMode toneMode;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<double> onLightnessChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<ToneMode> onToneModeChanged;

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
            Text('Controls', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Use the package extension methods to manipulate the current swatch.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            Text('Base color', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedColorKey,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
              ),
              items:
                  colors.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: entry.value,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(entry.key),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) onColorChanged(value);
              },
            ),
            const SizedBox(height: 20),
            Text('Transformation', style: theme.textTheme.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children:
                  ToneMode.values.map((mode) {
                    return ChoiceChip(
                      label: Text(mode.label),
                      selected: mode == toneMode,
                      onSelected: (_) => onToneModeChanged(mode),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            SliderField(
              title: 'Lightness shift',
              valueLabel: lightnessAmount.toStringAsFixed(2),
              value: lightnessAmount,
              onChanged: onLightnessChanged,
            ),
            const SizedBox(height: 16),
            SliderField(
              title: 'Opacity',
              valueLabel: '${(opacity * 100).round()}%',
              value: opacity,
              onChanged: onOpacityChanged,
            ),
          ],
        ),
      ),
    );
  }
}
