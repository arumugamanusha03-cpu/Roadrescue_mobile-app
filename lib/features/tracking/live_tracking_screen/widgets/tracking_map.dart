import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/theme.dart';

/// Dark map with the remaining route, the provider's van and the customer.
class TrackingMap extends StatelessWidget {
  const TrackingMap({
    super.key,
    required this.controller,
    required this.route,
    required this.provider,
    required this.customer,
    required this.providerName,
    required this.onReady,
  });

  final MapController controller;
  final List<LatLng> route;
  final LatLng provider;
  final LatLng customer;
  final String providerName;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: customer,
        initialZoom: 14,
        backgroundColor: AppColors.backgroundSecondary,
        onMapReady: onReady,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
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
        if (route.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: route,
                strokeWidth: 6,
                color: AppColors.brandGradientEnd,
                borderStrokeWidth: 3,
                borderColor: AppColors.brandCyan.withValues(alpha: 0.35),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: customer,
              width: 44,
              height: 44,
              child: const _CustomerDot(),
            ),
            Marker(
              point: provider,
              width: 150,
              height: 96,
              alignment: Alignment.topCenter,
              child: _ProviderMarker(name: providerName),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomerDot extends StatelessWidget {
  const _CustomerDot();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your location',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.brandCyan.withValues(alpha: 0.25),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brandGradientEnd,
            border: Border.all(color: AppColors.textPrimary, width: 3),
          ),
        ),
      ),
    );
  }
}

/// Name bubble above a cyan van badge.
class _ProviderMarker extends StatelessWidget {
  const _ProviderMarker({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$name’s vehicle',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8,
              vertical: AppSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              name,
              maxLines: 1,
              style: AppTypography.caption.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Gap.v4,
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandGradientEnd,
              border: Border.all(color: AppColors.textPrimary, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandCyan.withValues(alpha: 0.6),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Icon(
              Icons.local_shipping,
              size: 22,
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
