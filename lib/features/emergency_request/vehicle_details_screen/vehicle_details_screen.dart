import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/vehicle_type.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../vehicles/garage_provider.dart';
import '../request_draft.dart';
import '../widgets/photo_tiles.dart';
import '../widgets/request_fields.dart';
import '../widgets/request_step_scaffold.dart';
import 'vehicle_catalog.dart';
import 'widgets/vehicle_type_selector.dart';

/// Step 2: vehicle type, brand, model, registration, fuel, optional photo.
class VehicleDetailsScreen extends ConsumerStatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  ConsumerState<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _registration = TextEditingController(
    text: ref.read(requestDraftProvider).registration,
  );

  @override
  void initState() {
    super.initState();
    // Start from the customer's default vehicle (screen 29's promise).
    final draft = ref.read(requestDraftProvider);
    final saved = ref.read(garageProvider).defaultVehicle;
    if (draft.brand == null &&
        saved != null &&
        VehicleType.requestTypes.contains(saved.type)) {
      // Providers can't change while the tree is building; fill after the
      // first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(requestDraftProvider.notifier)
            .useVehicle(
              type: saved.type,
              brand: saved.brand,
              model: saved.model,
              registration: saved.registration,
              fuelType: saved.fuelType,
              photo: saved.photo,
            );
        _registration.text = saved.registration;
      });
    }
  }

  @override
  void dispose() {
    _registration.dispose();
    super.dispose();
  }

  String? _required(String? v, String what) =>
      v == null || v.isEmpty ? 'Select the $what.' : null;

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    context.push(AppRoutes.requestLocation);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(requestDraftProvider);
    final notifier = ref.read(requestDraftProvider.notifier);
    final type = draft.vehicleType;
    final fuels = VehicleCatalog.fuelTypes(type);

    // A single option (bike → Petrol, EV → Electric) is chosen for them.
    if (fuels.length == 1 && draft.fuelType != fuels.single) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => notifier.setFuelType(fuels.single),
      );
    }

    return RequestStepScaffold(
      title: 'Vehicle Details',
      subtitle: 'Select or add your vehicle details.',
      bottom: GradientButton(label: 'Next', onPressed: _next),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VehicleTypeSelector(
              types: VehicleType.requestTypes,
              selected: type,
              onChanged: notifier.selectVehicleType,
            ),
            Gap.v24,
            const FieldLabel('Brand'),
            RequestDropdown(
              value: draft.brand,
              items: VehicleCatalog.brands(type),
              hint: 'Select brand',
              onChanged: notifier.setBrand,
              validator: (v) => _required(v, 'brand'),
            ),
            Gap.v16,
            const FieldLabel('Model'),
            RequestDropdown(
              value: draft.model,
              items: draft.brand == null
                  ? const []
                  : VehicleCatalog.models(type, draft.brand!),
              hint: draft.brand == null
                  ? 'Select a brand first'
                  : 'Select model',
              onChanged: notifier.setModel,
              validator: (v) => _required(v, 'model'),
            ),
            Gap.v16,
            const FieldLabel('Registration Number'),
            TextFormField(
              controller: _registration,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                LengthLimitingTextInputFormatter(13),
              ],
              onChanged: notifier.setRegistration,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: requestFieldDecoration(hint: 'TN 45 AB 1234'),
              validator: VehicleCatalog.validatePlate,
            ),
            Gap.v16,
            const FieldLabel('Fuel Type'),
            RequestDropdown(
              value: draft.fuelType,
              items: fuels,
              hint: 'Select fuel type',
              onChanged: notifier.setFuelType,
              validator: (v) => _required(v, 'fuel type'),
            ),
            Gap.v24,
            const FieldLabel('Vehicle Photo (Optional)'),
            PhotoTiles(
              photos: [?draft.vehiclePhoto],
              maxPhotos: 1,
              onAdd: () async {
                final photo = await pickPhoto(context);
                if (photo != null) notifier.setVehiclePhoto(photo);
              },
              onRemove: (_) => notifier.setVehiclePhoto(null),
            ),
          ],
        ),
      ),
    );
  }
}
