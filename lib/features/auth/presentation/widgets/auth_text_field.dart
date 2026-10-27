import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Translucent field from the auth design: icon + placeholder inside, no
/// label above. The placeholder doubles as the accessible label.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
  });

  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.isPassword;

  static final _border = OutlineInputBorder(
    borderRadius: AppRadius.lgAll,
    borderSide: BorderSide(
      color: AppColorsDark.textPrimary.withValues(alpha: 0.14),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTypographyDark.bodyLarge.copyWith(
        fontSize: 17,
        color: AppColorsDark.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypographyDark.bodyLarge.copyWith(
          fontSize: 17,
          color: AppColorsDark.textSecondary,
        ),
        filled: true,
        fillColor: AppColorsDark.surface.withValues(alpha: 0.55),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s20,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.s20,
            right: AppSpacing.s12,
          ),
          child: Icon(
            widget.icon,
            size: AppSizes.iconLg,
            color: AppColorsDark.textSecondary,
          ),
        ),
        suffixIcon: widget.isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s8),
                child: IconButton(
                  onPressed: () => setState(() => _obscured = !_obscured),
                  tooltip: _obscured ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscured ? AppIcons.visibilityOff : AppIcons.visibility,
                    color: AppColorsDark.textSecondary,
                  ),
                ),
              )
            : null,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border.copyWith(
          borderSide: BorderSide(color: AppColorsDark.brandCyan, width: 1.5),
        ),
        errorBorder: _border.copyWith(
          borderSide: BorderSide(color: AppColorsDark.error),
        ),
        focusedErrorBorder: _border.copyWith(
          borderSide: BorderSide(color: AppColorsDark.error, width: 1.5),
        ),
        errorMaxLines: 2,
      ),
    );
  }
}
