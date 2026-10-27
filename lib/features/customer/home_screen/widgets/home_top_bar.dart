import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/theme.dart';

/// Profile circle · wordmark · bell, as in the approved home design.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.onProfile,
    required this.onNotifications,
    required this.unreadCount,
  });

  final VoidCallback onProfile;
  final VoidCallback onNotifications;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.appHeaderHeight,
      child: Row(
        children: [
          _CircleButton(
            icon: AppIcons.profile,
            semanticLabel: 'Profile',
            onPressed: onProfile,
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                AppAssets.logoWordmark,
                height: 22,
                semanticLabel: 'RoadRescue',
              ),
            ),
          ),
          _CircleButton(
            icon: AppIcons.notifications,
            semanticLabel: unreadCount > 0
                ? 'Notifications, $unreadCount unread'
                : 'Notifications',
            onPressed: onNotifications,
            showDot: unreadCount > 0,
            bordered: false,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.showDot = false,
    this.bordered = true,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final bool showDot;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: AppSizes.minTouchTarget,
            height: AppSizes.minTouchTarget,
            decoration: bordered
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColorsDark.background.withValues(alpha: 0.35),
                    border: Border.all(
                      color: AppColorsDark.textPrimary.withValues(alpha: 0.35),
                    ),
                  )
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: AppSizes.iconLg,
                  color: AppColorsDark.textPrimary,
                ),
                if (showDot)
                  Positioned(
                    top: 11,
                    right: 12,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColorsDark.brandCyan,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColorsDark.background,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
