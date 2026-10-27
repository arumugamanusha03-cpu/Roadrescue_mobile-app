import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/segmented_tabs.dart';
import '../request_history.dart';
import '../rescue_job.dart';
import '../rescue_routes.dart';
import 'widgets/active_request_panel.dart';
import 'widgets/history_request_card.dart';

/// 31 / 32. Track tab: the live request, or past requests.
class TrackServiceScreen extends ConsumerStatefulWidget {
  const TrackServiceScreen({super.key, this.initialTab = 0});

  /// 0 Active, 1 History, 2 Completed.
  final int initialTab;

  static int tabFromQuery(String? tab) => switch (tab) {
    'history' => 1,
    'completed' => 2,
    _ => 0,
  };

  @override
  ConsumerState<TrackServiceScreen> createState() => _TrackServiceScreenState();
}

class _TrackServiceScreenState extends ConsumerState<TrackServiceScreen> {
  late int _tab = widget.initialTab;

  @override
  void didUpdateWidget(TrackServiceScreen old) {
    super.didUpdateWidget(old);
    if (old.initialTab != widget.initialTab) _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(rescueJobProvider);
    final history = ref.watch(requestHistoryProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // The simulated drive finishing while this tab is open.
    ref.listen(rescueJobProvider.select((j) => j?.stage), (prev, next) {
      if (_tab == 0 && next == RescueStage.arrived && prev != next) {
        context.push(AppRoutes.rescueArrived);
      }
    });

    final list = switch (_tab) {
      1 => history,
      2 => [
        for (final r in history)
          if (r.isCompleted) r,
      ],
      _ => const <PastRequest>[],
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              0,
              AppSpacing.screenGutter,
              bottomInset + AppSpacing.s24,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go(AppRoutes.home),
                  tooltip: 'Back to Home',
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: Icon(AppIcons.back, color: AppColors.textPrimary),
                ),
              ),
              Semantics(
                header: true,
                child: Text(
                  'Track Service',
                  style: AppTypography.headingLarge.copyWith(fontSize: 26),
                ),
              ),
              if (_tab == 0) ...[
                Gap.v8,
                Text(
                  'Real-time updates on your service request.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              Gap.v16,
              SegmentedTabs(
                labels: const ['Active', 'History', 'Completed'],
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              Gap.v20,
              if (_tab == 0) ...[
                if (job == null)
                  EmptyState(
                    icon: AppIcons.tracking,
                    title: 'No active request',
                    message:
                        'When you request help, you can follow it here live.',
                    actionLabel: 'Get Help Now',
                    onAction: () => context.push(AppRoutes.requestService),
                  )
                else ...[
                  ActiveRequestPanel(
                    job: job,
                    onOpenMap: () => context.push(AppRoutes.liveTracking),
                  ),
                  Gap.v20,
                  if (job.provider != null)
                    GradientButton(
                      label: 'View Provider Details',
                      onPressed: () => context.push(AppRoutes.rescueProvider),
                    )
                  else
                    GradientButton(
                      label: 'View Progress',
                      onPressed: () => context.push(rescueRouteFor(job.stage)),
                    ),
                ],
              ] else ...[
                Text(
                  _tab == 1 ? 'Recent Requests' : 'Completed Requests',
                  style: AppTypography.headingSection,
                ),
                Gap.v12,
                if (list.isEmpty)
                  const EmptyState(
                    compact: true,
                    icon: AppIcons.history,
                    title: 'Nothing here yet',
                    message: 'Finished requests will be listed here.',
                  )
                else
                  for (final r in list) ...[
                    HistoryRequestCard(
                      request: r,
                      onTap: () => context.push(AppRoutes.pastRequest(r.id)),
                    ),
                    Gap.v12,
                  ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
