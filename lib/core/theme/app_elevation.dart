import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Depth comes mostly from surface steps (background → surface → elevated)
/// plus a hairline border. Shadows are rare and soft; the blue glow is
/// reserved for the single primary emergency CTA on a screen.
abstract final class AppElevation {
  /// Standard card: solid surface + hairline border, no shadow.
  static BoxDecoration card({Color? color, BorderRadius? radius}) =>
      BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.borderSubtle),
      );

  /// Floating elements over content (sheets, overlays, snackbars).
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Low lift for elevated surfaces sitting on [AppColors.surface].
  static const List<BoxShadow> low = [
    BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Low-opacity brand glow. One per screen, on the primary CTA only.
  static final List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.32),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Blur sigma for the glass overlays. Kept moderate for GPU cost.
  static const double glassBlur = 16;
}
