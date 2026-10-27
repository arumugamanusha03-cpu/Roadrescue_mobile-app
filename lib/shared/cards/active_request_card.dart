import 'package:flutter/material.dart';

import '../../core/constants/request_status.dart';
import '../../core/constants/service_type.dart';
import '../../core/theme/theme.dart';
import '../buttons/app_button.dart';
import '../widgets/status_chip.dart';
import 'app_card.dart';
import 'provider_card.dart';

/// The live request summary on the customer home screen.
///
/// While [status] is [RequestStatus.searching] there is no provider yet, so
/// [providerName] may be null.
class ActiveRequestCard extends StatelessWidget {
  const ActiveRequestCard({
    super.key,
    required this.status,
    required this.serviceType,
    required this.onViewTracking,
    this.providerName,
    this.providerRating,
    this.providerPhoto,
    this.etaMinutes,
    this.distanceKm,
  }) : assert(
         status == RequestStatus.searching ||
             (providerName != null && providerRating != null),
         'An assigned request needs a provider',
       );

  final RequestStatus status;
  final ServiceType serviceType;
  final VoidCallback onViewTracking;
  final String? providerName;
  final double? providerRating;
  final ImageProvider? providerPhoto;
  final int? etaMinutes;
  final double? distanceKm;

  static String headlineFor(RequestStatus status) => switch (status) {
    RequestStatus.searching => 'Finding a provider near you',
    RequestStatus.accepted => 'A provider has accepted',
    RequestStatus.onTheWay => 'Your rescue is on the way',
    RequestStatus.arrived => 'Your provider has arrived',
    RequestStatus.inProgress => 'Service in progress',
    RequestStatus.completed => 'Service completed',
    RequestStatus.cancelled => 'Request cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: AppRadius.cardProminent,
      padding: AppSpacing.cardInsetsLarge,
      color: AppColors.surfaceElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(child: StatusChip.request(status)),
              const Spacer(),
              Text(serviceType.label, style: AppTypography.caption),
            ],
          ),
          Gap.v16,
          AnimatedSwitcher(
            duration: AppMotion.standard,
            child: Semantics(
              key: ValueKey(status),
              liveRegion: true,
              header: true,
              child: Text(
                headlineFor(status),
                style: AppTypography.headingSection,
              ),
            ),
          ),
          Gap.v16,
          _ProgressTrack(status: status),
          Gap.v20,
          if (providerName != null)
            ProviderSummary(
              name: providerName!,
              rating: providerRating!,
              photo: providerPhoto,
            )
          else
            Text(
              'Matching you with verified providers nearby.',
              style: AppTypography.body,
            ),
          if (etaMinutes != null || distanceKm != null) ...[
            Gap.v16,
            Row(
              children: [
                if (etaMinutes != null)
                  Expanded(
                    child: _Metric(
                      icon: AppIcons.eta,
                      label: 'Arrives in',
                      value: '$etaMinutes min',
                    ),
                  ),
                if (distanceKm != null)
                  Expanded(
                    child: _Metric(
                      icon: AppIcons.distance,
                      label: 'Distance',
                      value: '${distanceKm!.toStringAsFixed(1)} km',
                    ),
                  ),
              ],
            ),
          ],
          Gap.v20,
          PrimaryButton(
            label: 'View Tracking',
            leadingIcon: AppIcons.tracking,
            size: AppButtonSize.medium,
            onPressed: onViewTracking,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.textMuted),
          Gap.h8,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTypography.caption),
                Text(value, style: AppTypography.bodyStrong),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Four-segment track across accepted → on the way → arrived → in service.
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.status});

  final RequestStatus status;

  static const _steps = [
    RequestStatus.accepted,
    RequestStatus.onTheWay,
    RequestStatus.arrived,
    RequestStatus.inProgress,
  ];

  @override
  Widget build(BuildContext context) {
    final reached = switch (status) {
      RequestStatus.searching || RequestStatus.cancelled => 0,
      RequestStatus.completed => _steps.length,
      _ => _steps.indexOf(status) + 1,
    };

    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < _steps.length; i++) ...[
            if (i > 0) Gap.h4,
            Expanded(
              child: AnimatedContainer(
                duration: AppMotion.emphasized,
                curve: AppMotion.standardCurve,
                height: 4,
                decoration: BoxDecoration(
                  color: i < reached ? AppColors.primary : AppColors.divider,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
