import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../tracking/rescue_format.dart';
import '../garage_provider.dart';
import '../saved_vehicle.dart';
import '../widgets/delete_vehicle.dart';
import '../widgets/vehicle_visuals.dart';

/// 27. One saved vehicle in full.
class SavedVehicleDetailsScreen extends ConsumerWidget {
  const SavedVehicleDetailsScreen({super.key, required this.vehicleId});

  final String vehicleId;

  static String _date(DateTime? d) {
    if (d == null) return 'Not added';
    final s = RescueFormat.dateTime(d);
    return s.substring(0, s.indexOf(' •'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garage = ref.watch(garageProvider);
    final v = garage.byId(vehicleId);
    if (v == null) {
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
    final isDefault = garage.isDefault(v);
    void edit() => context.push(AppRoutes.editVehicle(v.id));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _Hero(vehicle: v, isDefault: isDefault, onEdit: edit),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenGutter,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Gap.v16,
                        Row(
                          children: [
                            BrandBadge(brand: v.brand, size: 52),
                            Gap.h16,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.brand,
                                    style: AppTypography.headingSection,
                                  ),
                                  Text(
                                    v.model,
                                    style: AppTypography.headingSection,
                                  ),
                                  Gap.v4,
                                  Text(
                                    v.registration,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Gap.v20,
                        _StatsRow(vehicle: v),
                        Gap.v16,
                        _DocsCard(
                          rows: [
                            (
                              Icons.description_outlined,
                              'Registration Number',
                              v.registration,
                            ),
                            (
                              AppIcons.vehicles,
                              'Chassis Number',
                              v.chassisNumber ?? 'Not added',
                            ),
                            (
                              Icons.verified_user_outlined,
                              'Insurance Valid Till',
                              _date(v.insuranceValidTill),
                            ),
                            (
                              Icons.eco_outlined,
                              'PUC Valid Till',
                              _date(v.pucValidTill),
                            ),
                          ],
                          onTap: edit,
                        ),
                        Gap.v24,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.s8,
                  AppSpacing.screenGutter,
                  AppSpacing.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isDefault) ...[
                      GradientButton(
                        label: 'Set as Default Vehicle',
                        icon: Icons.star_rounded,
                        onPressed: () {
                          ref.read(garageProvider.notifier).setDefault(v.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${v.name} is now your default.'),
                            ),
                          );
                        },
                      ),
                      Gap.v12,
                    ],
                    OutlinedButton.icon(
                      onPressed: () async {
                        if (await confirmDeleteVehicle(context, ref, v) &&
                            context.mounted) {
                          context.pop();
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Vehicle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        minimumSize: const Size.fromHeight(56),
                        side: BorderSide(color: AppColors.error),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.lgAll,
                        ),
                        textStyle: AppTypography.button,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Photo (or icon) with the title, back arrow and Edit over it.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.vehicle,
    required this.isDefault,
    required this.onEdit,
  });

  final SavedVehicle vehicle;
  final bool isDefault;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 340 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black, Colors.transparent],
              stops: [0, 0.7, 1],
            ).createShader(r),
            child: VehicleThumb(
              vehicle: vehicle,
              width: double.infinity,
              height: double.infinity,
              iconSize: 120,
              radius: BorderRadius.zero,
            ),
          ),
          Positioned(
            top: top,
            left: AppSpacing.s8,
            right: AppSpacing.screenGutter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  tooltip: 'Back',
                  icon: Icon(AppIcons.back, color: AppColors.textPrimary),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s12),
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Vehicle Details',
                      style: AppTypography.headingLarge.copyWith(fontSize: 26),
                    ),
                  ),
                ),
                Gap.v12,
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(AppIcons.edit, size: AppSizes.iconSm),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.background.withValues(
                        alpha: 0.5,
                      ),
                      side: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.4),
                      ),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isDefault)
            const Positioned(
              left: AppSpacing.screenGutter,
              bottom: AppSpacing.s8,
              child: DefaultTag(label: 'Default Vehicle'),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.vehicle});

  final SavedVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.local_gas_station_outlined, 'Fuel Type', vehicle.fuelType),
      (Icons.calendar_month_outlined, 'Year', vehicle.year?.toString() ?? '—'),
      (Icons.palette_outlined, 'Color', vehicle.color ?? '—'),
      (Icons.settings_outlined, 'Engine', vehicle.engine ?? '—'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (final (i, (icon, label, value)) in stats.indexed) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                ),
              Expanded(
                child: MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s16,
                      horizontal: AppSpacing.s4,
                    ),
                    child: Column(
                      children: [
                        Icon(icon, color: AppColors.brandCyan),
                        Gap.v8,
                        Text(label, style: AppTypography.caption),
                        Gap.v4,
                        Text(
                          value,
                          style: AppTypography.bodyStrong,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DocsCard extends StatelessWidget {
  const _DocsCard({required this.rows, required this.onTap});

  final List<(IconData, String, String)> rows;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, (icon, label, value)) in rows.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: AppColors.textPrimary.withValues(alpha: 0.06),
              ),
            ListTile(
              onTap: onTap,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s4,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(icon, color: AppColors.brandCyan),
              ),
              title: Text(label, style: AppTypography.caption),
              subtitle: Text(
                value,
                style: AppTypography.bodyStrong.copyWith(fontSize: 15),
              ),
              trailing: Icon(
                AppIcons.chevronRight,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
