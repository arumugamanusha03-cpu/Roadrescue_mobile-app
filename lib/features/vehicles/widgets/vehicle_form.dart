import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/vehicle_type.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../emergency_request/request_draft.dart';
import '../../emergency_request/vehicle_details_screen/vehicle_catalog.dart';
import '../../emergency_request/vehicle_details_screen/widgets/vehicle_type_selector.dart';
import '../../emergency_request/widgets/photo_tiles.dart';
import '../../emergency_request/widgets/request_fields.dart';
import '../../emergency_request/widgets/request_step_scaffold.dart';
import '../garage_provider.dart';
import '../saved_vehicle.dart';

/// Shared form behind Add Vehicle (26) and Edit Vehicle (28).
class VehicleForm extends StatefulWidget {
  const VehicleForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    required this.onSubmit,
    this.initial,
    this.showYearAndColor = false,
  });

  final String title;
  final String subtitle;
  final String submitLabel;
  final ValueChanged<SavedVehicle> onSubmit;
  final SavedVehicle? initial;

  /// Edit shows year and colour; Add keeps the first save short.
  final bool showYearAndColor;

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late VehicleType _type = widget.initial?.type ?? VehicleType.car;
  late String? _brand = widget.initial?.brand;
  late String? _model = widget.initial?.model;
  late String? _fuel = widget.initial?.fuelType;
  late int? _year = widget.initial?.year;
  late String? _color = widget.initial?.color;
  late PickedPhoto? _photo = widget.initial?.photo;
  late final _registration = TextEditingController(
    text: widget.initial?.registration,
  );
  // Free-text brand/model for "Other" vehicles.
  late final _brandText = TextEditingController(
    text: _isOther ? widget.initial?.brand : null,
  );
  late final _modelText = TextEditingController(
    text: _isOther ? widget.initial?.model : null,
  );

  bool get _isOther => _type == VehicleType.other;

  @override
  void dispose() {
    _registration.dispose();
    _brandText.dispose();
    _modelText.dispose();
    super.dispose();
  }

  String? _required(Object? v, String what) =>
      v == null || (v is String && v.trim().isEmpty)
      ? 'Select the $what.'
      : null;

  void _setType(VehicleType t) {
    if (t == _type) return;
    setState(() {
      _type = t;
      _brand = null;
      _model = null;
      final fuels = VehicleCatalog.fuelTypes(t);
      _fuel = fuels.length == 1 ? fuels.single : null;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final base = widget.initial;
    final vehicle = SavedVehicle(
      id: base?.id ?? GarageController.newId(),
      type: _type,
      brand: _isOther ? _brandText.text.trim() : _brand!,
      model: _isOther ? _modelText.text.trim() : _model!,
      registration: _registration.text.trim().toUpperCase(),
      fuelType: _fuel!,
      year: _year,
      color: _color,
      engine: base?.engine,
      chassisNumber: base?.chassisNumber,
      insuranceValidTill: base?.insuranceValidTill,
      pucValidTill: base?.pucValidTill,
      photo: _photo,
    );
    widget.onSubmit(vehicle);
  }

  Widget _icon(IconData icon) =>
      Icon(icon, color: AppColors.textSecondary, size: AppSizes.iconMd);

  @override
  Widget build(BuildContext context) {
    final fuels = VehicleCatalog.fuelTypes(_type);
    final textStyle = AppTypography.bodyLarge.copyWith(
      color: AppColors.textPrimary,
    );

    return RequestStepScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      bottom: GradientButton(label: widget.submitLabel, onPressed: _submit),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: AppColors.textPrimary.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FieldLabel('Vehicle Type'),
              VehicleTypeSelector(selected: _type, onChanged: _setType),
              Gap.v20,
              const FieldLabel('Brand'),
              if (_isOther)
                TextFormField(
                  controller: _brandText,
                  style: textStyle,
                  textCapitalization: TextCapitalization.words,
                  decoration: requestFieldDecoration(
                    hint: 'e.g. Force Motors',
                    prefix: _icon(AppIcons.vehicles),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Enter the brand.' : null,
                )
              else
                RequestDropdown(
                  value: _brand,
                  items: VehicleCatalog.brands(_type),
                  hint: 'Select brand',
                  prefix: _icon(AppIcons.vehicles),
                  onChanged: (b) => setState(() {
                    _brand = b;
                    _model = null;
                  }),
                  validator: (v) => _required(v, 'brand'),
                ),
              Gap.v16,
              const FieldLabel('Model'),
              if (_isOther)
                TextFormField(
                  controller: _modelText,
                  style: textStyle,
                  textCapitalization: TextCapitalization.words,
                  decoration: requestFieldDecoration(hint: 'e.g. Traveller'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Enter the model.' : null,
                )
              else
                RequestDropdown(
                  value: _model,
                  items: _brand == null
                      ? const []
                      : VehicleCatalog.models(_type, _brand!),
                  hint: _brand == null
                      ? 'Select a brand first'
                      : 'Select model',
                  onChanged: (m) => setState(() => _model = m),
                  validator: (v) => _required(v, 'model'),
                ),
              Gap.v16,
              const FieldLabel('Registration Number'),
              TextFormField(
                controller: _registration,
                style: textStyle,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                  LengthLimitingTextInputFormatter(13),
                ],
                decoration: requestFieldDecoration(
                  hint: 'TN 45 AB 1234',
                  prefix: const _IndPlateTag(),
                ),
                validator: VehicleCatalog.validatePlate,
              ),
              Gap.v16,
              const FieldLabel('Fuel Type'),
              RequestDropdown(
                value: _fuel,
                items: fuels,
                hint: 'Select fuel type',
                prefix: _icon(Icons.local_gas_station_outlined),
                onChanged: (f) => setState(() => _fuel = f),
                validator: (v) => _required(v, 'fuel type'),
              ),
              if (widget.showYearAndColor) ...[
                Gap.v16,
                const FieldLabel('Year of Manufacture'),
                RequestDropdown(
                  value: _year?.toString(),
                  items: [for (final y in VehicleColors.years()) '$y'],
                  hint: 'Select year',
                  onChanged: (y) => setState(() => _year = int.parse(y)),
                ),
                Gap.v16,
                const FieldLabel('Color'),
                RequestDropdown(
                  value: _color,
                  items: VehicleColors.swatches.keys.toList(),
                  hint: 'Select colour',
                  prefix: _color == null
                      ? _icon(Icons.palette_outlined)
                      : _ColorDot(VehicleColors.swatches[_color]!),
                  onChanged: (c) => setState(() => _color = c),
                ),
              ],
              Gap.v20,
              FieldLabel(
                widget.showYearAndColor
                    ? 'Upload Vehicle Photo'
                    : 'Upload Vehicle Photo (Optional)',
              ),
              PhotoTiles(
                photos: [?_photo],
                maxPhotos: 1,
                onAdd: () async {
                  final p = await pickPhoto(context);
                  if (p != null) setState(() => _photo = p);
                },
                onRemove: (_) => setState(() => _photo = null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blue "IND" plate tag at the start of the registration field.
class _IndPlateTag extends StatelessWidget {
  const _IndPlateTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      margin: const EdgeInsets.only(right: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.brandGradientEnd,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(AppRadius.md),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.blur_circular, size: 16, color: AppColors.onPrimary),
          Text(
            'IND',
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
          ),
        ),
      ),
    );
  }
}
