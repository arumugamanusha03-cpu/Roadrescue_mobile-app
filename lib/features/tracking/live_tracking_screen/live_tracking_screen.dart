import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../rescue_job.dart';
import '../widgets/rescue_cards.dart';
import 'route_simulation.dart';
import 'widgets/tracking_map.dart';

/// 19. Full-screen map of the provider driving to the customer.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  final _map = MapController();
  bool _mapReady = false;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _fit(RescueJob job) {
    if (!_mapReady) return;
    final pts = [job.customerLocation, ?job.providerLocation, ...job.route];
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: pts,
        padding: const EdgeInsets.fromLTRB(60, 140, 60, 60),
        maxZoom: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(rescueJobProvider);
    final provider = job?.provider;

    if (job == null || provider == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: EmptyState(
            icon: AppIcons.tracking,
            title: 'Nothing to track yet',
            message:
                'Once a provider accepts your request, you can follow '
                'them here live.',
            actionLabel: 'Get Help Now',
            onAction: () => context.push(AppRoutes.requestService),
          ),
        ),
      );
    }

    // The (simulated) drive runs in RescueJobController; show the arrival.
    ref.listen(rescueJobProvider.select((j) => j?.stage), (prev, next) {
      if (next == RescueStage.arrived && prev != RescueStage.arrived) {
        context.push(AppRoutes.rescueArrived);
      }
    });
    final arrived = job.stage.index >= RescueStage.arrived.index;
    final providerAt = job.providerLocation ?? job.customerLocation;
    final route = job.remainingRoute;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s8,
                  0,
                  AppSpacing.screenGutter,
                  AppSpacing.s12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.tracking),
                      tooltip: 'Back',
                      icon: Icon(
                        Icons.chevron_left,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.s12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              'Live Tracking',
                              style: AppTypography.headingLarge.copyWith(
                                fontSize: 26,
                              ),
                            ),
                          ),
                          Gap.v4,
                          Text(
                            arrived
                                ? 'Your provider has arrived at your location.'
                                : 'Your provider is on the way to your location.',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: TrackingMap(
                        controller: _map,
                        route: route,
                        provider: providerAt,
                        customer: job.customerLocation,
                        providerName: provider.name,
                        onReady: () {
                          _mapReady = true;
                          _fit(job);
                        },
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.s16,
                      left: AppSpacing.screenGutter,
                      right: AppSpacing.screenGutter,
                      child: _EtaCard(
                        arrived: arrived,
                        minutes:
                            job.etaMinutes ?? RouteSimulation.startEtaMinutes,
                      ),
                    ),
                    Positioned(
                      right: AppSpacing.screenGutter,
                      top: 130,
                      child: Column(
                        children: [
                          _MapButton(
                            icon: AppIcons.myLocation,
                            label: 'Show the whole route',
                            onPressed: () => _fit(job),
                          ),
                          Gap.v16,
                          _MapButton(
                            icon: Icons.more_horiz,
                            label: 'Request details',
                            onPressed: () =>
                                context.push(AppRoutes.rescueProvider),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.screenGutter,
                      right: AppSpacing.screenGutter,
                      bottom: bottomInset + AppSpacing.s16,
                      child: RescueCard(
                        child: RescueProviderRow(
                          provider: provider,
                          showVehicle: true,
                          showContact: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtaCard extends StatelessWidget {
  const _EtaCard({required this.arrived, required this.minutes});

  final bool arrived;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: arrived ? 'Provider has arrived' : 'Arriving in $minutes minutes',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.88),
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 96,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(
                Icons.local_shipping,
                size: 34,
                color: AppColors.textPrimary,
              ),
            ),
            Gap.h16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arrived ? 'Status' : 'Arriving in',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Gap.v4,
                Text(
                  arrived
                      ? 'Arrived'
                      : '$minutes minute${minutes == 1 ? '' : 's'}',
                  style: AppTypography.headingSection,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.textPrimary,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 48,
            child: Icon(icon, color: AppColors.background),
          ),
        ),
      ),
    );
  }
}
