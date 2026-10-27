import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/service_type.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/adaptive_grid.dart';
import '../request_draft.dart';
import '../widgets/request_step_scaffold.dart';
import 'widgets/service_type_tile.dart';

/// Step 1 of the request flow. Tapping a service selects it and moves on.
class ServiceTypeScreen extends ConsumerWidget {
  const ServiceTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(requestDraftProvider).service;

    return RequestStepScaffold(
      title: 'Select Service Type',
      subtitle: 'What kind of assistance do you need?',
      body: AdaptiveGrid(
        minTileWidth: 140,
        maxColumns: 3,
        spacing: AppSpacing.s16,
        children: [
          for (final type in ServiceType.values)
            ServiceTypeTile(
              type: type,
              selected: type == selected,
              onTap: () {
                ref.read(requestDraftProvider.notifier).selectService(type);
                context.push(AppRoutes.requestVehicle);
              },
            ),
        ],
      ),
    );
  }
}
