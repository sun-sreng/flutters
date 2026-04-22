import 'package:flutter/material.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

class ColorExtensionLabPage extends StatefulWidget {
  const ColorExtensionLabPage({super.key});

  @override
  State<ColorExtensionLabPage> createState() => _ColorExtensionLabPageState();
}

class _ColorExtensionLabPageState extends State<ColorExtensionLabPage> {
  static const _baseColors = <String, Color>{
    'Tangerine': Color(0xFFF57224),
    'Ocean': Color(0xFF1565C0),
    'Forest': Color(0xFF2E7D32),
    'Mulberry': Color(0xFF7B1FA2),
    'Slate': Color(0xFF455A64),
  };

  String _selectedColorKey = 'Tangerine';
  double _lightnessAmount = 0.18;
  double _opacity = 1.0;
  _ToneMode _toneMode = _ToneMode.lighten;

  Color get _baseColor => _baseColors[_selectedColorKey]!;

  Color get _adjustedColor {
    final transformed =
        _toneMode == _ToneMode.lighten
            ? _baseColor.lighten(_lightnessAmount)
            : _baseColor.darken(_lightnessAmount);
    return transformed.withAlphaOpacity(_opacity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final adjustedColor = _adjustedColor;
    final complementary = adjustedColor.complementary;
    final (splitA, splitB) = adjustedColor.splitComplementary;
    final (triadA, triadB) = adjustedColor.triadic;
    final analogous = adjustedColor.analogous(count: 2);
    final contrastText = adjustedColor.contrastText;
    final contrastRatio = adjustedColor.contrastRatio(contrastText);

    return Scaffold(
      appBar: const GAppBar(title: 'Color Extension Lab'),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _BackgroundGlow(
              color: adjustedColor.withAlpha(90),
              size: 220,
            ),
          ),
          SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 960;
                final horizontalPadding =
                    constraints.maxWidth >= 1100
                        ? 40.0
                        : constraints.maxWidth >= 720
                        ? 28.0
                        : 18.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inspect color transformations with a cleaner working surface.',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Change the source color, shift lightness, and review contrast and harmony outputs immediately.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _PreviewPanel(
                                adjustedColor: adjustedColor,
                                baseColor: _baseColor,
                                contrastText: contrastText,
                                complementary: complementary,
                                analogous: analogous,
                                splitComplementary: (splitA, splitB),
                                triadic: (triadA, triadB),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 3,
                              child: _ControlsPanel(
                                selectedColorKey: _selectedColorKey,
                                colors: _baseColors,
                                lightnessAmount: _lightnessAmount,
                                opacity: _opacity,
                                toneMode: _toneMode,
                                onColorChanged: (value) {
                                  setState(() {
                                    _selectedColorKey = value;
                                  });
                                },
                                onLightnessChanged: (value) {
                                  setState(() {
                                    _lightnessAmount = value;
                                  });
                                },
                                onOpacityChanged: (value) {
                                  setState(() {
                                    _opacity = value;
                                  });
                                },
                                onToneModeChanged: (value) {
                                  setState(() {
                                    _toneMode = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _PreviewPanel(
                              adjustedColor: adjustedColor,
                              baseColor: _baseColor,
                              contrastText: contrastText,
                              complementary: complementary,
                              analogous: analogous,
                              splitComplementary: (splitA, splitB),
                              triadic: (triadA, triadB),
                            ),
                            const SizedBox(height: 16),
                            _ControlsPanel(
                              selectedColorKey: _selectedColorKey,
                              colors: _baseColors,
                              lightnessAmount: _lightnessAmount,
                              opacity: _opacity,
                              toneMode: _toneMode,
                              onColorChanged: (value) {
                                setState(() {
                                  _selectedColorKey = value;
                                });
                              },
                              onLightnessChanged: (value) {
                                setState(() {
                                  _lightnessAmount = value;
                                });
                              },
                              onOpacityChanged: (value) {
                                setState(() {
                                  _opacity = value;
                                });
                              },
                              onToneModeChanged: (value) {
                                setState(() {
                                  _toneMode = value;
                                });
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 18),
                      _StatsPanel(
                        adjustedColor: adjustedColor,
                        contrastText: contrastText,
                        contrastRatio: contrastRatio,
                        opacity: _opacity,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.adjustedColor,
    required this.baseColor,
    required this.contrastText,
    required this.complementary,
    required this.analogous,
    required this.splitComplementary,
    required this.triadic,
  });

  final Color adjustedColor;
  final Color baseColor;
  final Color contrastText;
  final Color complementary;
  final List<Color> analogous;
  final (Color, Color) splitComplementary;
  final (Color, Color) triadic;

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
                _PaletteChip(label: 'Base', color: baseColor),
                _PaletteChip(label: 'Adjusted', color: adjustedColor),
                _PaletteChip(label: 'Complementary', color: complementary),
                _PaletteChip(label: 'Split A', color: splitComplementary.$1),
                _PaletteChip(label: 'Split B', color: splitComplementary.$2),
                _PaletteChip(label: 'Triad A', color: triadic.$1),
                _PaletteChip(label: 'Triad B', color: triadic.$2),
                for (var i = 0; i < analogous.length; i++)
                  _PaletteChip(label: 'Analog ${i + 1}', color: analogous[i]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
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
  final _ToneMode toneMode;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<double> onLightnessChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<_ToneMode> onToneModeChanged;

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
                if (value != null) {
                  onColorChanged(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Text('Transformation', style: theme.textTheme.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children:
                  _ToneMode.values.map((mode) {
                    final isSelected = mode == toneMode;
                    return ChoiceChip(
                      label: Text(mode.label),
                      selected: isSelected,
                      onSelected: (_) => onToneModeChanged(mode),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            _SliderField(
              title: 'Lightness shift',
              valueLabel: lightnessAmount.toStringAsFixed(2),
              value: lightnessAmount,
              onChanged: onLightnessChanged,
            ),
            const SizedBox(height: 16),
            _SliderField(
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

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.adjustedColor,
    required this.contrastText,
    required this.contrastRatio,
    required this.opacity,
  });

  final Color adjustedColor;
  final Color contrastText;
  final double contrastRatio;
  final double opacity;

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
            _StatTile(label: 'RGB', value: adjustedColor.toHexRGB()),
            _StatTile(label: 'ARGB', value: adjustedColor.toHexARGB()),
            _StatTile(
              label: 'Contrast',
              value: contrastRatio.toStringAsFixed(2),
            ),
            _StatTile(label: 'Text', value: contrastText.toHexRGB()),
            _StatTile(label: 'Opacity', value: opacity.toStringAsFixed(2)),
            _StatTile(label: 'AA', value: passesAA ? 'Pass' : 'Fail'),
            _StatTile(label: 'AAA', value: passesAAA ? 'Pass' : 'Fail'),
          ],
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String valueLabel;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
            Text(valueLabel, style: theme.textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0,
          max: 1,
          divisions: 100,
        ),
      ],
    );
  }
}

class _PaletteChip extends StatelessWidget {
  const _PaletteChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(color.toHexRGB(), style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withAlpha(8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withAlpha(0)]),
        ),
      ),
    );
  }
}

enum _ToneMode {
  lighten('Lighten'),
  darken('Darken');

  const _ToneMode(this.label);

  final String label;
}
