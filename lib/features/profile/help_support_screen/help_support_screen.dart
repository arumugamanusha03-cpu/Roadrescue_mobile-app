import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../tracking/widgets/rescue_scaffold.dart';
import '../widgets/profile_widgets.dart';

/// FAQs and ways to reach support.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    (
      'How fast will help arrive?',
      'Most providers arrive in 10–15 minutes in the city; towing and '
          'accidents can take 20–30 minutes. You see a live ETA once a '
          'provider accepts.',
    ),
    (
      'How is the price decided?',
      'You see an estimated range before you request. The final amount is '
          'on your invoice after the service, including a small convenience '
          'fee.',
    ),
    (
      'Can I cancel a request?',
      'Yes, before the provider arrives. A cancellation fee may apply once '
          'the provider is on the way.',
    ),
    (
      'Are providers verified?',
      'Every provider’s identity, licence and service vehicle are checked '
          'before they can accept requests.',
    ),
    (
      'What if it’s an emergency?',
      'If anyone is hurt or in danger, call your local emergency number (112 '
          'in India) first, then request towing here.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    void notYet() => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Support contact details will be added soon.'),
        ),
      );

    return RescueScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Help & Support',
              style: AppTypography.headingLarge.copyWith(fontSize: 26),
            ),
          ),
          const GroupHeading('Frequently asked questions'),
          MenuGroup(
            children: [
              for (final (q, a) in _faqs)
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    iconColor: AppColors.brandCyan,
                    collapsedIconColor: AppColors.textSecondary,
                    title: Text(q, style: AppTypography.bodyStrong),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      0,
                      AppSpacing.s16,
                      AppSpacing.s16,
                    ),
                    children: [Text(a, style: AppTypography.body)],
                  ),
                ),
            ],
          ),
          const GroupHeading('Contact us'),
          MenuGroup(
            children: [
              MenuRow(
                icon: Icons.call_outlined,
                title: 'Call support',
                subtitle: '24×7 roadside helpline',
                onTap: notYet,
              ),
              MenuRow(
                icon: Icons.mail_outline,
                title: 'Email support',
                subtitle: 'We reply within a day',
                onTap: notYet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
