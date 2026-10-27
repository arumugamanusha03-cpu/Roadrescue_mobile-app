import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Circle with the person's initials (until profile photos exist).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 76});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Semantics(
      image: true,
      label: name,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.brandGradientStart, AppColors.brandGradientEnd],
          ),
        ),
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: AppTypography.headingSection.copyWith(
            fontSize: size * 0.34,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}

/// Rounded card that groups menu rows, with hairlines between them.
class MenuGroup extends StatelessWidget {
  const MenuGroup({super.key, required this.children});

  final List<Widget> children;

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
          for (final (i, c) in children.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 64,
                color: AppColors.textPrimary.withValues(alpha: 0.06),
              ),
            c,
          ],
        ],
      ),
    );
  }
}

/// Icon, title, subtitle, chevron.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minVerticalPadding: AppSpacing.s12,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      leading: Icon(icon, color: AppColors.brandCyan, size: 28),
      title: Text(title, style: AppTypography.cardTitle),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
      trailing:
          trailing ??
          (onTap == null
              ? null
              : Icon(AppIcons.chevronRight, color: AppColors.textSecondary)),
    );
  }
}

/// Uppercase-free small heading above a settings group.
class GroupHeading extends StatelessWidget {
  const GroupHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.s4,
        bottom: AppSpacing.s8,
        top: AppSpacing.s20,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: AppTypography.label.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
