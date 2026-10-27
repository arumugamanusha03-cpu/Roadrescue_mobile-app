import 'package:flutter/material.dart';

import '../../../../core/constants/request_status.dart';
import '../../../../core/constants/service_type.dart';
import '../../../../core/constants/vehicle_type.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/shared.dart';
import 'ds_foundations.dart';

/// Every shared component in its main states.
class DsComponents extends StatelessWidget {
  const DsComponents({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsSection(
          title: 'Image treatment',
          subtitle: 'ScrimImage · hero composition',
          child: _HeroDemo(),
        ),
        DsSection(title: 'Buttons', child: _Buttons()),
        DsSection(title: 'Inputs', child: _Inputs()),
        DsSection(
          title: 'Status',
          subtitle: 'Text + icon, never colour alone',
          child: _Chips(),
        ),
        DsSection(
          title: 'Service cards',
          subtitle: 'Tap to select',
          child: _ServiceCards(),
        ),
        DsSection(title: 'Request & provider', child: _RequestCards()),
        DsSection(title: 'Vehicles & location', child: _VehicleAndLocation()),
        DsSection(
          title: 'Map overlay',
          subtitle: 'The only glass in the app',
          child: _MapOverlayDemo(),
        ),
        DsSection(title: 'Bottom navigation', child: _NavDemo()),
        DsSection(title: 'States', child: _States()),
        DsSection(title: 'Sheets', child: _Sheets()),
      ],
    );
  }
}

class _HeroDemo extends StatelessWidget {
  const _HeroDemo();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 280),
      child: ScrimImage(
        borderRadius: AppRadius.hero,
        child: Padding(
          padding: AppSpacing.cardInsetsLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Photography slot', style: AppTypography.caption),
              Gap.v8,
              Text('Need help on the road?', style: AppTypography.headingLarge),
              Gap.v8,
              Text(
                'Find fast assistance from verified providers.',
                style: AppTypography.bodyLarge,
              ),
              Gap.v20,
              PrimaryButton(
                label: 'Get Help Now',
                emphasized: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Buttons extends StatefulWidget {
  const _Buttons();

  @override
  State<_Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<_Buttons> {
  bool _loading = false;

  Future<void> _simulate() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DsLabel('Variants'),
        PrimaryButton(
          label: 'Request Assistance',
          emphasized: true,
          isLoading: _loading,
          onPressed: _simulate,
        ),
        Gap.v12,
        SecondaryButton(
          label: 'Message',
          leadingIcon: AppIcons.message,
          onPressed: () {},
        ),
        Gap.v12,
        AppButton(
          label: 'Cancel Request',
          variant: AppButtonVariant.danger,
          onPressed: () {},
        ),
        Gap.v12,
        AppButton(
          label: 'Not Now',
          variant: AppButtonVariant.tertiary,
          onPressed: () {},
        ),
        const DsLabel('Sizes'),
        Wrap(
          spacing: AppSpacing.s12,
          runSpacing: AppSpacing.s12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PrimaryButton(label: 'Large', expand: false, onPressed: () {}),
            PrimaryButton(
              label: 'Medium',
              size: AppButtonSize.medium,
              expand: false,
              onPressed: () {},
            ),
            PrimaryButton(
              label: 'Small',
              size: AppButtonSize.small,
              expand: false,
              onPressed: () {},
            ),
          ],
        ),
        const DsLabel('Disabled'),
        const Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Continue',
                onPressed: null,
                size: AppButtonSize.medium,
              ),
            ),
            Gap.h12,
            Expanded(
              child: SecondaryButton(
                label: 'Skip',
                onPressed: null,
                size: AppButtonSize.medium,
              ),
            ),
          ],
        ),
        const DsLabel('Icon buttons'),
        Row(
          children: [
            AppIconButton(
              icon: AppIcons.back,
              semanticLabel: 'Back',
              onPressed: () {},
            ),
            Gap.h12,
            AppIconButton(
              icon: AppIcons.notifications,
              semanticLabel: 'Notifications, 2 unread',
              variant: AppIconButtonVariant.filled,
              showBadge: true,
              onPressed: () {},
            ),
            Gap.h12,
            AppIconButton(
              icon: AppIcons.call,
              semanticLabel: 'Call provider',
              variant: AppIconButtonVariant.filled,
              iconColor: AppColors.iceBlue,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _Inputs extends StatelessWidget {
  const _Inputs();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Email',
          hint: 'you@example.com',
          prefixIcon: AppIcons.email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: [AutofillHints.email],
        ),
        Gap.v20,
        AppTextField(
          label: 'Password',
          hint: 'At least 8 characters',
          prefixIcon: AppIcons.lock,
          isPassword: true,
        ),
        Gap.v20,
        AppTextField(
          label: 'Registration number',
          hint: 'KA 01 AB 1234',
          errorText: 'Enter the number exactly as it appears on the plate.',
          textCapitalization: TextCapitalization.characters,
        ),
        Gap.v20,
        AppTextField(
          label: 'Notes for the provider',
          hint: 'Landmarks, what happened, anything that helps',
          isOptional: true,
          maxLines: 4,
          minLines: 3,
        ),
        Gap.v20,
        SearchField(hint: 'Search for a road or landmark'),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DsLabel('Request lifecycle'),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final s in RequestStatus.values) StatusChip.request(s),
          ],
        ),
        const DsLabel('Tones'),
        const Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            StatusChip(label: 'Offline'),
            StatusChip(label: 'Available', tone: StatusTone.brand),
            StatusChip(
              label: 'Paid',
              tone: StatusTone.success,
              icon: AppIcons.success,
            ),
            StatusChip(
              label: 'Running late',
              tone: StatusTone.warning,
              icon: AppIcons.warning,
            ),
            StatusChip(
              label: 'Emergency',
              tone: StatusTone.error,
              icon: AppIcons.emergency,
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceCards extends StatefulWidget {
  const _ServiceCards();

  @override
  State<_ServiceCards> createState() => _ServiceCardsState();
}

class _ServiceCardsState extends State<_ServiceCards> {
  ServiceType? _selected = ServiceType.battery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DsLabel('Tile · Select Service Type'),
        AdaptiveGrid(
          children: [
            for (final type in ServiceType.values)
              ServiceCard(
                type: type,
                selected: type == _selected,
                onTap: () => setState(() => _selected = type),
              ),
          ],
        ),
        const DsLabel('Compact · home categories'),
        AdaptiveGrid(
          minTileWidth: 72,
          spacing: AppSpacing.s8,
          children: [
            for (final type in ServiceType.values)
              ServiceCard(
                type: type,
                layout: ServiceCardLayout.compact,
                onTap: () {},
              ),
          ],
        ),
      ],
    );
  }
}

