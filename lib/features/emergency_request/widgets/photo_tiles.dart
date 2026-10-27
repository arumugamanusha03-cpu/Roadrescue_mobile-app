import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/dialogs/app_bottom_sheet.dart';
import '../request_draft.dart';

/// Asks camera or gallery, then returns the picked photo (or null).
Future<PickedPhoto?> pickPhoto(BuildContext context) async {
  final source = await AppBottomSheet.show<ImageSource>(
    context,
    title: 'Add photo',
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(AppIcons.camera, color: AppColors.brandCyan),
          title: Text('Take photo', style: AppTypography.bodyStrong),
          onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
        ),
        ListTile(
          leading: Icon(
            Icons.photo_library_outlined,
            color: AppColors.brandCyan,
          ),
          title: Text('Choose from gallery', style: AppTypography.bodyStrong),
          onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
        ),
      ],
    ),
  );
  if (source == null) return null;

  try {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null) return null;
    return PickedPhoto(bytes: await file.readAsBytes(), name: file.name);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t open the camera or gallery. Try again.'),
        ),
      );
    }
    return null;
  }
}

/// Row of photo thumbnails followed by a "+" tile.
class PhotoTiles extends StatelessWidget {
  const PhotoTiles({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.maxPhotos = 4,
  });

  final List<PickedPhoto> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int maxPhotos;

  static const double size = 92;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s12,
      runSpacing: AppSpacing.s12,
      children: [
        for (final (i, photo) in photos.indexed)
          _Thumb(photo: photo, onRemove: () => onRemove(i)),
        if (photos.length < maxPhotos) _AddTile(onTap: onAdd),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.photo, required this.onRemove});

  final PickedPhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: PhotoTiles.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: Image.memory(
              photo.bytes,
              fit: BoxFit.cover,
              semanticLabel: 'Attached photo',
            ),
          ),
          Positioned(
            top: AppSpacing.s4,
            right: AppSpacing.s4,
            child: Material(
              color: AppColors.background.withValues(alpha: 0.7),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  child: Icon(
                    AppIcons.close,
                    size: AppSizes.iconXs,
                    color: AppColors.textPrimary,
                    semanticLabel: 'Remove photo',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add photo',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.12),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: SizedBox.square(
            dimension: PhotoTiles.size,
            child: Icon(
              Icons.add,
              size: AppSizes.iconXl,
              color: AppColors.brandCyan,
            ),
          ),
        ),
      ),
    );
  }
}
