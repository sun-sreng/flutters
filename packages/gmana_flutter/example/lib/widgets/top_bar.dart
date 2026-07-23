import 'package:flutter/material.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

class ShowcaseTopBar extends StatelessWidget {
  const ShowcaseTopBar({
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
