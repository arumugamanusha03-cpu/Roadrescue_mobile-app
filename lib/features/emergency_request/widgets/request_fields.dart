import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Field decoration shared by the request flow: dark fill, soft border,
/// cyan focus.
InputDecoration requestFieldDecoration({
  String? hint,
  Widget? suffix,
  Widget? prefix,
}) {
  final border = OutlineInputBorder(
    borderRadius: AppRadius.mdAll,
    borderSide: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.1)),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.s16,
      vertical: AppSpacing.s16,
    ),
    suffixIcon: suffix,
    prefixIcon: prefix,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: AppColors.brandCyan, width: 1.5),
    ),
    errorBorder: border.copyWith(
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    errorMaxLines: 2,
  );
}

/// Dropdown in the request-flow field style.
class RequestDropdown extends StatelessWidget {
  const RequestDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.validator,
    this.prefix,
  });

  /// Optional leading icon/badge inside the field.
  final Widget? prefix;
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // Rebuild when the option list changes (e.g. models after a brand).
      key: ValueKey(Object.hashAll(items)),
      initialValue: items.contains(value) ? value : null,
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: items.isEmpty
          ? null
          : (v) {
              if (v != null) onChanged(v);
            },
      validator: validator,
      isExpanded: true,
      dropdownColor: AppColors.surfaceElevated,
      borderRadius: AppRadius.mdAll,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),
      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: requestFieldDecoration(hint: hint, prefix: prefix),
    );
  }
}
