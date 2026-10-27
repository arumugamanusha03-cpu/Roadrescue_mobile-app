import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// "Don't have an account? Sign Up" line at the bottom of the auth screens.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: AppTypographyDark.bodyLarge.copyWith(
            color: AppColorsDark.textSecondary,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColorsDark.brandCyan,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            textStyle: AppTypographyDark.button.copyWith(fontSize: 17),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
