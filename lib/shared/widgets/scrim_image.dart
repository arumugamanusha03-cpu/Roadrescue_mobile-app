import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// The single image treatment for photography with text on top (onboarding,
/// home hero, invoice header). A bottom-up navy scrim keeps overlaid text
/// legible regardless of the photo.
///
/// When [image] is null or fails to load, a quiet navy surface stands in so
/// layouts are reviewable before final photography is licensed.
class ScrimImage extends StatelessWidget {
  const ScrimImage({
    super.key,
    this.image,
    this.semanticLabel,
    this.borderRadius = BorderRadius.zero,
    this.alignment = Alignment.center,
    this.child,
  });

  final ImageProvider? image;

  /// Describe the photo when it carries meaning; leave null when decorative.
  final String? semanticLabel;
  final BorderRadius borderRadius;
  final Alignment alignment;

  /// Content placed over the scrim (headline, CTA).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceElevated, AppColors.background],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      // The image and scrim fill whatever size the content (or the parent)
      // establishes, so this works inside scroll views where height is
      // unbounded and grows with the font scale.
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Positioned.fill(
            child: image == null
                ? placeholder
                : Image(
                    image: image!,
                    fit: BoxFit.cover,
                    alignment: alignment,
                    semanticLabel: semanticLabel,
                    excludeFromSemantics: semanticLabel == null,
                    errorBuilder: (_, _, _) => placeholder,
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 0.7, 1],
                  colors: AppColors.imageScrim,
                ),
              ),
            ),
          ),
          child ?? const SizedBox.expand(),
        ],
      ),
    );
  }
}
