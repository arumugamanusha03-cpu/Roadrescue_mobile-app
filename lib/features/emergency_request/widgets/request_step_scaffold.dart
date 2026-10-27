import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme.dart';

/// Shared frame for every request step: back arrow, title, subtitle,
/// scrolling body, and an optional action area pinned to the bottom.
class RequestStepScaffold extends StatelessWidget {
  const RequestStepScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.bottom,
    this.scrollable = true,
  });

  final String title;
  final String subtitle;
  final Widget body;

  /// Pinned actions (Next / Use This Location / Request Assistance).
  final Widget? bottom;

  /// False when the body manages its own size (the map).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        0,
        AppSpacing.screenGutter,
        AppSpacing.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTypography.headingLarge.copyWith(fontSize: 26),
            ),
          ),
          Gap.v8,
          Text(
            subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s8),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Back',
                    icon: Icon(AppIcons.back, color: AppColors.textPrimary),
                  ),
                ),
              ),
              header,
              Expanded(
                child: scrollable
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenGutter,
                          0,
                          AppSpacing.screenGutter,
                          AppSpacing.s24,
                        ),
                        child: body,
                      )
                    : body,
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    AppSpacing.s12,
                    AppSpacing.screenGutter,
                    AppSpacing.s16,
                  ),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small grey label above a field or group ("Brand", "Notes").
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppTypography.label.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
