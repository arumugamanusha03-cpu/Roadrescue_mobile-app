import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// A primary action placed in the centre of the bar. It triggers a flow
/// rather than switching tabs, so it never shows a selected state.
class AppNavAction {
  const AppNavAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  /// Not drawn; announced to screen readers and shown as a tooltip.
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

/// Shared bottom bar for all three role shells.
///
/// Rounded-top dark bar. Tabs are outlined icon + label in muted grey; the
/// selected tab switches to the filled icon and brand blue. The optional
/// [centerAction] is a raised gradient circle that sits half above the bar.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    this.centerAction,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final AppNavAction? centerAction;

  static const double _actionSize = 60;

  /// How far the centre action rises above the bar's top edge.
  static const double _actionLift = 22;

  @override
  Widget build(BuildContext context) {
    assert(
      centerAction == null || items.length.isEven,
      'A centre action needs an even number of tabs to sit between',
    );
    final tabs = <Widget>[
      for (var i = 0; i < items.length; i++)
        Expanded(
          child: _NavTab(
            item: items[i],
            selected: i == currentIndex,
            onTap: () => onSelected(i),
          ),
        ),
    ];
    if (centerAction != null) {
      // Reserve the slot; the button itself is painted above the bar.
      tabs.insert(items.length ~/ 2, const Expanded(child: SizedBox()));
    }

    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        border: Border(
          top: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.bottomNavHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s8,
              AppSpacing.s12,
              AppSpacing.s8,
              AppSpacing.s8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: tabs,
            ),
          ),
        ),
      ),
    );

    if (centerAction == null) return bar;

    // The lift area is part of this widget's bounds (transparent), so the
    // whole circle stays tappable. Shells use `extendBody` so page content
    // shows through behind it.
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: _actionLift),
          child: bar,
        ),
        _NavCenterAction(action: centerAction!, size: _actionSize),
      ],
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brandCyan : AppColors.textMuted;

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  key: ValueKey(selected),
                  size: AppSizes.iconLg,
                  color: color,
                ),
              ),
              Gap.v4,
              AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                style: AppTypography.label.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCenterAction extends StatelessWidget {
  const _NavCenterAction({required this.action, required this.size});

  final AppNavAction action;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.label,
      excludeSemantics: true,
      child: Tooltip(
        message: action.label,
        // The background-coloured ring separates the circle from the bar edge.
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brandGradientStart,
                  AppColors.brandGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGradientEnd.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: action.onPressed,
                customBorder: const CircleBorder(),
                child: SizedBox.square(
                  dimension: size,
                  child: Icon(
                    action.icon,
                    size: AppSizes.iconXl + 4,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
