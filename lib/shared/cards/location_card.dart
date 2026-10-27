import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_card.dart';

/// An address with an optional "Change" action. Used on the request
/// confirmation, the location step and in provider job details.
class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.title,
    required this.address,
    this.isCurrentLocation = false,
    this.onChange,
  });

  /// e.g. "Pickup location" or "Current location".
  final String title;
  final String address;

  /// Swaps to the crosshair icon so a GPS fix reads differently from a
  /// searched or dropped pin.
  final bool isCurrentLocation;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(
            icon: isCurrentLocation
                ? AppIcons.myLocation
                : AppIcons.locationSelected,
          ),
          Gap.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.caption),
                Gap.v4,
                Text(
                  address,
                  style: AppTypography.bodyStrong,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onChange != null) ...[
            Gap.h8,
            TextButton(
              onPressed: onChange,
              child: Semantics(
                label: 'Change $title',
                excludeSemantics: true,
                child: const Text('Change'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
