import 'package:material_ui/material_ui.dart';

import 'metric_tile.dart';

class SignalPanel extends StatelessWidget {
  const SignalPanel({super.key});

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
                MetricTile(value: '3', label: 'theme modes'),
                MetricTile(value: '6+', label: 'showcase blocks'),
                MetricTile(value: 'AA', label: 'contrast focus'),
                MetricTile(value: 'M3', label: 'visual system'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
