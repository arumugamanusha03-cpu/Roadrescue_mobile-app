import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../rescue_format.dart';
import '../rescue_job.dart';
import '../widgets/no_active_rescue.dart';
import '../widgets/rescue_cards.dart';
import 'widgets/service_timeline.dart';

/// 21. The provider is working on the vehicle.
///
/// TEMPORARY: the service "finishes" after [demoDuration]; with a backend
/// the provider's Complete Service action drives this.
class ServiceInProgressScreen extends ConsumerStatefulWidget {
  const ServiceInProgressScreen({super.key});

  static const demoDuration = Duration(seconds: 8);

  @override
  ConsumerState<ServiceInProgressScreen> createState() =>
      _ServiceInProgressScreenState();
}

class _ServiceInProgressScreenState
    extends ConsumerState<ServiceInProgressScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(ServiceInProgressScreen.demoDuration, () {
      if (ref.read(rescueJobProvider)?.stage != RescueStage.inProgress) return;
      ref.read(rescueJobProvider.notifier).completeService();
      if (mounted) context.go(AppRoutes.rescueCompleted);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(rescueJobProvider);
    final p = job?.provider;
    if (job == null || p == null) return const NoActiveRescue();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Photo across the top, fading into the page.
          SizedBox(
            height: 300,
            width: double.infinity,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black, Colors.transparent],
                stops: [0, 0.55, 1],
              ).createShader(r),
              child: Image.asset(
                AppAssets.homeHero,
                fit: BoxFit.cover,
                alignment: const Alignment(-0.3, 0.2),
                excludeFromSemantics: true,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.s8),
                    child: IconButton(
                      onPressed: () => context.go(AppRoutes.home),
                      tooltip: 'Back to Home',
                      icon: Icon(AppIcons.back, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenGutter,
                      150,
                      AppSpacing.screenGutter,
                      AppSpacing.s24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          liveRegion: true,
                          child: Text(
                            'Service In Progress',
                            textAlign: TextAlign.center,
                            style: AppTypography.headingLarge.copyWith(
                              fontSize: 26,
                            ),
                          ),
                        ),
                        Gap.v12,
                        Text(
                          'Your provider is working on your vehicle.\n'
                          'We’ll notify you once the service is completed.',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Gap.v24,
                        RescueCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                            vertical: AppSpacing.s4,
                          ),
                          child: ServiceTimeline(
                            steps: [
                              TimelineStep(
                                'Provider Arrived',
                                TimelineState.done,
                                time: job.arrivedAt == null
                                    ? null
                                    : RescueFormat.time(job.arrivedAt!),
                              ),
                              TimelineStep(
                                'Service Started',
                                TimelineState.current,
                                time: job.startedAt == null
                                    ? null
                                    : RescueFormat.time(job.startedAt!),
                              ),
                              const TimelineStep(
                                'Service in Progress',
                                TimelineState.pending,
                              ),
                              const TimelineStep(
                                'Service Completed',
                                TimelineState.pending,
                              ),
                            ],
                          ),
                        ),
                        Gap.v24,
                        Text(
                          'You can contact your provider if needed.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    AppSpacing.s8,
                    AppSpacing.screenGutter,
                    AppSpacing.s16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlineActionButton(
                          label: 'Call Provider',
                          icon: AppIcons.call,
                          onPressed: () => callProvider(context, p),
                        ),
                      ),
                      Gap.h12,
                      Expanded(
                        child: OutlineActionButton(
                          label: 'View Details',
                          onPressed: () =>
                              context.push(AppRoutes.rescueProvider),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
