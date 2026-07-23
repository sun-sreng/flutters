// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

class DetailRow extends StatelessWidget {
  final String label;

  final String value;
  const DetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: context.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class DetailsPanel extends StatelessWidget {
  final Color baseColor;

  final IconData restoredIcon;
  const DetailsPanel({
    super.key,
    required this.baseColor,
    required this.restoredIcon,
  });

  @override
  Widget build(BuildContext context) {
    final contrastRatio = baseColor.contrastRatio(Colors.white);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Utilities', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            DetailRow('RGB hex', baseColor.toHexRGB()),
            DetailRow('ARGB hex', baseColor.toHexARGB()),
            DetailRow(
              'Meets WCAG AA on white',
              '${baseColor.meetsWcagAA(Colors.white)}',
            ),
            DetailRow(
              'Contrast ratio on white',
              contrastRatio.toStringAsFixed(2),
            ),
            DetailRow('Theme key', 'dark'.toThemeMode().toLabel()),
            Row(
              children: [
                const Text('Restored icon'),
                const SizedBox(width: 12),
                Icon(restoredIcon),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
