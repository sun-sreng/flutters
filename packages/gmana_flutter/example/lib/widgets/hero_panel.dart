import 'package:gmana_flutter/gmana_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'feature_pill.dart';

class HeroPanel extends StatelessWidget {
  const HeroPanel({
    super.key,
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
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FeaturePill(label: 'Clean spacing'),
                FeaturePill(label: 'Reusable sections'),
                FeaturePill(label: 'Responsive layout'),
                FeaturePill(label: 'Polished theme'),
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
                    GStarRatingBar(ratingValue: 4.8, starSize: 18),
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
