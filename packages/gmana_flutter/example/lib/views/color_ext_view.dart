import 'package:flutter/material.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

import 'color_lab/color_lab_widgets.dart';
import 'color_lab/controls_panel.dart';
import 'color_lab/preview_panel.dart';
import 'color_lab/stats_panel.dart';
import 'color_lab/tone_mode.dart';

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
  ToneMode _toneMode = ToneMode.lighten;

  Color get _baseColor => _baseColors[_selectedColorKey]!;

  Color get _adjustedColor {
    final transformed =
        _toneMode == ToneMode.lighten
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
            child: BackgroundGlow(
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
                      _ContentLayout(
                        isWide: isWide,
                        previewPanel: PreviewPanel(
                          adjustedColor: adjustedColor,
                          baseColor: _baseColor,
                          contrastText: contrastText,
                          complementary: complementary,
                          analogous: analogous,
                          splitComplementary: (splitA, splitB),
                          triadic: (triadA, triadB),
                        ),
                        controlsPanel: ControlsPanel(
                          selectedColorKey: _selectedColorKey,
                          colors: _baseColors,
                          lightnessAmount: _lightnessAmount,
                          opacity: _opacity,
                          toneMode: _toneMode,
                          onColorChanged:
                              (v) => setState(() => _selectedColorKey = v),
                          onLightnessChanged:
                              (v) => setState(() => _lightnessAmount = v),
                          onOpacityChanged: (v) => setState(() => _opacity = v),
                          onToneModeChanged:
                              (v) => setState(() => _toneMode = v),
                        ),
                      ),
                      const SizedBox(height: 18),
                      StatsPanel(
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

class _ContentLayout extends StatelessWidget {
  const _ContentLayout({
    required this.isWide,
    required this.previewPanel,
    required this.controlsPanel,
  });

  final bool isWide;
  final Widget previewPanel;
  final Widget controlsPanel;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: previewPanel),
          const SizedBox(width: 18),
          Expanded(flex: 3, child: controlsPanel),
        ],
      );
    }

    return Column(
      children: [previewPanel, const SizedBox(height: 16), controlsPanel],
    );
  }
}
