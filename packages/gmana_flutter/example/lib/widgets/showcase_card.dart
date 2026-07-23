import 'package:flutter/material.dart';

class ShowcaseCard extends StatelessWidget {
  const ShowcaseCard({
    super.key,
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
