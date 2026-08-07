import 'package:flutter/material.dart';

/// Responsive builder widget that renders different layouts for mobile, tablet, and desktop screens.
class GResponsiveBuilder extends StatelessWidget {
  /// Builder for mobile layout (< [mobileBreakpoint]).
  final Widget Function(BuildContext context) mobile;

  /// Builder for tablet layout ([mobileBreakpoint] <= width < [tabletBreakpoint]).
  final Widget Function(BuildContext context)? tablet;

  /// Builder for desktop layout (>= [tabletBreakpoint]).
  final Widget Function(BuildContext context)? desktop;

  /// Breakpoint threshold between mobile and tablet layout (default: 600).
  final double mobileBreakpoint;

  /// Breakpoint threshold between tablet and desktop layout (default: 1024).
  final double tabletBreakpoint;

  /// Creates a [GResponsiveBuilder].
  const GResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = 600.0,
    this.tabletBreakpoint = 1024.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= tabletBreakpoint && desktop != null) {
          return desktop!(context);
        }

        if (width >= mobileBreakpoint && tablet != null) {
          return tablet!(context);
        }

        return mobile(context);
      },
    );
  }
}
