import 'package:flutter/material.dart';

import '../../core/constants/service_type.dart';
import '../../core/theme/theme.dart';
import 'app_card.dart';

enum ServiceCardLayout {
  /// Selection grid on "Select Service Type". Full label, selectable.
  tile,

  /// Home-screen category shortcut. Icon above a short label, no border.
  compact,
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.type,
    required this.onTap,
    this.selected = false,
    this.layout = ServiceCardLayout.tile,
  });

  final ServiceType type;
  final VoidCallback? onTap;
  final bool selected;
  final ServiceCardLayout layout;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      ServiceCardLayout.tile => _buildTile(),
      ServiceCardLayout.compact => _buildCompact(),
    };
  }

  Widget _buildTile() {
    return AppCard(
      onTap: onTap,
      selected: selected,
      semanticLabel: type.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(
                icon: AppIcons.service(type, selected: selected),
                selected: selected,
              ),
              const Spacer(),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: AppMotion.fast,
                child: Icon(
                  Icons.check_circle,
                  size: AppSizes.iconMd,
                  color: AppColors.iceBlue,
                ),
              ),
            ],
          ),
          Gap.v16,
          ExcludeSemantics(
            child: Text(
              type.label,
              style: AppTypography.cardTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return Semantics(
      button: true,
      label: type.shortLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.avatarLg,
                height: AppSizes.avatarLg,
                decoration: AppElevation.card(radius: AppRadius.card),
                child: Icon(
                  AppIcons.service(type),
                  size: AppSizes.iconLg,
                  color: AppColors.iceBlue,
                ),
              ),
              Gap.v8,
              Text(
                type.shortLabel,
                style: AppTypography.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
