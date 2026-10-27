import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/segmented_tabs.dart';
import '../request_history.dart';
import '../rescue_format.dart';
import '../service_in_progress_screen/widgets/service_timeline.dart';
import '../widgets/request_visuals.dart';
import '../widgets/rescue_cards.dart';
import '../widgets/rescue_scaffold.dart';

/// 33. A past request in full.
class RequestDetailsScreen extends ConsumerStatefulWidget {
  const RequestDetailsScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<RequestDetailsScreen> createState() =>
      _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends ConsumerState<RequestDetailsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(requestHistoryProvider.notifier).byId(widget.requestId);
    ref.watch(requestHistoryProvider);
    if (r == null) {
      return const RescueScaffold(
        body: EmptyState(icon: AppIcons.history, title: 'Request not found'),
      );
    }

    return RescueScaffold(
      bottom: r.isCompleted
          ? GradientButton(
              label: 'Download Invoice',
              icon: AppIcons.download,
              onPressed: () => context.push(AppRoutes.invoice(r.id)),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Request Details',
              style: AppTypography.headingLarge.copyWith(fontSize: 26),
            ),
          ),
          Gap.v16,
          RescueCard(
            child: Row(
              children: [
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
                      Text(r.title, style: AppTypography.headingSection),
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
                RequestVehicleImage(
                  type: r.vehicleType,
                  width: 104,
                  height: 80,
                ),
              ],
            ),
          ),
          Gap.v16,
          SegmentedTabs(
            labels: const ['Details', 'Timeline', 'Invoice', 'Feedback'],
            selected: _tab,
            compact: true,
            onChanged: (i) => setState(() => _tab = i),
          ),
          Gap.v16,
          AnimatedSwitcher(
            duration: AppMotion.standard,
            child: KeyedSubtree(
              key: ValueKey(_tab),
              child: switch (_tab) {
                1 => _TimelineTab(request: r),
                2 => _InvoiceTab(request: r),
                3 => _FeedbackTab(request: r),
                _ => _DetailsTab(request: r),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.request});

  final PastRequest request;

  @override
  Widget build(BuildContext context) {
    final r = request;
    Widget row(IconData icon, String label, String value) => MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.brandCyan, size: 28),
            Gap.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.caption),
                  Gap.v4,
                  Text(
                    value,
                    style: AppTypography.bodyStrong.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RescueCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s4,
          ),
          child: Column(
            children: [
              row(
                AppIcons.service(r.service, selected: true),
                'Service Type',
                r.service.label,
              ),
              row(
                AppIcons.vehicle(r.vehicleType, selected: true),
                'Vehicle',
                '${r.vehicleName}\n${r.vehicleRegistration}',
              ),
              row(AppIcons.locationSelected, 'Location', r.address),
            ],
          ),
        ),
        if (r.provider != null) ...[
          Gap.v12,
          RescueCard(
            child: Row(
              children: [
                ProviderAvatar(name: r.provider!.name, size: 52),
                Gap.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service Provider', style: AppTypography.caption),
                      Text(r.provider!.name, style: AppTypography.cardTitle),
                      Row(
                        children: [
                          Icon(
                            AppIcons.rating,
                            size: AppSizes.iconXs,
                            color: AppColors.warning,
                          ),
                          Gap.h4,
                          Flexible(
                            child: Text(
                              '${r.provider!.rating} (${r.provider!.reviews} reviews)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                RoundContactButton(
                  icon: AppIcons.call,
                  label: 'Call ${r.provider!.name}',
                  onPressed: () => callProvider(context, r.provider!),
                ),
              ],
            ),
          ),
        ],
        if (r.notes != null) ...[
          Gap.v20,
          Text('Service Notes', style: AppTypography.cardTitle),
          Gap.v8,
          RescueCard(child: Text(r.notes!, style: AppTypography.body)),
        ],
        if (r.photoCount > 0) ...[
          Gap.v20,
          Text('Photos', style: AppTypography.cardTitle),
          Gap.v8,
          Row(
            children: [
              for (var i = 0; i < r.photoCount.clamp(0, 2); i++) ...[
                Expanded(child: _PhotoSlot(index: i)),
                Gap.h12,
              ],
              Expanded(
                child: r.photoCount > 2
                    ? AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                          child: Text(
                            '+${r.photoCount - 2}',
                            style: AppTypography.headingSection,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Photo placeholder until request photos are stored.
class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.mdAll,
        ),
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textMuted,
          semanticLabel: 'Photo ${index + 1}',
        ),
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.request});

  final PastRequest request;

  @override
  Widget build(BuildContext context) {
    return RescueCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s4,
      ),
      child: ServiceTimeline(
        steps: [
          for (final (label, at) in request.timeline)
            TimelineStep(
              label,
              TimelineState.done,
              time: RescueFormat.time(at),
            ),
        ],
      ),
    );
  }
}

class _InvoiceTab extends StatelessWidget {
  const _InvoiceTab({required this.request});

  final PastRequest request;

  @override
  Widget build(BuildContext context) {
    final r = request;
    if (!r.isCompleted) {
      return const EmptyState(
        compact: true,
        icon: AppIcons.invoice,
        title: 'No invoice',
        message: 'This request was cancelled before any service.',
      );
    }
    Widget line(String a, String b, {bool total = false}) => MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                a,
                style: total
                    ? AppTypography.cardTitle
                    : AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
            Text(
              b,
              style: total
                  ? AppTypography.headingSection.copyWith(
                      color: AppColors.brandCyan,
                    )
                  : AppTypography.bodyStrong,
            ),
          ],
        ),
      ),
    );
    return RescueCard(
      child: Column(
        children: [
          line('Request ID', '#${r.id}'),
          line('Service Type', r.service.shortLabel),
          line('Service Charge', RescueFormat.rupees(r.serviceCharge)),
          line('Convenience Fee', RescueFormat.rupees(r.convenienceFee)),
          Divider(color: AppColors.textPrimary.withValues(alpha: 0.08)),
          line('Total Amount', RescueFormat.rupees(r.total), total: true),
        ],
      ),
    );
  }
}

class _FeedbackTab extends StatelessWidget {
  const _FeedbackTab({required this.request});

  final PastRequest request;

  @override
  Widget build(BuildContext context) {
    final rating = request.rating;
    if (rating == null) {
      return const EmptyState(
        compact: true,
        icon: AppIcons.rating,
        title: 'No feedback given',
        message: 'You didn’t rate this request.',
      );
    }
    return RescueCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Rated $rating out of 5',
            excludeSemantics: true,
            child: Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  Icon(
                    i <= rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i <= rating
                        ? AppColors.warning
                        : AppColors.textMuted,
                    size: 32,
                  ),
              ],
            ),
          ),
          if (request.feedback != null) ...[
            Gap.v12,
            Text(request.feedback!, style: AppTypography.body),
          ],
        ],
      ),
    );
  }
}
