import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme.dart';

/// Frame for the rescue screens: back arrow, scrolling body, pinned
/// actions at the bottom.
class RescueScaffold extends StatelessWidget {
  const RescueScaffold({
    super.key,
    required this.body,
    this.bottom,
    this.onBack,
    this.showBack = true,
  });

  final Widget body;
  final Widget? bottom;

  /// Defaults to popping the route.
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: AppSizes.minTouchTarget,
                child: showBack
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.s8),
                          child: IconButton(
                            onPressed:
                                onBack ??
                                () => Navigator.of(context).maybePop(),
                            tooltip: 'Back',
                            icon: Icon(
                              AppIcons.back,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    0,
                    AppSpacing.screenGutter,
                    AppSpacing.s24,
                  ),
                  child: body,
                ),
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    AppSpacing.s8,
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
