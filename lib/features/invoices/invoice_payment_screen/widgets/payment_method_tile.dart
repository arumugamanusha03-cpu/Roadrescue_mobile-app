import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

enum PaymentMethod {
  upi('UPI (GPay, PhonePe, Paytm)'),
  card('Credit / Debit Card'),
  cash('Cash (Pay to Provider)');

  const PaymentMethod(this.label);

  final String label;
}

/// Radio card for one payment method; the selected one gets a cyan border.
class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: method.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: selected
                ? AppColors.brandGradientEnd
                : AppColors.textPrimary.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.brandGradientEnd
                            : AppColors.textSecondary,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: selected
                        ? DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.brandGradientEnd,
                            ),
                          )
                        : null,
                  ),
                  Gap.h16,
                  Expanded(
                    child: Text(
                      method.label,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
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
