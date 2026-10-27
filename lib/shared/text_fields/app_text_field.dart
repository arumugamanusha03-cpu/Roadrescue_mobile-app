import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';

/// Form field with a persistent label above the input.
///
/// A static label (rather than Material's floating label) keeps the field's
/// purpose visible while typing and reads better under large font scales.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.isPassword = false,
    this.isOptional = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helperText;

  /// Shown below the field with an icon. Write it as a fix, not a code:
  /// "Enter a 10-digit phone number", not "Invalid input".
  final String? errorText;
  final IconData? prefixIcon;
  final bool isPassword;

  /// Appends a muted "Optional" tag to the label.
  final bool isOptional;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? minLines;
  final int? maxLength;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final isMultiline = widget.maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            children: [
              if (widget.isOptional)
                TextSpan(text: '  Optional', style: AppTypography.caption),
            ],
          ),
          style: AppTypography.label,
        ),
        Gap.v8,
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscured,
          keyboardType: widget.isPassword
              ? TextInputType.visiblePassword
              : widget.keyboardType ??
                    (isMultiline ? TextInputType.multiline : null),
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            helperMaxLines: 2,
            errorText: widget.errorText,
            errorMaxLines: 3,
            alignLabelWithHint: isMultiline,
            constraints: const BoxConstraints(minHeight: AppSizes.input),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: AppSizes.iconMd),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscured ? AppIcons.visibility : AppIcons.visibilityOff,
                      size: AppSizes.iconMd,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
