import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../tracking/rescue_job.dart';
import '../request_draft.dart';
import '../widgets/request_step_scaffold.dart';
import 'estimates.dart';
import 'widgets/summary_row.dart';

/// Step 5: review everything, then send the request.
class RequestConfirmationScreen extends ConsumerStatefulWidget {
  const RequestConfirmationScreen({super.key});

  @override
  ConsumerState<RequestConfirmationScreen> createState() =>
      _RequestConfirmationScreenState();
}

class _RequestConfirmationScreenState
    extends ConsumerState<RequestConfirmationScreen> {
  bool _sending = false;

  Future<void> _submit() async {
    final draft = ref.read(requestDraftProvider);
    setState(() => _sending = true);
    // TEMPORARY: no requests API yet, so the request is created locally.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    ref
        .read(rescueJobProvider.notifier)
        .submit(
          service: draft.service!,
          address: draft.address ?? 'Pinned location',
          location: draft.location!,
          vehicleType: draft.vehicleType,
          vehicleName: draft.vehicleName,
          vehicleRegistration: draft.registration.trim().toUpperCase(),
          notes: draft.notes.trim(),
          photoCount: draft.photos.length,
          voiceNotePath: draft.voiceNote?.path,
        );
    ref.read(requestDraftProvider.notifier).reset();
    context.go(AppRoutes.rescueSubmitted);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(requestDraftProvider);
    final service = draft.service;

    // Reached without the earlier steps (e.g. after a restart): start over.
    if (service == null || !draft.hasVehicle || draft.location == null) {
      return RequestStepScaffold(
        title: 'Request Assistance',
        subtitle: 'Some details are missing.',
        bottom: GradientButton(
          label: 'Start Again',
          onPressed: () => context.go(AppRoutes.requestService),
        ),
        body: Text(
          'Please choose the service, vehicle and location first.',
          style: AppTypography.body,
        ),
      );
    }

    return RequestStepScaffold(
      title: 'Request Assistance',
      subtitle: 'Review the details before sending.',
      bottom: GradientButton(
        label: 'Request Assistance',
        isLoading: _sending,
        onPressed: _submit,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            SummaryRow(
              icon: AppIcons.service(service, selected: true),
              label: 'Service Type',
              value: service.label,
            ),
            SummaryRow(
              icon: AppIcons.vehicle(draft.vehicleType, selected: true),
              label: 'Vehicle',
              value:
                  '${draft.vehicleName}\n${draft.registration.trim().toUpperCase()}',
            ),
            SummaryRow(
              icon: AppIcons.locationSelected,
              label: 'Location',
              value: draft.address ?? 'Pinned location',
            ),
            SummaryRow(
              icon: Icons.payments_outlined,
              label: 'Estimated Service Charge',
              value: Estimates.charge(service),
            ),
            SummaryRow(
              icon: Icons.timer_outlined,
              label: 'Estimated Arrival',
              value: Estimates.arrival(service),
            ),
            if (draft.photos.isNotEmpty ||
                draft.notes.trim().isNotEmpty ||
                draft.voiceNote != null)
              SummaryRow(
                icon: Icons.note_alt_outlined,
                label: 'Additional Info',
                value: [
                  if (draft.photos.isNotEmpty)
                    '${draft.photos.length} photo${draft.photos.length == 1 ? '' : 's'}',
                  if (draft.voiceNote != null) 'Voice note',
                  if (draft.notes.trim().isNotEmpty) draft.notes.trim(),
                ].join(' · '),
              ),
          ],
        ),
      ),
    );
  }
}
