// Passthrough widget mirroring Flutter AppBar props.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class GAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Custom title widget. Takes precedence over [title] when supplied.
  final Widget? titleWidget;

  /// Whether to synthesize a back button when [leading] is null.
  ///
  /// Leave this on for pushed routes; turn it off on tab roots, where the
  /// default back arrow would pop nothing.
  final bool showBackButton;

  /// Optional widget below the toolbar, e.g. a `TabBar`. Its height is
  /// included in [preferredSize].
  final PreferredSizeWidget? bottom;

  /// Scroll-independent elevation passthrough.
  final double? elevation;

  /// Toolbar height override.
  final double? toolbarHeight;

  const GAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.actions,
    this.leading,
    this.onLeadingPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.titleWidget,
    this.showBackButton = true,
    this.bottom,
    this.elevation,
    this.toolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? Text(title),
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBackButton,
      leading:
          leading ??
          (showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    onLeadingPressed ?? () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              )
              : null),
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      bottom: bottom,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
    );
  }
}
