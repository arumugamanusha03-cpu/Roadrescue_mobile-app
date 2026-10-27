import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../core/theme/theme.dart';
import '../../live_tracking_screen/widgets/tracking_map.dart';
import '../../rescue_format.dart';
import '../../rescue_job.dart';
import '../../service_in_progress_screen/widgets/service_timeline.dart';
import '../../widgets/request_visuals.dart';
import '../../widgets/rescue_cards.dart';

/// The live request on the Track tab: summary card, step timeline and a
/// mini map that opens the full live map.
class ActiveRequestPanel extends StatefulWidget {
  const ActiveRequestPanel({
    super.key,
    required this.job,
    required this.onOpenMap,
  });

  final RescueJob job;
  final VoidCallback onOpenMap;

  static String statusLabel(RescueStage s) => switch (s) {
    RescueStage.submitted || RescueStage.searching => 'Finding Provider',
    RescueStage.assigned || RescueStage.onTheWay => 'On the Way',
    RescueStage.arrived => 'Provider Arrived',
    RescueStage.inProgress => 'In Progress',
    RescueStage.completed || RescueStage.paid => 'Completed',
  };

  @override
  State<ActiveRequestPanel> createState() => _ActiveRequestPanelState();
}

class _ActiveRequestPanelState extends State<ActiveRequestPanel> {
  final _map = MapController();

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  List<TimelineStep> _steps(RescueJob j) {
    final i = j.stage.index;
    String? t(DateTime? d) => d == null ? null : RescueFormat.time(d);
    final moving = j.providerMoving;
    final raw = <(String, String?, bool)>[
      ('Request Submitted', t(j.createdAt), true),
      ('Provider Assigned', t(j.assignedAt), i >= RescueStage.assigned.index),
      ('Provider En Route', t(j.assignedAt), i >= RescueStage.onTheWay.index),
      (
        moving
            ? 'Arriving in ${j.etaMinutes ?? '—'} minutes'
            : 'Provider Arrived',
        t(j.arrivedAt),
        i >= RescueStage.arrived.index,
      ),
      (
        'Service In Progress',
        t(j.startedAt),
        i >= RescueStage.inProgress.index,
      ),
      ('Service Completed', t(j.completedAt), i >= RescueStage.completed.index),
    ];
    final current = raw.indexWhere((s) => !s.$3);
    return [
      for (final (k, (label, time, done)) in raw.indexed)
        TimelineStep(
          label,
          done
              ? TimelineState.done
              : k == current
              ? TimelineState.current
              : TimelineState.pending,
          time: done ? time : null,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final hasMap =
        j.provider != null && j.stage.index < RescueStage.inProgress.index;

    return RescueCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RequestStatusPill(
                        label: ActiveRequestPanel.statusLabel(j.stage),
                        tone: RequestChipTone.active,
                      ),
                      Gap.v8,
                      Text('#${j.requestId}', style: AppTypography.caption),
                      Gap.v4,
                      Text(
                        j.service.label,
                        style: AppTypography.headingSection,
                      ),
                      Gap.v4,
                      Text(
                        RescueFormat.dateTime(j.createdAt),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                RequestVehicleImage(
                  type: j.vehicleType,
                  width: 110,
                  height: 80,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: ServiceTimeline(steps: _steps(j)),
          ),
          Gap.v12,
          if (hasMap)
            Semantics(
              button: true,
              label: 'Open live map',
              child: GestureDetector(
                onTap: widget.onOpenMap,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: TrackingMap(
                              controller: _map,
                              route: j.remainingRoute,
                              provider:
                                  j.providerLocation ?? j.customerLocation,
                              customer: j.customerLocation,
                              providerName: j.provider!.name,
                              onReady: () => _map.fitCamera(
                                CameraFit.coordinates(
                                  coordinates: [j.customerLocation, ...j.route],
                                  padding: const EdgeInsets.all(40),
                                  maxZoom: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (j.providerMoving)
                          Positioned(
                            top: AppSpacing.s12,
                            right: AppSpacing.s12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s12,
                                vertical: AppSpacing.s8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadius.mdAll,
                                boxShadow: AppElevation.low,
                              ),
                              child: Text(
                                'Arriving in\n${j.etaMinutes ?? '—'} minutes',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: AppSpacing.s12,
                          bottom: AppSpacing.s12,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                              boxShadow: AppElevation.low,
                            ),
                            child: Icon(
                              AppIcons.myLocation,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
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
