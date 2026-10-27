import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Pill-style tab strip (Active / History / Completed, Details / Timeline…).
/// The selected segment is a solid blue pill.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.compact = false,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  /// Smaller text for four-segment strips.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          for (final (i, label) in labels.indexed)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                label: '$label tab',
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: AppMotion.standard,
                    curve: AppMotion.standardCurve,
                    constraints: const BoxConstraints(minHeight: 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.smAll,
                      color: i == selected
                          ? AppColors.brandGradientEnd
                          : Colors.transparent,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact ? AppTypography.label : AppTypography.body)
                              .copyWith(
                                color: i == selected
                                    ? AppColors.onPrimary
                                    : AppColors.textSecondary,
                                fontWeight: i == selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
