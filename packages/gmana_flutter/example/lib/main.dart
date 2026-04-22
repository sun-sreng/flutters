import 'package:example/views/color_ext_view.dart';
import 'package:flutter/material.dart';
import 'package:gmana_flutter/design_system/colors.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

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
      theme: _buildShowcaseTheme(Brightness.light),
      darkTheme: _buildShowcaseTheme(Brightness.dark),
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

ThemeData _buildShowcaseTheme(Brightness brightness) {
  final baseTheme =
      brightness == Brightness.dark ? GColors.darkTheme : GColors.lightTheme;
  final colorScheme = baseTheme.colorScheme;
  final isDark = brightness == Brightness.dark;

  return baseTheme.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface.withAlpha(isDark ? 230 : 245),
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outline.withAlpha(60)),
      ),
    ),
    chipTheme: baseTheme.chipTheme.copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      side: BorderSide(color: colorScheme.outline.withAlpha(50)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline.withAlpha(90)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF101113) : const Color(0xFFF7F3EE),
    textTheme: baseTheme.textTheme.copyWith(
      displaySmall: baseTheme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
      headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.45),
    ),
  );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -40,
            child: _GlowOrb(
              color: colorScheme.primary.withAlpha(70),
              size: 260,
            ),
          ),
          Positioned(
            top: 280,
            left: -70,
            child: _GlowOrb(
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
                      _TopBar(
                        currentThemeMode: currentThemeMode,
                        onThemeChanged: onThemeChanged,
                      ),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _HeroPanel(
                                currentThemeMode: currentThemeMode,
                                onExploreColorLab: () => _openColorLab(context),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(flex: 2, child: _SignalPanel()),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _HeroPanel(
                              currentThemeMode: currentThemeMode,
                              onExploreColorLab: () => _openColorLab(context),
                            ),
                            const SizedBox(height: 16),
                            const _SignalPanel(),
                          ],
                        ),
                      const SizedBox(height: 28),
                      _SectionLabel(
                        eyebrow: 'Examples',
                        title: 'A cleaner way to present the package surface.',
                        subtitle:
                            'The demo now reads like a product showcase instead of a widget sandbox.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _ShowcaseCard(
                            width:
                                isWide
                                    ? (constraints.maxWidth -
                                            horizontalPadding * 2 -
                                            16) /
                                        2
                                    : double.infinity,
                            icon: currentThemeMode.toIcon(),
                            title: 'Theme Mode Controls',
                            description:
                                'Preview light, dark, and system behavior with a clearer hierarchy and cleaner controls.',
                            metrics: const [
                              'Material 3',
                              'Adaptive',
                              'Focused',
                            ],
                            actionLabel: 'Review theme modes',
                            onPressed: () {},
                          ),
                          _ShowcaseCard(
                            width:
                                isWide
                                    ? (constraints.maxWidth -
                                            horizontalPadding * 2 -
                                            16) /
                                        2
                                    : double.infinity,
                            icon: Icons.palette_outlined,
                            title: 'Color Extension Lab',
                            description:
                                'Explore transformed colors, contrast output, and palette relationships in one place.',
                            metrics: const ['Contrast', 'Harmony', 'Swatches'],
                            actionLabel: 'Open color lab',
                            onPressed: () => _openColorLab(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _SectionLabel(
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
                          _BenefitTile(
                            icon: Icons.grid_view_rounded,
                            title: 'Structured Layout',
                            description:
                                'Clear sections, consistent spacing, and responsive grouping.',
                          ),
                          _BenefitTile(
                            icon: Icons.visibility_rounded,
                            title: 'Better Demo Value',
                            description:
                                'Each screen now teaches the package instead of just exposing controls.',
                          ),
                          _BenefitTile(
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.currentThemeMode, required this.onThemeChanged});

  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      spacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [GColors.primary, GColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('gmana_flutter', style: theme.textTheme.titleLarge),
                Text('Package showcase', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.surface.withAlpha(220),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outline.withAlpha(60)),
          ),
          child: Wrap(
            spacing: 6,
            children:
                ThemeMode.values.map((mode) {
                  final isSelected = mode == currentThemeMode;
                  return ChoiceChip(
                    label: Text(mode.toLabel()),
                    avatar: Icon(mode.toIcon(), size: 18),
                    selected: isSelected,
                    onSelected: (_) => onThemeChanged(mode),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.currentThemeMode,
    required this.onExploreColorLab,
  });

  final ThemeMode currentThemeMode;
  final VoidCallback onExploreColorLab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              colorScheme.surface.withAlpha(240),
              colorScheme.primaryContainer.withAlpha(150),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withAlpha(15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Flutter UI utilities and extensions',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Professional demos make a package feel trustworthy.',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 14),
            Text(
              'This refreshed example uses the package more deliberately, presents features with stronger hierarchy, and makes the demo easier to navigate.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _FeaturePill(label: 'Clean spacing'),
                _FeaturePill(label: 'Reusable sections'),
                _FeaturePill(label: 'Responsive layout'),
                _FeaturePill(label: 'Polished theme'),
              ],
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onExploreColorLab,
                  icon: const Icon(Icons.palette_outlined),
                  label: const Text('Explore color lab'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(currentThemeMode.toIcon()),
                  label: Text(currentThemeMode.toLabel()),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    StarRatingBar(ratingValue: 4.8, starSize: 18),
                    SizedBox(width: 8),
                    Text('Demo polish'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalPanel extends StatelessWidget {
  const _SignalPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Package signal', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'A clean example communicates maturity faster than documentation alone.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricTile(value: '3', label: 'theme modes'),
                _MetricTile(value: '6+', label: 'showcase blocks'),
                _MetricTile(value: 'AA', label: 'contrast focus'),
                _MetricTile(value: 'M3', label: 'visual system'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 1.2,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.metrics,
    required this.actionLabel,
    required this.onPressed,
  });

  final double width;
  final IconData icon;
  final String title;
  final String description;
  final List<String> metrics;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    metrics
                        .map(
                          (metric) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withAlpha(12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(metric),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(height: 14),
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 120,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withAlpha(10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(190),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outline.withAlpha(45)),
      ),
      child: Text(label),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

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
