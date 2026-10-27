import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme.dart';
import '../rescue_job.dart';

/// Dark rounded card used by every rescue screen.
class RescueCard extends StatelessWidget {
  const RescueCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }
}

/// Icon tile + grey label + white value rows with hairlines between.
class InfoRowsCard extends StatelessWidget {
  const InfoRowsCard({super.key, required this.rows});

  final List<(IconData, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return RescueCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s4,
      ),
      child: Column(
        children: [
          for (final (i, (icon, label, value)) in rows.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 64,
                color: AppColors.textPrimary.withValues(alpha: 0.06),
              ),
            MergeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Icon(icon, color: AppColors.brandCyan),
                    ),
                    Gap.h16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: AppTypography.caption),
                          Gap.v4,
                          Text(
                            value,
                            style: AppTypography.bodyStrong.copyWith(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Provider avatar, name, rating and either a verified badge or the
/// vehicle line, with optional call / message buttons.
class RescueProviderRow extends StatelessWidget {
  const RescueProviderRow({
    super.key,
    required this.provider,
    this.showVerified = true,
    this.showVehicle = false,
    this.showContact = false,
  });

  final ProviderInfo provider;
  final bool showVerified;
  final bool showVehicle;
  final bool showContact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProviderAvatar(name: provider.name),
        Gap.h16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.name,
                style: AppTypography.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap.v4,
              Semantics(
                label:
                    'Rated ${provider.rating} from ${provider.reviews} reviews',
                excludeSemantics: true,
                child: Row(
                  children: [
                    Icon(
                      AppIcons.rating,
                      size: AppSizes.iconXs,
                      color: AppColors.warning,
                    ),
                    Gap.h4,
                    Flexible(
                      child: Text(
                        '${provider.rating} (${provider.reviews} reviews)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showVehicle) ...[
                Gap.v4,
                Text(
                  provider.vehicleLine,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else if (showVerified) ...[
                Gap.v8,
                const VerifiedBadge(),
              ],
            ],
          ),
        ),
        if (showContact) ...[
          Gap.h8,
          RoundContactButton(
            icon: AppIcons.call,
            label: 'Call ${provider.name}',
            onPressed: () => callProvider(context, provider),
          ),
          Gap.h8,
          RoundContactButton(
            icon: Icons.chat_bubble,
            label: 'Message ${provider.name}',
            filled: true,
            onPressed: () => messageProvider(context, provider),
          ),
        ],
      ],
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySelectedFill,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: AppColors.brandCyan),
          Gap.h4,
          Flexible(
            child: Text(
              'Verified Provider',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                color: AppColors.iceBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Initials in a circle until provider photos exist.
class ProviderAvatar extends StatelessWidget {
  const ProviderAvatar({super.key, required this.name, this.size = 56});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceElevated, AppColors.backgroundSecondary],
        ),
        border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.5)),
      ),
      child: Text(
        initials,
        style: AppTypography.cardTitle.copyWith(
          fontSize: size * 0.32,
          color: AppColors.brandCyan,
        ),
      ),
    );
  }
}

class RoundContactButton extends StatelessWidget {
  const RoundContactButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: filled ? AppColors.brandGradientEnd : AppColors.surfaceElevated,
        shape: CircleBorder(
          side: filled
              ? BorderSide.none
              : BorderSide(color: AppColors.brandCyan.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(
              icon,
              size: AppSizes.iconMd,
              color: filled ? AppColors.onPrimary : AppColors.brandCyan,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cyan-outlined secondary action ("Live Tracking", "Rate Provider").
class OutlineActionButton extends StatelessWidget {
  const OutlineActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandCyan,
        minimumSize: const Size.fromHeight(56),
        // Tight side padding so two buttons fit side by side on phones.
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
        side: BorderSide(color: AppColors.brandCyan.withValues(alpha: 0.6)),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        textStyle: AppTypography.button,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: AppSizes.iconMd), Gap.h8],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// Opens the dialer. Tells the customer if the device can't place calls.
Future<void> callProvider(BuildContext context, ProviderInfo provider) =>
    _launch(context, Uri(scheme: 'tel', path: provider.phone), 'call');

Future<void> messageProvider(BuildContext context, ProviderInfo provider) =>
    _launch(context, Uri(scheme: 'sms', path: provider.phone), 'message');

Future<void> _launch(BuildContext context, Uri uri, String action) async {
  var ok = false;
  try {
    ok = await launchUrl(uri);
  } catch (_) {}
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Couldn’t open $action on this device.')),
      );
  }
}
