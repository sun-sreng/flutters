import 'package:flutter/material.dart';
import 'package:gmana/extensions.dart' show StringX;

import '../design_system/radius.dart';

/// A circular or rounded-square avatar with a graceful fallback chain.
///
/// Resolution order: [image] → initials derived from [name] → [fallbackIcon].
/// When no [backgroundColor] is given, a stable color is derived from [name]
/// so the same person keeps the same tint across sessions.
///
/// ```dart
/// GAvatar(name: 'Ada Lovelace');                       // 'AL' on a stable tint
/// GAvatar(image: NetworkImage(url), name: 'Ada');      // falls back if it fails
/// const GAvatar(fallbackIcon: Icons.group_outlined);   // no identity at all
/// ```
class GAvatar extends StatelessWidget {
  /// Optional image. Falls back to initials or [fallbackIcon] on error.
  final ImageProvider? image;

  /// Person or entity name used to derive initials and the default tint.
  final String? name;

  /// Icon shown when there is neither an [image] nor usable initials.
  final IconData fallbackIcon;

  /// Diameter (or side length when [square] is true).
  final double size;

  /// Background color override. Defaults to a stable tint derived from [name].
  final Color? backgroundColor;

  /// Foreground color override for initials and the fallback icon.
  final Color? foregroundColor;

  /// Renders a rounded square instead of a circle.
  final bool square;

  /// Corner radius used when [square] is true.
  final double borderRadius;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional small widget pinned to the bottom-trailing corner, typically a
  /// presence dot.
  final Widget? badge;

  /// Maximum number of initials to derive from [name].
  final int maxInitials;

  /// Creates an avatar.
  const GAvatar({
    super.key,
    this.image,
    this.name,
    this.fallbackIcon = Icons.person_outline,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.square = false,
    this.borderRadius = GRadius.md,
    this.onTap,
    this.badge,
    this.maxInitials = 2,
  });

  /// The palette candidate tints used when [backgroundColor] is omitted.
  static const List<Color> _palette = <Color>[
    Color(0xFFF57224),
    Color(0xFF00639B),
    Color(0xFF386A20),
    Color(0xFF7C5800),
    Color(0xFF8E4EC6),
    Color(0xFF0F766E),
    Color(0xFFBE3C10),
    Color(0xFF3F51B5),
  ];

  /// Picks a deterministic palette entry for [seed].
  ///
  /// Exposed so callers can tint related chrome to match an avatar.
  static Color tintFor(String? seed) {
    if (seed == null || seed.trim().isEmpty) return _palette.first;

    var hash = 0;
    for (final unit in seed.trim().toLowerCase().codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final initials = name?.initials(max: maxInitials) ?? '';
    final background = backgroundColor ?? tintFor(name);
    final foreground =
        foregroundColor ??
        (ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : Colors.black87);

    Widget content;
    if (image != null) {
      content = Image(
        image: image!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder:
            (context, _, _) => _placeholder(initials, foreground, background),
      );
    } else {
      content = _placeholder(initials, foreground, background);
    }

    final shape =
        square
            ? RoundedRectangleBorder(borderRadius: GRadius.all(borderRadius))
            : const CircleBorder();

    Widget avatar = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child:
            onTap == null
                ? content
                : InkWell(customBorder: shape, onTap: onTap, child: content),
      ),
    );

    if (badge != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          PositionedDirectional(bottom: 0, end: 0, child: badge!),
        ],
      );
    }

    return Semantics(
      label: name ?? 'Avatar',
      image: image != null,
      button: onTap != null,
      child: ExcludeSemantics(child: avatar),
    );
  }

  Widget _placeholder(String initials, Color foreground, Color background) {
    return ColoredBox(
      color: background,
      child: Center(
        child:
            initials.isEmpty
                ? Icon(fallbackIcon, size: size * 0.5, color: foreground)
                : Text(
                  initials,
                  style: TextStyle(
                    color: foreground,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
      ),
    );
  }
}
