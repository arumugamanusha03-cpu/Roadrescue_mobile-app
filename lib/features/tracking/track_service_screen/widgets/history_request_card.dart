import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../request_history.dart';
import '../../rescue_format.dart';
import '../../widgets/request_visuals.dart';

/// One past request in the History / Completed lists.
class HistoryRequestCard extends StatelessWidget {
  const HistoryRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final PastRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Semantics(
      button: true,
      label:
          '${r.title}, ${r.isCompleted ? 'completed' : 'cancelled'}, '
          '${RescueFormat.dateTimePadded(r.at)}',
      excludeSemantics: true,
      child: Material(
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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s8),
            child: Row(
              children: [
                RequestVehicleImage(type: r.vehicleType, height: 96),
                Gap.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RequestStatusPill(
                        label: r.isCompleted ? 'Completed' : 'Cancelled',
                        tone: r.isCompleted
                            ? RequestChipTone.completed
                            : RequestChipTone.cancelled,
                      ),
                      Gap.v8,
                      Text('#${r.id}', style: AppTypography.caption),
                      Gap.v4,
                      Text(r.title, style: AppTypography.cardTitle),
                      Gap.v4,
                      Text(
                        RescueFormat.dateTimePadded(r.at),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(AppIcons.chevronRight, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
