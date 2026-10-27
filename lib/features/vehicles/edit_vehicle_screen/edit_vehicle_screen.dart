import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../garage_provider.dart';
import '../widgets/vehicle_form.dart';

/// 28. Update a saved vehicle.
class EditVehicleScreen extends ConsumerWidget {
  const EditVehicleScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read once: the form owns its edits until "Update Vehicle".
    final vehicle = ref.read(garageProvider).byId(vehicleId);
    if (vehicle == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const EmptyState(
          icon: AppIcons.vehicles,
          title: 'Vehicle not found',
          message: 'It may have been deleted.',
        ),
      );
    }

    return VehicleForm(
      title: 'Edit Vehicle',
      subtitle: 'Update your vehicle information.',
      submitLabel: 'Update Vehicle',
      initial: vehicle,
      showYearAndColor: true,
      onSubmit: (updated) {
        ref.read(garageProvider.notifier).update(updated);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${updated.name} updated.')));
        context.pop();
      },
    );
  }
}
