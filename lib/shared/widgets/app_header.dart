import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../buttons/app_icon_button.dart';

/// Top bar for every pushed screen. Left-aligned title (Android convention),
/// back button shown automatically when the route can pop.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title,
    this.actions = const [],
    this.onBack,
    this.showBack,
    this.backgroundColor,
  });

  final String? title;
  final List<Widget> actions;

  /// Overrides the default pop behaviour (e.g. to confirm leaving a form).
  final VoidCallback? onBack;

  /// Forces the back button on/off. Defaults to whether the route can pop.
  final bool? showBack;

  /// Transparent headers are used over hero imagery and maps.
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appHeaderHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = showBack ?? Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      toolbarHeight: AppSizes.appHeaderHeight,
      titleSpacing: canPop ? 0 : AppSpacing.screenGutter,
      leadingWidth: AppSizes.minTouchTarget + AppSpacing.s12,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.s12),
              child: AppIconButton(
                icon: AppIcons.back,
                semanticLabel: 'Back',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
            )
          : null,
      title: title == null
          ? null
          : Semantics(
              header: true,
              child: Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
      actions: [...actions, Gap.h12],
    );
  }
}
