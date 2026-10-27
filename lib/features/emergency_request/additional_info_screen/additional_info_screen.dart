import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../request_draft.dart';
import '../widgets/photo_tiles.dart';
import '../widgets/request_fields.dart';
import '../widgets/request_step_scaffold.dart';
import 'widgets/voice_note_tile.dart';

/// Step 4: optional photos, notes and voice description.
class AdditionalInfoScreen extends ConsumerStatefulWidget {
  const AdditionalInfoScreen({super.key});

  @override
  ConsumerState<AdditionalInfoScreen> createState() =>
      _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends ConsumerState<AdditionalInfoScreen> {
  late final _notes = TextEditingController(
    text: ref.read(requestDraftProvider).notes,
  );
  bool _photosOpen = true;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(requestDraftProvider);
    final notifier = ref.read(requestDraftProvider.notifier);

    return RequestStepScaffold(
      title: 'Additional Information',
      subtitle: 'Add photos, notes or voice description.',
      bottom: GradientButton(
        label: 'Next',
        onPressed: () => context.push(AppRoutes.requestConfirm),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(
            'Photos (Optional)',
            trailing: IconButton(
              onPressed: () => setState(() => _photosOpen = !_photosOpen),
              tooltip: _photosOpen ? 'Hide photos' : 'Show photos',
              visualDensity: VisualDensity.compact,
              icon: AnimatedRotation(
                turns: _photosOpen ? 0 : 0.5,
                duration: AppMotion.standard,
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.brandCyan,
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: _photosOpen
                ? PhotoTiles(
                    photos: draft.photos,
                    onAdd: () async {
                      final photo = await pickPhoto(context);
                      if (photo != null) notifier.addPhoto(photo);
                    },
                    onRemove: notifier.removePhoto,
                  )
                : const SizedBox(width: double.infinity),
          ),
          Gap.v24,
          const FieldLabel('Notes'),
          TextField(
            controller: _notes,
            onChanged: notifier.setNotes,
            minLines: 4,
            maxLines: 6,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: requestFieldDecoration(
              hint: 'Describe the problem...',
            ).copyWith(counterStyle: AppTypography.caption),
          ),
          Gap.v16,
          const FieldLabel('Voice Description (Optional)'),
          const VoiceNoteTile(),
        ],
      ),
    );
  }
}
