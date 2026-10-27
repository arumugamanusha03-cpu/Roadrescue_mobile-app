import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../buttons/app_button.dart';

/// Recoverable failure. The message should say what happened and what the
/// user can do — not an exception string.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = AppIcons.error,
  });

  /// Preset for lost connectivity, the most common failure on the roadside.
  const ErrorState.offline({
    super.key,
    this.onRetry,
    this.retryLabel = 'Try again',
  }) : title = 'No connection',
       message =
           'Check your mobile data or Wi-Fi. If this is an emergency, call '
           'your local emergency number.',
       icon = AppIcons.offline;

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.avatarLg,
                height: AppSizes.avatarLg,
                decoration: BoxDecoration(
                  color: AppColors.errorFill,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconXl,
                  color: AppColors.error,
                ),
              ),
              Gap.v20,
              Text(
                title,
                style: AppTypography.headingSection,
                textAlign: TextAlign.center,
              ),
              Gap.v8,
              Text(
                message,
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                Gap.v24,
                SecondaryButton(
                  label: retryLabel,
                  onPressed: onRetry,
                  size: AppButtonSize.medium,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
