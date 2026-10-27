import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Dots: the active one is brand cyan with a soft glow.
class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${index + 1} of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) Gap.h12,
            AnimatedContainer(
              duration: AppMotion.standard,
              curve: AppMotion.standardCurve,
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == index
                    ? AppColorsDark.brandCyan
                    : AppColorsDark.textMuted.withValues(alpha: 0.35),
                boxShadow: i == index
                    ? [
                        BoxShadow(
                          color: AppColorsDark.brandCyan.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
