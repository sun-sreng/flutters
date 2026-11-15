import 'package:gmana_flutter/gmana_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'demos/extensions_demo.dart';
import 'demos/form_demo.dart';
import 'demos/spinner_demo.dart';
import 'theme/showcase_theme.dart';
import 'views/color_ext_view.dart';
import 'widgets/benefit_tile.dart';
import 'widgets/glow_orb.dart';
import 'widgets/hero_panel.dart';
import 'widgets/section_label.dart';
import 'widgets/showcase_card.dart';
import 'widgets/signal_panel.dart';
import 'widgets/top_bar.dart';

void main() {
  runApp(const ThemeModeExampleApp());
}

class ThemeModeExampleApp extends StatefulWidget {
  const ThemeModeExampleApp({super.key});

  @override
  State<ThemeModeExampleApp> createState() => _ThemeModeExampleAppState();
}

class _ThemeModeExampleAppState extends State<ThemeModeExampleApp> {
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gmana Flutter Showcase',
      theme: buildShowcaseTheme(Brightness.light),
      darkTheme: buildShowcaseTheme(Brightness.dark),
      themeMode: _currentThemeMode,
      home: ThemeModeHomePage(
        currentThemeMode: _currentThemeMode,
        onThemeChanged: _updateThemeMode,
      ),
    );
  }

  void _updateThemeMode(ThemeMode newMode) {
    setState(() {
      _currentThemeMode = newMode;
    });
  }
}

class ThemeModeHomePage extends StatelessWidget {
  const ThemeModeHomePage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -40,
            child: GlowOrb(color: colorScheme.primary.withAlpha(70), size: 260),
          ),
          Positioned(
            top: 280,
            left: -70,
            child: GlowOrb(
              color: colorScheme.secondary.withAlpha(40),
              size: 220,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 920;
                final horizontalPadding =
                    constraints.maxWidth >= 1100
                        ? 48.0
                        : constraints.maxWidth >= 720
                        ? 32.0
                        : 20.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShowcaseTopBar(
                        currentThemeMode: currentThemeMode,
                        onThemeChanged: onThemeChanged,
                      ),
                      const SizedBox(height: 24),
                      _HeroSignalRow(
                        isWide: isWide,
                        currentThemeMode: currentThemeMode,
                        onOpenColorLab: () => _openColorLab(context),
                      ),
                      const SizedBox(height: 28),
                      SectionLabel(
                        eyebrow: 'Examples',
                        title: 'A cleaner way to present the package surface.',
                        subtitle:
                            'The demo now reads like a product showcase instead of a widget sandbox.',
                      ),
                      const SizedBox(height: 16),
                      _ShowcaseCards(
                        isWide: isWide,
                        constraints: constraints,
                        horizontalPadding: horizontalPadding,
                        currentThemeMode: currentThemeMode,
                        onOpenColorLab: () => _openColorLab(context),
                      ),
                      const SizedBox(height: 28),
                      SectionLabel(
                        eyebrow: 'What Changed',
                        title: 'Sharper presentation, same package APIs.',
                        subtitle:
                            'This example emphasizes design clarity, information hierarchy, and stronger demo quality.',
                      ),
                      const SizedBox(height: 16),
                      const Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          BenefitTile(
                            icon: Icons.grid_view_rounded,
                            title: 'Structured Layout',
                            description:
                                'Clear sections, consistent spacing, and responsive grouping.',
                          ),
                          BenefitTile(
                            icon: Icons.visibility_rounded,
                            title: 'Better Demo Value',
                            description:
                                'Each screen now teaches the package instead of just exposing controls.',
                          ),
                          BenefitTile(
                            icon: Icons.brush_outlined,
                            title: 'Professional Finish',
                            description:
                                'Improved theme polish, card styling, and readable visual rhythm.',
                          ),
                        ],
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

  void _openColorLab(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ColorExtensionLabPage()),
    );
  }
}

class _HeroSignalRow extends StatelessWidget {
  const _HeroSignalRow({
    required this.isWide,
    required this.currentThemeMode,
    required this.onOpenColorLab,
  });

  final bool isWide;
  final ThemeMode currentThemeMode;
  final VoidCallback onOpenColorLab;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: HeroPanel(
              currentThemeMode: currentThemeMode,
              onExploreColorLab: onOpenColorLab,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(flex: 2, child: SignalPanel()),
        ],
      );
    }

    return Column(
      children: [
        HeroPanel(
          currentThemeMode: currentThemeMode,
          onExploreColorLab: onOpenColorLab,
        ),
        const SizedBox(height: 16),
        const SignalPanel(),
      ],
    );
  }
}

class _ShowcaseCards extends StatelessWidget {
  const _ShowcaseCards({
    required this.isWide,
    required this.constraints,
    required this.horizontalPadding,
    required this.currentThemeMode,
    required this.onOpenColorLab,
  });

  final bool isWide;
  final BoxConstraints constraints;
  final double horizontalPadding;
  final ThemeMode currentThemeMode;
  final VoidCallback onOpenColorLab;

  double get _cardWidth =>
      isWide
          ? (constraints.maxWidth - horizontalPadding * 2 - 16) / 2
          : double.infinity;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ShowcaseCard(
          width: _cardWidth,
          icon: currentThemeMode.toIcon(),
          title: 'Flutter Extensions',
          description:
              'Breakpoints, responsive values, color math, time formatting, icon codecs, and snackbar helpers.',
          metrics: const ['Responsive', 'Color', 'Theme mode'],
          actionLabel: 'Open extensions',
          onPressed:
              () => _push(
                context,
                ExtensionsDemoPage(themeMode: currentThemeMode),
              ),
        ),
        ShowcaseCard(
          width: _cardWidth,
          icon: Icons.edit_note_rounded,
          title: 'Form Fields',
          description:
              'Text, email, number, password, and confirm-password fields wired to typed gmana validators.',
          metrics: const ['Validation', 'GForm', 'Submit'],
          actionLabel: 'Open form demo',
          onPressed: () => _push(context, const ExampleFormPage()),
        ),
        ShowcaseCard(
          width: _cardWidth,
          icon: Icons.autorenew_rounded,
          title: 'Loading Spinners',
          description:
              'Every animated spinner in one gallery, plus the blocking loading overlay.',
          metrics: const ['Animated', 'Overlay', 'Themed'],
          actionLabel: 'Open spinner gallery',
          onPressed: () => _push(context, const SpinnerGalleryPage()),
        ),
        ShowcaseCard(
          width: _cardWidth,
          icon: Icons.palette_outlined,
          title: 'Color Extension Lab',
          description:
              'Explore transformed colors, contrast output, and palette relationships in one place.',
          metrics: const ['Contrast', 'Harmony', 'Swatches'],
          actionLabel: 'Open color lab',
          onPressed: onOpenColorLab,
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
