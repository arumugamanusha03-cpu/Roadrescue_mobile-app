import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/theme.dart';

/// Dark street map (CARTO "dark_all" tiles over OpenStreetMap data; no API
/// key). The pin is fixed at the centre, so the location is whatever the
/// customer drags under it.
class DarkMap extends StatelessWidget {
  const DarkMap({
    super.key,
    required this.controller,
    required this.initialCenter,
    required this.onCenterChanged,
    required this.onReady,
  });

  final MapController controller;
  final LatLng initialCenter;
  final ValueChanged<LatLng> onCenterChanged;

  /// The controller can only move the map after this fires.
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 15,
            backgroundColor: AppColors.backgroundSecondary,
            onMapReady: onReady,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapEvent: (event) {
              if (event is MapEventMoveEnd ||
                  event is MapEventFlingAnimationEnd ||
                  event is MapEventDoubleTapZoomEnd) {
                onCenterChanged(event.camera.center);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  // CARTO dark or light tiles to match the app theme.
                  'https://{s}.basemaps.cartocdn.com/${AppColors.isDark ? 'dark_all' : 'light_all'}/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              retinaMode: RetinaMode.isHighDensity(context),
              userAgentPackageName: 'com.roadrescue.app',
            ),
          ],
        ),
        // Required tile attribution. flutter_map's SimpleAttributionWidget
        // overflows on phone widths, so this is a plain wrapping caption.
        Positioned(
          left: AppSpacing.s8,
          bottom: AppSpacing.s8,
          right: 80,
          child: Text(
            '© OpenStreetMap contributors © CARTO',
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const IgnorePointer(child: Center(child: _CenterPin())),
      ],
    );
  }
}

/// Cyan pin with a soft halo, lifted so its tip marks the map centre.
class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -10,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandCyan.withValues(alpha: 0.25),
                border: Border.all(
                  color: AppColors.brandCyan.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          Icon(
            Icons.location_on,
            size: 52,
            color: AppColors.brandCyan,
            shadows: [const Shadow(color: Color(0x9900C2FF), blurRadius: 18)],
            semanticLabel: 'Selected location',
          ),
        ],
      ),
    );
  }
}