class _RequestCards extends StatefulWidget {
  const _RequestCards();

  @override
  State<_RequestCards> createState() => _RequestCardsState();
}

class _RequestCardsState extends State<_RequestCards> {
  static const _cycle = [
    RequestStatus.searching,
    RequestStatus.accepted,
    RequestStatus.onTheWay,
    RequestStatus.arrived,
    RequestStatus.inProgress,
  ];
  int _index = 2;

  @override
  Widget build(BuildContext context) {
    final status = _cycle[_index];
    final assigned = status != RequestStatus.searching;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DsLabel('Active request'),
        ActiveRequestCard(
          status: status,
          serviceType: ServiceType.battery,
          providerName: assigned ? 'Arjun Menon' : null,
          providerRating: assigned ? 4.8 : null,
          etaMinutes: status == RequestStatus.onTheWay ? 12 : null,
          distanceKm: status == RequestStatus.onTheWay ? 3.4 : null,
          onViewTracking: () {},
        ),
        Gap.v12,
        AppButton(
          label: 'Advance status',
          variant: AppButtonVariant.tertiary,
          size: AppButtonSize.small,
          onPressed: () =>
              setState(() => _index = (_index + 1) % _cycle.length),
        ),
        const DsLabel('No active request'),
        const EmptyState(
          compact: true,
          icon: AppIcons.success,
          title: 'No active assistance',
          message: 'Requests you make will appear here.',
        ),
        const DsLabel('Provider'),
        ProviderCard(
          name: 'Priya Raghavan',
          rating: 4.9,
          subtitle: 'Tyre & battery · 1.8 km',
          trailing: AppIconButton(
            icon: AppIcons.call,
            semanticLabel: 'Call Priya Raghavan',
            variant: AppIconButtonVariant.filled,
            iconColor: AppColors.iceBlue,
            onPressed: () {},
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

class _VehicleAndLocation extends StatefulWidget {
  const _VehicleAndLocation();

  @override
  State<_VehicleAndLocation> createState() => _VehicleAndLocationState();
}

class _VehicleAndLocationState extends State<_VehicleAndLocation> {
  int _selected = 0;

  static const _vehicles = [
    (VehicleType.car, 'Hyundai Creta', 'KA 05 MN 2231', 'Diesel'),
    (VehicleType.ev, 'Tata Nexon EV', 'KA 03 EV 0912', '40.5 kWh'),
    (VehicleType.bike, 'Royal Enfield Classic', 'KA 01 HK 7710', 'Petrol'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (type, name, reg, detail)) in _vehicles.indexed) ...[
          if (i > 0) Gap.v12,
          VehicleCard(
            type: type,
            name: name,
            registration: reg,
            detail: detail,
            selected: i == _selected,
            onTap: () => setState(() => _selected = i),
          ),
        ],
        Gap.v20,
        LocationCard(
          title: 'Current location',
          address: 'Outer Ring Road, near Silk Board Junction, Bengaluru',
          isCurrentLocation: true,
          onChange: () {},
        ),
      ],
    );
  }
}

class _MapOverlayDemo extends StatelessWidget {
  const _MapOverlayDemo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.hero,
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _MapStubPainter()),
            ),
            MapOverlay(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.eta,
                    size: AppSizes.iconMd,
                    color: AppColors.iceBlue,
                  ),
                  Gap.h8,
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: 'Arriving in ',
                        children: [
                          TextSpan(
                            text: '12 min',
                            style: AppTypography.bodyStrong,
                          ),
                        ],
                      ),
                      style: AppTypography.body,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: AppSpacing.s16,
              bottom: AppSpacing.s16,
              child: AppIconButton(
                icon: AppIcons.myLocation,
                semanticLabel: 'Centre on my location',
                variant: AppIconButtonVariant.glass,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stand-in for the dark map tiles so the overlay can be judged in context.
class _MapStubPainter extends CustomPainter {
  const _MapStubPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.backgroundSecondary,
    );

    final road = Paint()
      ..color = AppColors.surfaceElevated
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    canvas
      ..drawLine(
        Offset(0, size.height * 0.62),
        Offset(size.width, size.height * 0.48),
        road,
      )
      ..drawLine(
        Offset(size.width * 0.3, 0),
        Offset(size.width * 0.42, size.height),
        road,
      )
      ..drawLine(
        Offset(size.width * 0.78, 0),
        Offset(size.width * 0.7, size.height),
        road..strokeWidth = 6,
      );

    final route = Path()
      ..moveTo(size.width * 0.74, size.height * 0.2)
      ..lineTo(size.width * 0.72, size.height * 0.5)
      ..lineTo(size.width * 0.39, size.height * 0.55)
      ..lineTo(size.width * 0.37, size.height * 0.78);
    canvas.drawPath(
      route,
      Paint()
        ..color = AppColors.primarySecondary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    void marker(Offset c, Color color) {
      canvas
        ..drawCircle(c, 14, Paint()..color = color.withValues(alpha: 0.25))
        ..drawCircle(c, 7, Paint()..color = color)
        ..drawCircle(
          c,
          7,
          Paint()
            ..color = AppColors.textPrimary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }

    marker(Offset(size.width * 0.74, size.height * 0.2), AppColors.iceBlue);
    marker(Offset(size.width * 0.37, size.height * 0.78), AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavDemo extends StatefulWidget {
  const _NavDemo();

  @override
  State<_NavDemo> createState() => _NavDemoState();
}

class _NavDemoState extends State<_NavDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.card,
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: AppBottomNavigation(
          items: const [
            AppNavItem(
              label: 'Home',
              icon: AppIcons.home,
              selectedIcon: AppIcons.homeSelected,
            ),
            AppNavItem(
              label: 'Vehicles',
              icon: AppIcons.vehicles,
              selectedIcon: AppIcons.vehiclesSelected,
            ),
            AppNavItem(
              label: 'Tracking',
              icon: AppIcons.tracking,
              selectedIcon: AppIcons.trackingSelected,
            ),
            AppNavItem(
              label: 'Profile',
              icon: AppIcons.profile,
              selectedIcon: AppIcons.profileSelected,
            ),
          ],
          currentIndex: _index,
          onSelected: (i) => setState(() => _index = i),
          centerAction: AppNavAction(
            label: 'Get Help',
            icon: AppIcons.getHelp,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

class _States extends StatelessWidget {
  const _States();

  @override
  Widget build(BuildContext context) {
    Widget frame(Widget child) => Container(
      decoration: AppElevation.card(radius: AppRadius.card),
      child: child,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DsLabel('Loading'),
        frame(const LoadingState(message: 'Finding providers near you')),
        const DsLabel('Skeleton'),
        frame(
          const Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              children: [
                SkeletonBox(
                  width: AppSizes.avatarLg,
                  height: AppSizes.avatarLg,
                ),
                Gap.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 160, height: AppSpacing.s16),
                      Gap.v8,
                      SkeletonBox(width: 100, height: AppSpacing.s12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const DsLabel('Empty'),
        frame(
          EmptyState(
            icon: AppIcons.history,
            title: 'No service history yet',
            message: 'Completed requests and invoices will appear here.',
            actionLabel: 'Add a vehicle',
            onAction: () {},
          ),
        ),
        const DsLabel('Error'),
        frame(ErrorState.offline(onRetry: () {})),
      ],
    );
  }
}

class _Sheets extends StatelessWidget {
  const _Sheets();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecondaryButton(
          label: 'Open bottom sheet',
          size: AppButtonSize.medium,
          onPressed: () => AppBottomSheet.show<void>(
            context,
            title: 'Pickup location',
            builder: (_) => const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchField(hint: 'Search for a road or landmark'),
                Gap.v16,
                LocationCard(
                  title: 'Current location',
                  address: 'Outer Ring Road, near Silk Board Junction',
                  isCurrentLocation: true,
                ),
              ],
            ),
          ),
        ),
        Gap.v12,
        SecondaryButton(
          label: 'Open confirmation sheet',
          size: AppButtonSize.medium,
          onPressed: () async {
            final confirmed = await ConfirmationSheet.show(
              context,
              title: 'Cancel this request?',
              message:
                  'Your provider is already on the way. A cancellation fee '
                  'may apply.',
              confirmLabel: 'Cancel Request',
              cancelLabel: 'Keep Request',
              isDestructive: true,
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(confirmed ? 'Request cancelled' : 'Request kept'),
              ),
            );
          },
        ),
      ],
    );
  }
}
