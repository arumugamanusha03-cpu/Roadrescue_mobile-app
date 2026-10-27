import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Base surface for every card: solid navy, hairline border, optional tap
/// and selected state. Feature cards compose this rather than drawing their
/// own containers.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = AppSpacing.cardInsets,
    this.borderRadius = AppRadius.card,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Blue tint + 1.5px blue border. Exposed to accessibility services.
  final bool selected;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final String? semanticLabel;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final interactive = widget.onTap != null;

    final card = AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
      decoration: BoxDecoration(
        color: selected
            ? Color.alphaBlend(AppColors.primarySelectedFill, AppColors.surface)
            : widget.color ?? AppColors.surface,
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderSubtle,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: interactive
              ? (value) => setState(() => _pressed = value)
              : null,
          borderRadius: widget.borderRadius,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: interactive,
      selected: interactive ? selected : null,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: _pressed ? AppMotion.pressedScale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standardCurve,
        child: card,
      ),
    );
  }
}

/// Square icon tile used at the leading edge of cards and list rows.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.selected = false,
    this.size = AppSizes.avatarMd,
    this.color,
  });

  final IconData icon;
  final bool selected;
  final double size;

  /// Overrides the icon colour for status use (e.g. error).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.standard,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceElevated,
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(
        icon,
        size: AppSizes.iconLg,
        color: color ?? (selected ? AppColors.onPrimary : AppColors.iceBlue),
      ),
    );
  }
}
