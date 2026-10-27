import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../tracking/rescue_format.dart';
import '../../tracking/rescue_job.dart';
import '../../tracking/widgets/no_active_rescue.dart';
import '../../tracking/widgets/rescue_cards.dart';
import '../../tracking/widgets/rescue_scaffold.dart';
import 'widgets/payment_method_tile.dart';

/// 23. Bill breakdown and payment method.
///
/// TEMPORARY: no payment gateway yet. Paying only records the choice and
/// says so; no money moves.
class InvoicePaymentScreen extends ConsumerStatefulWidget {
  const InvoicePaymentScreen({super.key});

  @override
  ConsumerState<InvoicePaymentScreen> createState() =>
      _InvoicePaymentScreenState();
}

class _InvoicePaymentScreenState extends ConsumerState<InvoicePaymentScreen> {
  PaymentMethod _method = PaymentMethod.upi;
  bool _paying = false;

  Future<void> _pay(RescueJob job) async {
    setState(() => _paying = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ref.read(rescueJobProvider.notifier).markPaid();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _method == PaymentMethod.cash
              ? 'Please pay ${RescueFormat.rupees(job.total)} to your provider.'
              : 'Payments aren’t connected yet — nothing was charged.',
        ),
      ),
    );
    context.pushReplacement(AppRoutes.rescueRate);
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(rescueJobProvider);
    if (job == null) return const NoActiveRescue();
    final paid = job.stage == RescueStage.paid;

    return RescueScaffold(
      bottom: paid
          ? GradientButton(
              label: 'Rate Provider',
              onPressed: () => context.pushReplacement(AppRoutes.rescueRate),
            )
          : GradientButton(
              label: 'Pay ${RescueFormat.rupees(job.total)}',
              isLoading: _paying,
              onPressed: () => _pay(job),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Invoice & Payment',
              textAlign: TextAlign.center,
              style: AppTypography.headingLarge.copyWith(fontSize: 24),
            ),
          ),
          Gap.v24,
          RescueCard(
            child: Column(
              children: [
                _Line('Request ID', '#${job.requestId}'),
                _Line('Service Type', job.service.shortLabel),
                _Line('Service Charge', RescueFormat.rupees(job.serviceCharge)),
                _Line(
                  'Convenience Fee',
                  RescueFormat.rupees(job.convenienceFee),
                ),
                Divider(
                  height: AppSpacing.s24,
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                ),
                MergeSemantics(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total Amount',
                          style: AppTypography.cardTitle,
                        ),
                      ),
                      Text(
                        RescueFormat.rupees(job.total),
                        style: AppTypography.headingSection.copyWith(
                          color: AppColors.brandCyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push(AppRoutes.invoice(job.requestId)),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('View Invoice PDF'),
              style: TextButton.styleFrom(foregroundColor: AppColors.brandCyan),
            ),
          ),
          Gap.v12,
          Text(
            paid ? 'Payment recorded' : 'Select Payment Method',
            style: AppTypography.cardTitle.copyWith(fontSize: 15),
          ),
          Gap.v12,
          for (final m in PaymentMethod.values) ...[
            PaymentMethodTile(
              method: m,
              selected: m == _method,
              onTap: paid ? () {} : () => setState(() => _method = m),
            ),
            Gap.v12,
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Text(value, style: AppTypography.bodyStrong),
          ],
        ),
      ),
    );
  }
}
