import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../request_draft.dart';
import '../widgets/request_fields.dart';
import '../widgets/request_step_scaffold.dart';
import 'current_location.dart';
import 'widgets/dark_map.dart';

/// Step 3: confirm where the vehicle is. GPS fix if available, otherwise
/// the customer drags the map; the text field holds the address/landmark.
class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final _map = MapController();
  final _addressFocus = FocusNode();
  late final _address = TextEditingController(
    text: ref.read(requestDraftProvider).address ?? '',
  );
  late LatLng _center =
      ref.read(requestDraftProvider).location ?? CurrentLocation.fallback;
  bool _locating = false;
  bool _mapReady = false;

  void _onMapReady() {
    _mapReady = true;
    _map.move(_center, 16);
  }

  /// True once the customer types, so map moves stop overwriting the text.
  bool _addressEdited = false;

  @override
  void initState() {
    super.initState();
    _addressEdited = _address.text.isNotEmpty;
    // Use an existing permission silently; never prompt on open.
    if (ref.read(requestDraftProvider).location == null) {
      unawaited(_locate(prompt: false));
    }
  }

  @override
  void dispose() {
    _map.dispose();
    _address.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Future<void> _locate({required bool prompt}) async {
    setState(() => _locating = true);
    try {
      final here = await CurrentLocation.get(prompt: prompt);
      if (!mounted) return;
      _center = here;
      // Before the map is ready, _onMapReady moves it to _center instead.
      if (_mapReady) _map.move(here, 16);
      if (!_addressEdited) _address.text = 'Current location';
    } on LocationUnavailable catch (e) {
      if (prompt && mounted) _snack(e.message);
    } catch (_) {
      if (prompt && mounted) {
        _snack('Couldn’t get your location. Move the map to set it.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  void _onCenterChanged(LatLng center) {
    _center = center;
    if (!_addressEdited) _address.text = 'Pinned location';
  }

  void _changeLocation() {
    _address.clear();
    _addressEdited = false;
    _addressFocus.requestFocus();
  }

  void _useThisLocation() {
    final typed = _address.text.trim();
    final label = typed.isEmpty
        ? 'Pinned location (${_center.latitude.toStringAsFixed(5)}, '
              '${_center.longitude.toStringAsFixed(5)})'
        : typed;
    ref.read(requestDraftProvider.notifier).setLocation(_center, label);
    context.push(AppRoutes.requestDetails);
  }

  @override
  Widget build(BuildContext context) {
    return RequestStepScaffold(
      title: 'Your Current Location',
      subtitle: 'Confirm your location or change it if needed',
      scrollable: false,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientButton(
            label: 'Use This Location',
            onPressed: _useThisLocation,
          ),
          Gap.v8,
          TextButton(
            onPressed: _changeLocation,
            style: TextButton.styleFrom(foregroundColor: AppColors.brandCyan),
            child: const Text('Change Location'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
            ),
            child: TextField(
              controller: _address,
              focusNode: _addressFocus,
              onChanged: (v) => _addressEdited = v.trim().isNotEmpty,
              textInputAction: TextInputAction.done,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration:
                  requestFieldDecoration(
                    hint: 'Type an address or landmark',
                    suffix: Icon(AppIcons.location, color: AppColors.brandCyan),
                  ).copyWith(
                    prefixIcon: Icon(
                      AppIcons.search,
                      color: AppColors.textSecondary,
                    ),
                  ),
            ),
          ),
          Gap.v16,
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: DarkMap(
                    controller: _map,
                    initialCenter: _center,
                    onCenterChanged: _onCenterChanged,
                    onReady: _onMapReady,
                  ),
                ),
                Positioned(
                  right: AppSpacing.s16,
                  bottom: AppSpacing.s32,
                  child: _MyLocationButton(
                    busy: _locating,
                    onPressed: () => _locate(prompt: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  const _MyLocationButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Use my current location',
      excludeSemantics: true,
      child: Material(
        color: AppColors.textPrimary,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: busy ? null : onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 52,
            child: Center(
              child: busy
                  ? SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.background,
                      ),
                    )
                  : Icon(AppIcons.myLocation, color: AppColors.background),
            ),
          ),
        ),
      ),
    );
  }
}
