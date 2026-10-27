import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../rescue_job.dart';
import '../widgets/no_active_rescue.dart';
import '../widgets/rescue_cards.dart';
import '../widgets/rescue_scaffold.dart';

/// 18. Who is coming, in what, and how to reach them.
class ProviderDetailsScreen extends ConsumerWidget {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(rescueJobProvider);
    final p = job?.provider;
    if (job == null || p == null) return const NoActiveRescue();

    return RescueScaffold(
      bottom: GradientButton(
        label: 'Live Tracking',
        icon: Icons.navigation,
        onPressed: () => context.push(AppRoutes.liveTracking),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Provider Details',
              style: AppTypography.headingLarge.copyWith(fontSize: 26),
            ),
          ),
          Gap.v20,
          RescueCard(
            child: Row(
              children: [
                Expanded(child: RescueProviderRow(provider: p)),
                RoundContactButton(
                  icon: AppIcons.call,
                  label: 'Call ${p.name}',
                  onPressed: () => callProvider(context, p),
                ),
              ],
            ),
          ),
          Gap.v12,
          RescueCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Fact(label: 'Vehicle', value: p.vehicleType),
                    ),
                    Container(
                      width: 96,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.mdAll,
                        color: AppColors.surfaceElevated,
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        size: 36,
                        color: AppColors.textPrimary,
                        semanticLabel: 'Service vehicle',
                      ),
                    ),
                  ],
                ),
                _rule(),
                _Fact(label: 'Vehicle Number', value: p.vehicleNumber),
                _rule(),
                Row(
                  children: [
                    Expanded(
                      child: _Fact(label: 'Experience', value: p.experience),
                    ),
                    Expanded(
                      child: _Fact(
                        label: 'Total Services',
                        value: p.totalServices,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap.v12,
          Row(
            children: [
              _ActionTile(
                icon: AppIcons.call,
                label: 'Call',
                onTap: () => callProvider(context, p),
              ),
              Gap.h12,
              _ActionTile(
                icon: Icons.mark_chat_unread_outlined,
                label: 'Message',
                onTap: () => messageProvider(context, p),
              ),
              Gap.h12,
              _ActionTile(
                icon: AppIcons.share,
                label: 'Share',
                onTap: () => _share(context, job),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rule() => Divider(
    height: AppSpacing.s32,
    color: AppColors.textPrimary.withValues(alpha: 0.06),
  );

  /// No share sheet plugin yet, so copy a status line to the clipboard.
  Future<void> _share(BuildContext context, RescueJob job) async {
    final p = job.provider!;
    await Clipboard.setData(
      ClipboardData(
        text:
            'RoadRescue request #${job.requestId}: ${p.name} '
            '(${p.vehicleLine}) is on the way.',
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip details copied. Paste to share.')),
      );
    }
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          Gap.v4,
          Text(value, style: AppTypography.bodyStrong.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
            side: BorderSide(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.lgAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Column(
                children: [
                  Icon(icon, color: AppColors.brandCyan),
                  Gap.v8,
                  Text(
                    label,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
