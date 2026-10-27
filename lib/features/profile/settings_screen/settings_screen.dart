import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/theme_controller.dart';
import '../../../core/theme/theme.dart';
import '../../tracking/widgets/rescue_scaffold.dart';
import '../notification_prefs.dart';
import '../widgets/profile_widgets.dart';

/// App preferences, starting with Theme (System / Light / Dark).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    final setMode = ref.read(themeModeProvider.notifier).set;
    final prefs = ref.watch(notificationPrefsProvider);
    final prefsCtl = ref.read(notificationPrefsProvider.notifier);

    return RescueScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Settings',
              style: AppTypography.headingLarge.copyWith(fontSize: 26),
            ),
          ),
          const GroupHeading('Theme'),
          MenuGroup(
            children: [
              for (final (m, icon, title, sub) in const [
                (
                  ThemeMode.light,
                  Icons.light_mode_outlined,
                  'Light',
                  'Bright background, dark text',
                ),
                (
                  ThemeMode.dark,
                  Icons.dark_mode_outlined,
                  'Dark',
                  'Dark background, easy on the eyes at night',
                ),
                (
                  ThemeMode.system,
                  Icons.brightness_auto_outlined,
                  'System default',
                  'Follow your phone’s setting',
                ),
              ])
                Semantics(
                  inMutuallyExclusiveGroup: true,
                  checked: mode == m,
                  child: MenuRow(
                    icon: icon,
                    title: title,
                    subtitle: sub,
                    onTap: () => setMode(m),
                    trailing: Icon(
                      mode == m
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: mode == m
                          ? AppColors.brandGradientEnd
                          : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          const GroupHeading('Notifications'),
          MenuGroup(
            children: [
              SwitchListTile(
                value: prefs.requestUpdates,
                onChanged: prefsCtl.setRequestUpdates,
                secondary: Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.brandCyan,
                ),
                title: Text('Request updates', style: AppTypography.cardTitle),
                subtitle: Text(
                  'Provider assigned, arriving, completed',
                  style: AppTypography.caption,
                ),
              ),
              SwitchListTile(
                value: prefs.offers,
                onChanged: prefsCtl.setOffers,
                secondary: Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.brandCyan,
                ),
                title: Text('Offers & news', style: AppTypography.cardTitle),
                subtitle: Text(
                  'Occasional RoadRescue updates',
                  style: AppTypography.caption,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.s4,
              top: AppSpacing.s8,
            ),
            child: Text(
              'Saved on this phone. These control in-app updates now; push '
              'alerts aren’t set up yet.',
              style: AppTypography.caption,
            ),
          ),
          const GroupHeading('General'),
          const MenuGroup(
            children: [
              MenuRow(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
