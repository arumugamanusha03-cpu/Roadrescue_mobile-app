import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Frosted surface. Allowed only over maps, hero imagery, the active
/// request overlay and floating controls — never for ordinary cards.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.lgAll,
    this.padding,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppElevation.glassBlur,
          sigmaY: AppElevation.glassBlur,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
