import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/theme.dart';
import '../../tracking/widgets/rescue_scaffold.dart';
import '../widgets/profile_widgets.dart';

/// App version, what RoadRescue is, and licences.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return RescueScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.v16,
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                // The logo artwork is made for dark backgrounds.
                color: AppPalette.dark.background,
                borderRadius: AppRadius.xlAll,
              ),
              child: Image.asset(
                AppAssets.logo,
                height: 110,
                semanticLabel: 'RoadRescue',
              ),
            ),
          ),
          Gap.v16,
          Text(
            'Version $version',
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          Gap.v20,
          Text(
            'RoadRescue connects you with verified roadside assistance '
            'providers nearby — battery, tyres, fuel, lockouts, engine '
            'trouble, accidents and towing — and lets you follow your rescue '
            'live until you’re back on the road.',
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
          Gap.v24,
          MenuGroup(
            children: [
              MenuRow(
                icon: Icons.description_outlined,
                title: 'Open-source licences',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'RoadRescue',
                  applicationVersion: version,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
