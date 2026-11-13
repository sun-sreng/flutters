import 'package:material_ui/material_ui.dart';

class FeaturePill extends StatelessWidget {
  const FeaturePill({super.key, required this.label});

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
