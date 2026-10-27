import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../buttons/app_button.dart';
import 'app_bottom_sheet.dart';

/// Yes/no decision in a bottom sheet (cancel request, reject job, sign out).
/// Sheets keep the thumb near the actions, which dialogs on tall phones don't.
class ConfirmationSheet extends StatelessWidget {
  const ConfirmationSheet({
    super.key,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  /// Resolves to true only when the user confirms; dismissing returns false.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await AppBottomSheet.show<bool>(
      context,
      title: title,
      builder: (_) => ConfirmationSheet(
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, style: AppTypography.body),
        Gap.v24,
        AppButton(
          label: confirmLabel,
          variant: isDestructive
              ? AppButtonVariant.danger
              : AppButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        Gap.v12,
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.tertiary,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
