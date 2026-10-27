import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/services/session_controller.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/dialogs/confirmation_sheet.dart';
import '../../tracking/request_history.dart';
import '../../tracking/rescue_format.dart';
import '../../tracking/rescue_job.dart';
import '../user_profile.dart';
import '../widgets/profile_widgets.dart';

/// 34. Profile tab.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await ConfirmationSheet.show(
      context,
      title: 'Log out?',
      message: 'You’ll need to sign in again to request assistance.',
      confirmLabel: 'Logout',
      cancelLabel: 'Stay Signed In',
      isDestructive: true,
    );
    // The router's redirect takes the customer to sign-in.
    if (ok) ref.read(sessionProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final total =
        ref.watch(requestHistoryProvider).length +
        (ref.watch(rescueJobProvider) == null ? 0 : 1);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              0,
              AppSpacing.screenGutter,
              bottomInset + AppSpacing.s24,
            ),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    tooltip: 'Back to Home',
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: Icon(AppIcons.back, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.settings),
                    tooltip: 'Settings',
                    icon: Icon(
                      Icons.settings_outlined,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Semantics(
                header: true,
                child: Text(
                  'My Profile',
                  style: AppTypography.headingLarge.copyWith(fontSize: 26),
                ),
              ),
              Gap.v16,
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(
                    color: AppColors.textPrimary.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    InitialsAvatar(name: profile.name),
                    Gap.h16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: AppTypography.headingSection,
                          ),
                          if (profile.phone.isNotEmpty) ...[
                            Gap.v4,
                            Text(profile.phone, style: AppTypography.body),
                          ],
                          Gap.v4,
                          Text(
                            profile.email,
                            style: AppTypography.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton.filled(
                        onPressed: () => context.push(AppRoutes.editProfile),
                        tooltip: 'Edit profile',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.brandGradientEnd,
                          foregroundColor: AppColors.onPrimary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.smAll,
                          ),
                        ),
                        icon: const Icon(Icons.edit, size: AppSizes.iconSm),
                      ),
                    ),
                  ],
                ),
              ),
              Gap.v12,
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      icon: Icons.event_available,
                      label: 'Member Since',
                      value: RescueFormat.monthYear(profile.memberSince),
                    ),
                  ),
                  Gap.h12,
                  Expanded(
                    child: _Stat(
                      icon: Icons.description,
                      label: 'Total Requests',
                      value: '$total',
                    ),
                  ),
                ],
              ),
              Gap.v12,
              MenuGroup(
                children: [
                  MenuRow(
                    icon: Icons.directions_car_filled,
                    title: 'My Vehicles',
                    subtitle: 'Manage your vehicles',
                    onTap: () => context.go(AppRoutes.vehicles),
                  ),
                  MenuRow(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'View your notifications',
                    onTap: () => context.push(AppRoutes.notifications),
                  ),
                  MenuRow(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  MenuRow(
                    icon: Icons.headset_mic,
                    title: 'Help & Support',
                    subtitle: 'FAQs and contact us',
                    onTap: () => context.push(AppRoutes.helpSupport),
                  ),
                  MenuRow(
                    icon: Icons.info,
                    title: 'About RoadRescue',
                    subtitle: 'App version 1.0.0',
                    onTap: () => context.push(AppRoutes.about),
                  ),
                ],
              ),
              Gap.v20,
              OutlinedButton.icon(
                onPressed: () => _logout(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(56),
                  side: BorderSide(color: AppColors.error),
                  backgroundColor: AppColors.errorFill,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.lgAll,
                  ),
                  textStyle: AppTypography.button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brandCyan, size: 30),
            Gap.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.caption),
                  Text(value, style: AppTypography.cardTitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
