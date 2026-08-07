import 'package:flutter/material.dart';

/// A star-rating display that can also collect input.
///
/// Renders [maxStars] icons that visually represent a numeric [ratingValue].
/// Supports half-star precision when [enableHalfStar] is `true`.
///
/// Read-only by default. Supply [onRatingChanged] to make it interactive:
///
/// ```dart
/// GStarRatingBar(
///   ratingValue: rating,
///   starSize: 32,
///   onRatingChanged: (value) => setState(() => rating = value),
/// );
/// ```
class GStarRatingBar extends StatelessWidget {
  /// The current rating value.
  final double ratingValue;

  /// The size of each star icon.
  final double starSize;

  /// The color of filled stars.
  final Color activeStarColor;

  /// The color of unfilled stars.
  final Color inactiveStarColor;

  /// The total number of stars to display.
  final int maxStars;

  /// The horizontal space between stars.
  final double starSpacing;

  /// Whether to allow half-star ratings.
  final bool enableHalfStar;

  /// The icon to use for filled stars.
  final IconData activeStarIcon;

  /// The icon to use for half-filled stars.
  final IconData halfStarIcon;

  /// The icon to use for empty stars.
  final IconData inactiveStarIcon;

  /// Optional semantics label for assistive technologies.
  final String? semanticsLabel;

  /// Called with the new rating when a star is tapped.
  ///
  /// When null the bar stays read-only. When [enableHalfStar] is true,
  /// tapping the leading half of a star reports the half value.
  final ValueChanged<double>? onRatingChanged;

  /// Creates a star rating bar showing [ratingValue] out of [maxStars] stars.
  const GStarRatingBar({
    super.key,
    required this.ratingValue,
    this.starSize = 14.0,
    this.activeStarColor = Colors.amber,
    this.inactiveStarColor = Colors.grey,
    this.maxStars = 5,
    this.starSpacing = 2.0,
    this.enableHalfStar = true,
    this.activeStarIcon = Icons.star,
    this.halfStarIcon = Icons.star_half,
    this.inactiveStarIcon = Icons.star_border,
    this.semanticsLabel,
    this.onRatingChanged,
  }) : assert(
         ratingValue >= 0 && ratingValue <= maxStars,
         'Rating value must be between 0 and $maxStars',
       );

  @override
  Widget build(BuildContext context) {
    final isInteractive = onRatingChanged != null;

    return Semantics(
      label: semanticsLabel ?? 'Rating $ratingValue out of $maxStars',
      readOnly: !isInteractive,
      slider: isInteractive,
      value: '$ratingValue',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxStars, (starIndex) {
          final star = ExcludeSemantics(child: _buildStarIcon(starIndex + 1));

          return Padding(
            padding: EdgeInsets.only(
              right: starIndex < maxStars - 1 ? starSpacing : 0,
            ),
            child:
                isInteractive
                    ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp:
                          (details) =>
                              _handleTap(starIndex, details.localPosition.dx),
                      child: star,
                    )
                    : star,
          );
        }),
      ),
    );
  }

  void _handleTap(int starIndex, double localX) {
    final isLeadingHalf = enableHalfStar && localX < starSize / 2;
    final value = starIndex + (isLeadingHalf ? 0.5 : 1.0);
    onRatingChanged?.call(value.clamp(0.0, maxStars.toDouble()));
  }

  Widget _buildStarIcon(int starPosition) {
    IconData starIcon;
    Color starColor;

    if (starPosition <= ratingValue) {
      starIcon = activeStarIcon;
      starColor = activeStarColor;
    } else if (enableHalfStar && starPosition - ratingValue <= 0.5) {
      starIcon = halfStarIcon;
      starColor = activeStarColor;
    } else {
      starIcon = inactiveStarIcon;
      starColor = inactiveStarColor;
    }

    return Icon(starIcon, color: starColor, size: starSize);
  }
}

@Deprecated(
  'Use GStarRatingBar instead. This alias will be removed before 1.0.',
)
/// Deprecated alias for [GStarRatingBar].
class StarRatingBar extends GStarRatingBar {
  /// Creates a deprecated star rating bar. Prefer [GStarRatingBar].
  const StarRatingBar({
    super.key,
    required super.ratingValue,
    super.starSize,
    super.activeStarColor,
    super.inactiveStarColor,
    super.maxStars,
    super.starSpacing,
    super.enableHalfStar,
    super.activeStarIcon,
    super.halfStarIcon,
    super.inactiveStarIcon,
    super.semanticsLabel,
  });
}
