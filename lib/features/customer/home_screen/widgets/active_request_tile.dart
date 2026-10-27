import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../active_request.dart';

/// Compact live-request card: provider thumbnail, service + status chip,
/// headline, rating and provider name. Tapping opens tracking.
class ActiveRequestTile extends StatelessWidget {
  const ActiveRequestTile({
    super.key,
    required this.request,
    required this.onTap,
  });

  final ActiveRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = request;

    return Semantics(
      button: true,
      hint: 'Opens live tracking',
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Row(
              children: [
                _ProviderThumb(name: r.providerName),

                Gap.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            AppIcons.service(r.serviceType),
                            size: AppSizes.iconMd,
                            color: AppColors.textPrimary,
                          ),
                          Gap.h8,
                          Expanded(
                            child: Text(
                              '${r.serviceType.shortLabel} Assistance',
                              style: AppTypography.cardTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Gap.v8,
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusChip.request(r.status),
                          if (r.etaMinutes != null)
                            Text(
                              '${r.etaMinutes} min away',
                              style: AppTypography.bodyStrong,
                            ),
                        ],
                      ),
                      Gap.v8,
                      if (r.hasProvider)
                        Wrap(
                          spacing: AppSpacing.s16,
                          runSpacing: AppSpacing.s4,
                          children: [
                            if (r.providerRating != null)
                              _Meta(
                                icon: AppIcons.rating,
                                iconColor: AppColors.warning,
                                text:
                                    '${r.providerRating!.toStringAsFixed(1)} (${r.providerReviews ?? 0})',
                                semantics:
                                    'Rated ${r.providerRating} from ${r.providerReviews ?? 0} reviews',
                              ),
                            _Meta(
                              icon: AppIcons.profile,
                              text: r.providerName!,
                            ),
                          ],
                        )
                      else
                        Text(
                          'Matching you with a verified provider nearby.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.icon,
    required this.text,
    this.iconColor,
    this.semantics,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;
  final String? semantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      excludeSemantics: semantics != null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSizes.iconXs,
            color: iconColor ?? AppColors.textMuted,
          ),
          Gap.h4,
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded-square provider photo slot; initials until photos exist.
class _ProviderThumb extends StatelessWidget {
  const _ProviderThumb({required this.name});

  /// Null while searching: shows a radar icon instead of initials.
  final String? name;

  @override
  Widget build(BuildContext context) {
    final initials = (name ?? '')
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceElevated, AppColors.backgroundSecondary],
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: name == null
          ? Icon(Icons.radar, size: 32, color: AppColors.brandCyan)
          : Text(
              initials,
              style: AppTypography.headingSection.copyWith(
                color: AppColors.brandCyan,
              ),
            ),
    );
  }
}
