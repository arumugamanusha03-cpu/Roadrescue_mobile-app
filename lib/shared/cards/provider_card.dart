import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../widgets/app_avatar.dart';
import 'app_card.dart';

/// Identity row for a service provider. Used standalone (provider lists,
/// admin) and embedded in the active request card and tracking sheet via
/// [ProviderSummary].
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.name,
    required this.rating,
    this.subtitle,
    this.photo,
    this.verified = true,
    this.trailing,
    this.onTap,
  });

  final String name;
  final double rating;

  /// e.g. "Battery specialist · 2.4 km away"
  final String? subtitle;
  final ImageProvider? photo;
  final bool verified;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: ProviderSummary(
        name: name,
        rating: rating,
        subtitle: subtitle,
        photo: photo,
        verified: verified,
        trailing: trailing,
      ),
    );
  }
}

/// The card-less provider row, for composing inside other surfaces.
class ProviderSummary extends StatelessWidget {
  const ProviderSummary({
    super.key,
    required this.name,
    required this.rating,
    this.subtitle,
    this.photo,
    this.verified = true,
    this.trailing,
  });

  final String name;
  final double rating;
  final String? subtitle;
  final ImageProvider? photo;
  final bool verified;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ratingText = rating.toStringAsFixed(1);

    return Row(
      children: [
        AppAvatar(name: name, image: photo, size: AppSizes.avatarLg),
        Gap.h16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: AppTypography.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (verified) ...[
                    Gap.h4,
                    Icon(
                      AppIcons.verified,
                      size: AppSizes.iconXs,
                      color: AppColors.iceBlue,
                      semanticLabel: 'Verified provider',
                    ),
                  ],
                ],
              ),
              Gap.v4,
              Semantics(
                label: 'Rated $ratingText out of 5',
                excludeSemantics: true,
                child: Row(
                  children: [
                    Icon(
                      AppIcons.rating,
                      size: AppSizes.iconXs,
                      color: AppColors.iceBlue,
                    ),
                    Gap.h4,
                    Text(ratingText, style: AppTypography.bodyStrong),
                  ],
                ),
              ),
              if (subtitle != null) ...[
                Gap.v4,
                Text(
                  subtitle!,
                  style: AppTypography.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[Gap.h12, trailing!],
      ],
    );
  }
}
