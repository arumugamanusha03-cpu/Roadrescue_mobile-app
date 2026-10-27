import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

enum AppButtonVariant {
  /// The one main action on a screen. Solid brand blue.
  primary,

  /// Alternative actions next to a primary. Elevated surface + hairline.
  secondary,

  /// Low-emphasis actions ("Not now", "Skip"). Text only.
  tertiary,

  /// Destructive or emergency-cancel actions. Tonal red.
  danger,
}

enum AppButtonSize { large, medium, small }

/// The single button implementation. [PrimaryButton] and [SecondaryButton]
/// are named shorthands for the two most common variants.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = true,
    this.emphasized = false,
  });

  final String label;

  /// Null renders the disabled state.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Replaces the label with a progress indicator and blocks taps, while
  /// keeping the button's size so the layout doesn't jump.
  final bool isLoading;

  /// Stretch to the parent's width.
  final bool expand;

  /// Adds the brand glow. Use for the single most important action on a
  /// screen (e.g. "Get Help Now", "Request Assistance") and nowhere else.
  final bool emphasized;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = _ButtonColors.resolve(widget.variant, enabled: _enabled);
    final (minHeight, hPadding, textStyle, iconSize) = switch (widget.size) {
      AppButtonSize.large => (
        AppSizes.buttonLarge,
        AppSpacing.s24,
        AppTypography.button,
        AppSizes.iconMd,
      ),
      AppButtonSize.medium => (
        AppSizes.buttonMedium,
        AppSpacing.s20,
        AppTypography.button,
        AppSizes.iconMd,
      ),
      AppButtonSize.small => (
        AppSizes.buttonSmall,
        AppSpacing.s16,
        AppTypography.buttonSmall,
        AppSizes.iconXs,
      ),
    };

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: iconSize, color: colors.foreground),
          Gap.h8,
        ],
        Flexible(
          child: Text(
            widget.label,
            style: textStyle.copyWith(color: colors.foreground),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          Gap.h8,
          Icon(widget.trailingIcon, size: iconSize, color: colors.foreground),
        ],
      ],
    );

    final button = AnimatedScale(
      scale: _pressed ? AppMotion.pressedScale : 1,
      duration: AppMotion.fast,
      curve: AppMotion.standardCurve,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.standardCurve,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: AppRadius.button,
          border: colors.border == null
              ? null
              : Border.all(color: colors.border!),
          boxShadow: widget.emphasized && _enabled
              ? AppElevation.primaryGlow
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _enabled ? widget.onPressed : null,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: AppRadius.button,
            splashColor: colors.foreground.withValues(alpha: 0.12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight,
                minWidth: AppSizes.minTouchTarget,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: hPadding,
                  vertical: AppSpacing.s8,
                ),
                child: Center(
                  widthFactor: widget.expand ? null : 1,
                  child: widget.isLoading
                      ? SizedBox.square(
                          dimension: iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.foreground,
                          ),
                        )
                      : content,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.isLoading ? '${widget.label}, loading' : null,
      excludeSemantics: widget.isLoading,
      child: widget.expand
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;

  static _ButtonColors resolve(
    AppButtonVariant variant, {
    required bool enabled,
  }) {
    if (!enabled) {
      return switch (variant) {
        AppButtonVariant.tertiary => _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.textMuted,
        ),
        _ => _ButtonColors(
          background: AppColors.surface,
          foreground: AppColors.textMuted,
          border: AppColors.borderSubtle,
        ),
      };
    }
    return switch (variant) {
      AppButtonVariant.primary => _ButtonColors(
        background: AppColors.primary,
        foreground: AppColors.onPrimary,
      ),
      AppButtonVariant.secondary => _ButtonColors(
        background: AppColors.surfaceElevated,
        foreground: AppColors.textPrimary,
        border: AppColors.borderSubtle,
      ),
      AppButtonVariant.tertiary => _ButtonColors(
        background: Colors.transparent,
        foreground: AppColors.link,
      ),
      AppButtonVariant.danger => _ButtonColors(
        background: AppColors.errorFill,
        foreground: AppColors.error,
        border: AppColors.error.withValues(alpha: 0.4),
      ),
    };
  }
}

class PrimaryButton extends AppButton {
  const PrimaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.size,
    super.leadingIcon,
    super.trailingIcon,
    super.isLoading,
    super.expand,
    super.emphasized,
  }) : super(variant: AppButtonVariant.primary);
}

class SecondaryButton extends AppButton {
  const SecondaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.size,
    super.leadingIcon,
    super.trailingIcon,
    super.isLoading,
    super.expand,
  }) : super(variant: AppButtonVariant.secondary);
}
