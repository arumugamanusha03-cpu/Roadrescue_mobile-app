import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Standard modal sheet: drag handle, optional title, padded content that
/// lifts above the keyboard. Always open it with [AppBottomSheet.show].
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? title,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      sheetAnimationStyle: const AnimationStyle(
        duration: AppMotion.emphasized,
        reverseDuration: AppMotion.standard,
      ),
      builder: (context) =>
          AppBottomSheet(title: title, child: builder(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap.v12,
            Center(
              child: Container(
                width: AppSpacing.s40,
                height: AppSpacing.s4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s20,
                  AppSpacing.s24,
                  0,
                ),
                child: Semantics(
                  header: true,
                  child: Text(title!, style: AppTypography.headingSection),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s16,
                  AppSpacing.s24,
                  AppSpacing.s24,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
