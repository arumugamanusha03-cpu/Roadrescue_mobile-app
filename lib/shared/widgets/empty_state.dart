import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../buttons/app_button.dart';

/// Explains why an area is empty and, where possible, offers the next step.
///
/// [compact] renders as an inline card row (e.g. "No active assistance" on
/// the home screen); the default is a centred full-area state.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconTile = Container(
      width: compact ? AppSizes.avatarMd : AppSizes.avatarLg,
      height: compact ? AppSizes.avatarMd : AppSizes.avatarLg,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(
        icon,
        size: compact ? AppSizes.iconMd : AppSizes.iconXl,
        color: AppColors.textMuted,
      ),
    );

    if (compact) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: AppElevation.card(radius: AppRadius.card),
        child: Row(
          children: [
            iconTile,
            Gap.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTypography.cardTitle),
                  if (message != null) ...[
                    Gap.v4,
                    Text(message!, style: AppTypography.caption),
                  ],
                ],
              ),
            ),
            if (actionLabel != null) ...[
              Gap.h8,
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconTile,
            Gap.v20,
            Text(
              title,
              style: AppTypography.headingSection,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              Gap.v8,
              Text(
                message!,
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              Gap.v24,
              SecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.medium,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
