import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Full-area loading with an optional line of context ("Finding providers
/// near you"). Use [SkeletonBox] instead when the layout is known.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Semantics(
          liveRegion: true,
          label: message ?? 'Loading',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox.square(
                dimension: AppSizes.iconXl,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              if (message != null) ...[
                Gap.v16,
                Text(
                  message!,
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder block that gently pulses while content loads.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.mdAll,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: widget.borderRadius,
      ),
    );
    if (reduceMotion) return box;

    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.45,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: box,
    );
  }
}
