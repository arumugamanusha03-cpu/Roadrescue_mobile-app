import 'package:flutter/material.dart';

import '../../../core/constants/vehicle_type.dart';
import '../../../core/theme/theme.dart';

enum RequestChipTone { active, completed, cancelled }

/// Coloured status pill on request cards: amber while live, green when
/// completed, red when cancelled. Always text + icon.
class RequestStatusPill extends StatelessWidget {
  const RequestStatusPill({super.key, required this.label, required this.tone});

  final String label;
  final RequestChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, icon) = switch (tone) {
      RequestChipTone.active => (AppColors.warning, Icons.star_rounded),
      RequestChipTone.completed => (AppColors.success, Icons.check_rounded),
      RequestChipTone.cancelled => (AppColors.error, Icons.close_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.smAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          Gap.h4,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vehicle picture slot on request cards (icon until photos exist).
class RequestVehicleImage extends StatelessWidget {
  const RequestVehicleImage({
    super.key,
    required this.type,
    this.width = 84,
    this.height = 84,
  });

  final VehicleType type;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.mdAll,
        ),
        child: Icon(
          AppIcons.vehicle(type, selected: true),
          size: width * 0.5,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
