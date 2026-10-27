import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/session_controller.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../application/location_permission_controller.dart';
import '../domain/location_access.dart';
import 'widgets/location_map_illustration.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends ConsumerState<LocationPermissionScreen>
    with WidgetsBindingObserver {
  bool _waitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Permission is only requested by the Allow Location button.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForSettings) {
      _waitingForSettings = false;
      unawaited(
        ref.read(locationPermissionProvider.notifier).refreshAfterSettings(),
      );
    }
  }

  Future<void> _openSettings() async {
    _waitingForSettings = true;
    final opened = await ref
        .read(locationPermissionProvider.notifier)
        .openSettings();
    if (!opened && mounted) _waitingForSettings = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationPermissionProvider);
    final controller = ref.read(locationPermissionProvider.notifier);
    // Once the customer allows or chooses Not Now, record it on the session;
    // the router's redirect then moves them on to Home.
    ref.listen(locationPermissionProvider, (previous, next) {
      if (next.isComplete && !(previous?.isComplete ?? false)) {
        ref.read(sessionProvider.notifier).markLocationPromptHandled();
      }
    });
    final message =
        state.error ??
        (state.skipped
            ? 'Location access skipped. You can enable it later.'
            : switch (state.access) {
                LocationAccess.granted => 'Location access allowed.',
                LocationAccess.denied =>
                  'Location access was denied. Try again or choose Not Now.',
                LocationAccess.permanentlyDenied =>
                  'Location access is blocked. Enable it in Settings or choose Not Now.',
                LocationAccess.restricted =>
                  'Location access is restricted by your device. You can choose Not Now.',
                LocationAccess.unavailable =>
                  'Location permission is available on Android and iOS. You can choose Not Now here.',
                LocationAccess.unknown => null,
              });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ResponsiveBody(
                  maxWidth: 440,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: (constraints.maxHeight * 0.42).clamp(
                            180.0,
                            330.0,
                          ),
                          child: const LocationMapIllustration(),
                        ),
                        Gap.v32,
                        Semantics(
                          header: true,
                          label: 'Allow Location Access',
                          excludeSemantics: true,
                          child: Text.rich(
                            TextSpan(
                              text: 'Allow ',
                              children: [
                                TextSpan(
                                  text: 'Location Access',
                                  style: TextStyle(color: AppColors.iceBlue),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: AppTypography.headingLarge,
                          ),
                        ),
                        Gap.v20,
                        Text(
                          'We need your location to find nearby service providers and give you faster assistance.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge,
                        ),
                        Gap.v40,
                        _AllowLocationButton(
                          isLoading: state.isBusy,
                          onPressed:
                              state.isBusy ||
                                  state.access == LocationAccess.granted
                              ? null
                              : () => unawaited(controller.allow()),
                        ),
                        Gap.v16,
                        OutlinedButton(
                          onPressed: state.isBusy || state.isComplete
                              ? null
                              : controller.skip,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            textStyle: AppTypography.button,
                            minimumSize: const Size(
                              double.infinity,
                              AppSizes.buttonLarge,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s16,
                              horizontal: AppSpacing.s24,
                            ),
                            side: BorderSide(color: AppColors.divider),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.lgAll,
                            ),
                          ),
                          child: const Text(
                            'Not Now',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (message != null) ...[
                          Gap.v20,
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: AppTypography.body,
                            ),
                          ),
                        ],
                        if (state.access == LocationAccess.permanentlyDenied &&
                            !state.skipped) ...[
                          Gap.v8,
                          TextButton(
                            onPressed: state.isBusy
                                ? null
                                : () => unawaited(_openSettings()),
                            child: const Text('Open Settings'),
                          ),
                        ],
                      ],
                    ),
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

/// Uses the established cyan/blue CTA treatment with wrapping content.
class _AllowLocationButton extends StatelessWidget {
  const _AllowLocationButton({
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: isLoading ? 'Allow Location, loading' : 'Allow Location',
    excludeSemantics: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: LinearGradient(
          colors: [AppColors.authGradientStart, AppColors.authGradientEnd],
        ),
        boxShadow: onPressed == null ? null : AppElevation.primaryGlow,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: AppColors.surface,
          foregroundColor: AppColors.onAuthGradient,
          minimumSize: const Size(double.infinity, AppSizes.buttonLarge),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
            vertical: AppSpacing.s16,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: AppSizes.iconLg,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.iceBlue,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AppIcons.trackingSelected, size: AppSizes.iconMd),
                  Gap.h12,
                  Flexible(
                    child: Text(
                      'Allow Location',
                      style: AppTypography.button,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}
