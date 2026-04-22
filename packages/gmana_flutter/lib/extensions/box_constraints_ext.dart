import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ── Semantic breakpoint enum ───────────────────────────────────────────────
enum Breakpoint {
  mobile,
  tablet,
  desktop,
  widescreen;

  /// True for desktop and above.
  bool get isAtLeastDesktop => index >= Breakpoint.desktop.index;

  /// True for tablet and above.
  bool get isAtLeastTablet => index >= Breakpoint.tablet.index;
  bool get isDesktop =>
      this == Breakpoint.desktop || this == Breakpoint.widescreen;
  bool get isMobile => this == Breakpoint.mobile;

  bool get isTablet => this == Breakpoint.tablet;

  bool get isWidescreen => this == Breakpoint.widescreen;

  T maybeWhen<T>({
    T Function()? mobile,
    T Function()? tablet,
    T Function()? desktop,
    T Function()? widescreen,
    required T Function() orElse,
  }) => switch (this) {
    Breakpoint.mobile => (mobile ?? orElse)(),
    Breakpoint.tablet => (tablet ?? orElse)(),
    Breakpoint.desktop => (desktop ?? orElse)(),
    Breakpoint.widescreen => (widescreen ?? orElse)(),
  };

  T when<T>({
    required T Function() mobile,
    required T Function() tablet,
    required T Function() desktop,
    T Function()? widescreen,
  }) => switch (this) {
    Breakpoint.mobile => mobile(),
    Breakpoint.tablet => tablet(),
    Breakpoint.desktop => desktop(),
    Breakpoint.widescreen => widescreen != null ? widescreen() : desktop(),
  };
}

// ── Breakpoint thresholds ──────────────────────────────────────────────────
abstract final class Breakpoints {
  static const double mobile = 0;
  static const double tablet = 730;
  static const double desktop = 1200;
  static const double widescreen = 1600;
}

// ── BoxConstraints extension ───────────────────────────────────────────────
extension BreakpointUtils on BoxConstraints {
  Breakpoint get breakpoint => switch (maxWidth) {
    < Breakpoints.tablet => Breakpoint.mobile,
    < Breakpoints.desktop => Breakpoint.tablet,
    < Breakpoints.widescreen => Breakpoint.desktop,
    _ => Breakpoint.widescreen,
  };
  bool get isAtLeastDesktop => maxWidth >= Breakpoints.desktop;
  // Cumulative guards — useful for "at least tablet" style conditions.
  bool get isAtLeastTablet => maxWidth >= Breakpoints.tablet;
  bool get isDesktop =>
      maxWidth >= Breakpoints.desktop && maxWidth < Breakpoints.widescreen;

  // Exclusive ranges — no overlap.
  bool get isMobile => maxWidth < Breakpoints.tablet;
  bool get isTablet =>
      maxWidth >= Breakpoints.tablet && maxWidth < Breakpoints.desktop;

  /// True when both axes are tightly constrained.
  bool get isTight => minWidth == maxWidth && minHeight == maxHeight;

  /// True when height is unbounded.
  bool get isUnboundedHeight => maxHeight == double.infinity;

  /// True when width is unbounded (e.g. inside a scrollable).
  bool get isUnboundedWidth => maxWidth == double.infinity;

  bool get isWidescreen => maxWidth >= Breakpoints.widescreen;

  /// Returns the largest tight [Size] that fits within these constraints.
  Size get largestSize => Size(maxWidth, maxHeight);

  /// Returns the smallest tight [Size] that satisfies these constraints.
  Size get smallestSize => Size(minWidth, minHeight);

  /// Adds symmetrical padding to the constraints.
  BoxConstraints deflate(EdgeInsets insets) => copyWith(
    maxWidth: (maxWidth - insets.horizontal).clamp(0.0, double.infinity),
    maxHeight: (maxHeight - insets.vertical).clamp(0.0, double.infinity),
  );

  /// Resolves a value per breakpoint. Falls back up the chain when a tier
  /// is omitted (mobile → tablet → desktop → widescreen).
  T resolve<T>({required T mobile, T? tablet, T? desktop, T? widescreen}) {
    final bp = breakpoint;
    return switch (bp) {
      Breakpoint.widescreen => widescreen ?? desktop ?? tablet ?? mobile,
      Breakpoint.desktop => desktop ?? tablet ?? mobile,
      Breakpoint.tablet => tablet ?? mobile,
      Breakpoint.mobile => mobile,
    };
  }

  /// Clamps constraints to [size], respecting existing min/max bounds.
  BoxConstraints tightenMaxSize(Size? size) {
    if (size == null) return this;
    return copyWith(
      maxWidth: clampDouble(size.width, minWidth, maxWidth),
      maxHeight: clampDouble(size.height, minHeight, maxHeight),
    );
  }
}

// ── BuildContext extension ─────────────────────────────────────────────────
extension ResponsiveContext on BuildContext {
  Breakpoint get breakpoint => switch (screenSize.width) {
    < Breakpoints.tablet => Breakpoint.mobile,
    < Breakpoints.desktop => Breakpoint.tablet,
    < Breakpoints.widescreen => Breakpoint.desktop,
    _ => Breakpoint.widescreen,
  };
  bool get isAtLeastDesktop => breakpoint.isAtLeastDesktop;

  bool get isAtLeastTablet => breakpoint.isAtLeastTablet;

  bool get isDesktop => breakpoint.isDesktop;
  bool get isMobile => breakpoint.isMobile;
  bool get isTablet => breakpoint.isTablet;
  bool get isWidescreen => breakpoint.isWidescreen;
  Size get screenSize => _mq.size;
  MediaQueryData get _mq => MediaQuery.of(this);

  /// Shorthand for breakpoint-driven value resolution.
  T responsive<T>({required T mobile, T? tablet, T? desktop, T? widescreen}) =>
      switch (breakpoint) {
        Breakpoint.widescreen => widescreen ?? desktop ?? tablet ?? mobile,
        Breakpoint.desktop => desktop ?? tablet ?? mobile,
        Breakpoint.tablet => tablet ?? mobile,
        Breakpoint.mobile => mobile,
      };
}
