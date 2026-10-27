import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Cyan icon, grey label, white value — one line of the request summary.
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Jumps back to the step that set this value.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 26, color: AppColors.brandCyan),
            ),
            Gap.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Gap.v4,
                  Text(
                    value,
                    style: AppTypography.bodyStrong.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit $label',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  AppIcons.edit,
                  size: AppSizes.iconSm,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
