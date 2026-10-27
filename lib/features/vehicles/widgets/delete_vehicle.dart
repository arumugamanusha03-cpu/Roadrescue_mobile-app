import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/dialogs/confirmation_sheet.dart';
import '../garage_provider.dart';
import '../saved_vehicle.dart';

/// Confirms, then removes the vehicle. Returns true if it was deleted.
Future<bool> confirmDeleteVehicle(
  BuildContext context,
  WidgetRef ref,
  SavedVehicle vehicle,
) async {
  final ok = await ConfirmationSheet.show(
    context,
    title: 'Delete ${vehicle.name}?',
    message:
        '${vehicle.registration} will be removed from your saved vehicles. '
        'Past requests and invoices are kept.',
    confirmLabel: 'Delete Vehicle',
    cancelLabel: 'Keep Vehicle',
    isDestructive: true,
  );
  if (!ok) return false;
  ref.read(garageProvider.notifier).remove(vehicle.id);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${vehicle.name} deleted.')));
  }
  return true;
}
