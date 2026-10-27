import 'package:flutter/material.dart';

import '../../core/constants/request_status.dart';
import '../../core/theme/theme.dart';

enum StatusTone { neutral, brand, success, warning, error }

/// Compact status label. Always text + icon/dot, so colour is never the
/// only signal.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
  });

  /// Maps the shared request lifecycle onto tones in one place, so customer,
  /// provider and admin views always agree.
  factory StatusChip.request(RequestStatus status, {Key? key}) => StatusChip(
    key: key,
    label: status.label,
    icon: AppIcons.status(status),
    tone: switch (status) {
      RequestStatus.completed => StatusTone.success,
      RequestStatus.cancelled => StatusTone.neutral,
      _ => StatusTone.brand,
    },
  );

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      StatusTone.neutral => (
        AppColors.textSecondary,
        AppColors.surfaceElevated,
      ),
      StatusTone.brand => (AppColors.iceBlue, AppColors.primarySelectedFill),
      StatusTone.success => (AppColors.success, AppColors.successFill),
      StatusTone.warning => (AppColors.warning, AppColors.warningFill),
      StatusTone.error => (AppColors.error, AppColors.errorFill),
    };

    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: AppSizes.iconXs, color: foreground)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
          Gap.h8,
          Flexible(
            child: Text(
              label,
              style: AppTypography.label.copyWith(color: foreground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
