// Passthrough widget mirroring Flutter ListTile props.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class GListTile extends StatelessWidget {
  final IconData icon;
  final void Function()? onTap;
  final String title;
  final String label;

  /// Optional secondary line below [title].
  final String? subtitle;

  /// Replaces the default `label + chevron` trailing area entirely.
  final Widget? trailing;

  /// Whether to draw the trailing chevron. Ignored when [trailing] is set.
  final bool showChevron;

  /// Whether the tile responds to input.
  final bool enabled;

  /// Whether the tile renders in its selected state.
  final bool selected;

  /// Leading icon color override.
  final Color? iconColor;

  /// Content padding passthrough.
  final EdgeInsetsGeometry? contentPadding;

  const GListTile({
    super.key,
    required this.icon,
    required this.title,
    this.label = '',
    this.onTap,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
    this.enabled = true,
    this.selected = false,
    this.iconColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      selected: selected,
      contentPadding: contentPadding,
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ?? _defaultTrailing(context),
    );
  }

  Widget? _defaultTrailing(BuildContext context) {
    final hasLabel = label.isNotEmpty;
    if (!hasLabel && !showChevron) return null;

    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLabel)
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          if (showChevron) const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}
