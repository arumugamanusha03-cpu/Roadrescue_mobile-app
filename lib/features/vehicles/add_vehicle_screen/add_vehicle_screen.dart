import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../garage_provider.dart';
import '../widgets/vehicle_form.dart';

/// 26. Save a new vehicle.
class AddVehicleScreen extends ConsumerWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VehicleForm(
      title: 'Add Vehicle',
      subtitle:
          'Enter your vehicle details to save it for future service '
          'requests.',
      submitLabel: 'Save Vehicle',
      onSubmit: (vehicle) {
        ref.read(garageProvider.notifier).add(vehicle);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${vehicle.name} saved.')));
        context.pop();
      },
    );
  }
}
