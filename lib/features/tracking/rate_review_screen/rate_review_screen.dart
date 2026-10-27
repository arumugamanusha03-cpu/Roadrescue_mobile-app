import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../emergency_request/widgets/request_fields.dart';
import '../rescue_job.dart';
import '../widgets/no_active_rescue.dart';
import '../widgets/rescue_cards.dart';
import '../widgets/rescue_scaffold.dart';
import 'widgets/star_rating.dart';

/// 24. Rate the provider, then the journey ends.
///
/// TEMPORARY: the review isn't sent anywhere until the reviews API exists.
class RateReviewScreen extends ConsumerStatefulWidget {
  const RateReviewScreen({super.key});

  @override
  ConsumerState<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends ConsumerState<RateReviewScreen> {
  static const _tags = [
    'Professional',
    'On Time',
    'Helpful',
    'Good Service',
    'Friendly',
  ];

  final _comment = TextEditingController();
  final _selected = <String>{};
  int _stars = 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _done(String message, {bool withReview = false}) {
    ref
        .read(rescueJobProvider.notifier)
        .finish(
          rating: withReview ? _stars : null,
          feedback: withReview
              ? [
                  ..._selected,
                  _comment.text.trim(),
                ].where((s) => s.isNotEmpty).join(' · ')
              : null,
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    context.go(AppRoutes.home);
  }

  void _submit() {
    if (_stars == 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Tap a star to rate your provider.')),
        );
      return;
    }
    _done('Thanks for your review!', withReview: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(rescueJobProvider)?.provider;
    if (p == null) return const NoActiveRescue();

    return RescueScaffold(
      onBack: () => context.go(AppRoutes.home),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientButton(label: 'Submit Review', onPressed: _submit),
          Gap.v8,
          TextButton(
            onPressed: () => _done('Thanks for using RoadRescue.'),
            style: TextButton.styleFrom(foregroundColor: AppColors.brandCyan),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.star_rounded,
            size: 52,
            color: AppColors.warning,
            shadows: [const Shadow(color: Color(0x88F2B84B), blurRadius: 20)],
          ),
          Gap.v12,
          Semantics(
            header: true,
            child: Text(
              'Rate & Review',
              textAlign: TextAlign.center,
              style: AppTypography.headingLarge.copyWith(fontSize: 24),
            ),
          ),
          Gap.v8,
          Text.rich(
            TextSpan(
              text: 'How was your experience with ',
              children: [
                TextSpan(
                  text: '${p.name}?',
                  style: TextStyle(color: AppColors.brandCyan),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          Gap.v24,
          RescueProviderRow(provider: p, showVehicle: true),
          Gap.v24,
          StarRating(
            value: _stars,
            onChanged: (v) => setState(() => _stars = v),
          ),
          Gap.v24,
          TextField(
            controller: _comment,
            minLines: 3,
            maxLines: 5,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: requestFieldDecoration(
              hint: 'Share your experience (optional)...',
            ).copyWith(counterStyle: AppTypography.caption),
          ),
          Gap.v12,
          Wrap(
            spacing: AppSpacing.s12,
            runSpacing: AppSpacing.s12,
            children: [
              for (final tag in _tags)
                FilterChip(
                  label: Text(tag),
                  selected: _selected.contains(tag),
                  onSelected: (on) => setState(
                    () => on ? _selected.add(tag) : _selected.remove(tag),
                  ),
                  showCheckmark: false,
                  labelStyle: AppTypography.label.copyWith(
                    color: _selected.contains(tag)
                        ? AppColors.onAuthGradient
                        : AppColors.textPrimary,
                  ),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.authGradientStart,
                  side: BorderSide(
                    color: AppColors.textPrimary.withValues(alpha: 0.12),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
