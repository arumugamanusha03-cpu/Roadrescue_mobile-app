import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Person avatar. Falls back to initials on an elevated surface when there
/// is no photo, or when the photo fails to load.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.image,
    this.size = AppSizes.avatarMd,
  });

  final String name;
  final ImageProvider? image;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        _initials,
        style: AppTypography.bodyStrong.copyWith(
          color: AppColors.iceBlue,
          fontSize: size * 0.36,
        ),
      ),
    );

    return Semantics(
      image: true,
      label: name,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider),
        ),
        child: image == null
            ? fallback
            : Image(
                image: image!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
