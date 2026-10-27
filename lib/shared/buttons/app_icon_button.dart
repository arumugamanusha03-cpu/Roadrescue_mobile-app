import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../widgets/glass_surface.dart';

enum AppIconButtonVariant {
  /// Bare icon. Headers and inline actions.
  plain,

  /// Icon on an elevated surface tile. Standalone actions (notifications).
  filled,

  /// Frosted tile. Only for controls floating over maps or imagery.
  glass,
}

/// Icon-only button. Always 48dp to touch even when the visual is smaller,
/// and always carries a [semanticLabel] because the icon alone is not enough.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.variant = AppIconButtonVariant.plain,
    this.showBadge = false,
    this.iconColor,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;

  /// Small dot for unread notifications. Announced via the semantic label,
  /// so callers should say e.g. "Notifications, 2 unread".
  final bool showBadge;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? AppColors.textMuted
        : iconColor ?? AppColors.textPrimary;

    Widget tile = SizedBox.square(
      dimension: AppSizes.minTouchTarget,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: AppSizes.iconLg, color: color),
          if (showBadge)
            const Positioned(
              top: AppSpacing.s12,
              right: AppSpacing.s12,
              child: _Badge(),
            ),
        ],
      ),
    );

    tile = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.mdAll,
        child: tile,
      ),
    );

    tile = switch (variant) {
      AppIconButtonVariant.plain => tile,
      AppIconButtonVariant.filled => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: tile,
      ),
      AppIconButtonVariant.glass => GlassSurface(
        borderRadius: AppRadius.mdAll,
        child: tile,
      ),
    };

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Tooltip(message: semanticLabel, child: tile),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.s8,
      height: AppSpacing.s8,
      decoration: BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
    );
  }
}
