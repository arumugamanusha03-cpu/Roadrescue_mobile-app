import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../tracking/rescue_format.dart';
import '../../tracking/rescue_job.dart';
import '../../tracking/rescue_routes.dart';
import '../../tracking/widgets/rescue_scaffold.dart';
import '../notification_center.dart';
import '../notification_prefs.dart';
import '../widgets/profile_widgets.dart';

/// In-app updates about the customer's requests, with read state.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, AppNotification n) {
    ref.read(notificationCenterProvider.notifier).markRead(n.id);
    final job = ref.read(rescueJobProvider);
    if (job != null && job.requestId == n.requestId) {
      context.push(rescueRouteFor(job.stage));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationCenterProvider);
    final unread = ref.watch(unreadCountProvider);
    final updatesOn = ref.watch(notificationPrefsProvider).requestUpdates;
    final center = ref.read(notificationCenterProvider.notifier);

    return RescueScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Notifications',
                    style: AppTypography.headingLarge.copyWith(fontSize: 26),
                  ),
                ),
              ),
              if (unread > 0)
                TextButton(
                  onPressed: center.markAllRead,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandCyan,
                  ),
                  child: const Text('Mark all read'),
                ),
            ],
          ),
          Gap.v12,
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondary),
                Gap.h12,
                Expanded(
                  child: Text(
                    'In-app updates on this device. Push notifications '
                    'aren’t set up yet, so you won’t get alerts when the app '
                    'is closed.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap.v16,
          if (items.isEmpty)
            EmptyState(
              icon: AppIcons.notifications,
              title: 'You’re all caught up',
              message: updatesOn
                  ? 'Updates about your requests will appear here.'
                  : 'Request updates are turned off in Settings.',
              actionLabel: updatesOn ? null : 'Open Settings',
              onAction: updatesOn
                  ? null
                  : () => context.push(AppRoutes.settings),
            )
          else ...[
            MenuGroup(
              children: [
                for (final n in items)
                  Semantics(
                    label: n.read ? null : 'Unread',
                    child: MenuRow(
                      icon: n.read
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      title: n.title,
                      subtitle:
                          '${n.body}\n${RescueFormat.dateTimePadded(n.at)}',
                      onTap: () => _open(context, ref, n),
                      trailing: n.read
                          ? null
                          : Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.brandCyan,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
            Gap.v12,
            Center(
              child: TextButton(
                onPressed: center.clear,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: const Text('Clear all'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
