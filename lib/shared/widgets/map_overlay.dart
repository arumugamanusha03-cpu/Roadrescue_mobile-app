import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'glass_surface.dart';

/// A frosted panel floating over the map: the ETA pill on tracking, the
/// selected-address panel on location pick, the provider's next-turn hint.
///
/// Place it inside a [Stack] above the map. It pads itself away from the
/// screen edges and system UI.
class MapOverlay extends StatelessWidget {
  const MapOverlay({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: GlassSurface(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
