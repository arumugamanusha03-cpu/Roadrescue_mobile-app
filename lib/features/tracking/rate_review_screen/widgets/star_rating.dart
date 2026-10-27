import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Five tappable stars; each is its own 48dp target with a label.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          Semantics(
            button: true,
            selected: i <= value,
            label: '$i star${i == 1 ? '' : 's'}',
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => onChanged(i),
              radius: 28,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s4),
                child: AnimatedScale(
                  scale: i <= value ? 1 : 0.92,
                  duration: AppMotion.fast,
                  child: Icon(
                    i <= value
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 44,
                    color: i <= value
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
