import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

enum TimelineState { done, current, pending }

class TimelineStep {
  const TimelineStep(this.label, this.state, {this.time});

  final String label;
  final TimelineState state;
  final String? time;
}

/// Vertical checklist: green outlined tick for done, filled blue tick for
/// the current step, empty rings for what's next, joined by a line.
class ServiceTimeline extends StatelessWidget {
  const ServiceTimeline({super.key, required this.steps});

  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, s) in steps.indexed)
          Semantics(
            label: [
              s.label,
              switch (s.state) {
                TimelineState.done => 'done',
                TimelineState.current => 'current step',
                TimelineState.pending => 'not started',
              },
              ?s.time,
            ].join(', '),
            excludeSemantics: true,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.s12),
                          child: _Dot(state: s.state),
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Gap.h16,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.label,
                              style: AppTypography.body.copyWith(
                                color: s.state == TimelineState.pending
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontWeight: s.state == TimelineState.current
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (s.time != null)
                            Text(
                              s.time!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.state});

  final TimelineState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: state == TimelineState.current
            ? AppColors.brandGradientEnd
            : AppColors.background,
        border: switch (state) {
          TimelineState.done => Border.all(color: AppColors.success, width: 2),
          TimelineState.current => null,
          TimelineState.pending => Border.all(
            color: AppColors.textMuted,
            width: 1.5,
          ),
        },
      ),
      child: switch (state) {
        TimelineState.done => Icon(
          Icons.check,
          size: 14,
          color: AppColors.success,
        ),
        TimelineState.current => Icon(
          Icons.check,
          size: 16,
          color: AppColors.onPrimary,
        ),
        TimelineState.pending => null,
      },
    );
  }
}
