import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Square shortcut tile: icon above a short label, optional count badge.
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: badgeCount > 0 ? '$label, $badgeCount' : label,
      excludeSemantics: true,
      // Expands to the row height so all four tiles match.
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgAll,
              side: BorderSide(
                color: AppColors.textPrimary.withValues(alpha: 0.08),
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.lgAll,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.lgAll,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surfaceElevated,
                      AppColors.surface.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                    vertical: AppSpacing.s16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: AppSizes.iconXl,
                        color: AppColors.brandCyan,
                      ),
                      Gap.v12,
                      // One line, scaled down on narrow phones rather than
                      // breaking mid-word.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          // 11px keeps all four labels the same size on a
                          // 360dp phone; FittedBox only kicks in below that.
                          style: AppTypography.label.copyWith(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 22),
                height: 22,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: AppColors.brandGradientEnd,
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
