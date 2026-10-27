import 'package:flutter/material.dart';

import '../../../../core/constants/service_type.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/shared.dart';

/// Foundations: colour, type, spacing, radius, icons.
class DsFoundations extends StatelessWidget {
  const DsFoundations({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsSection(
          title: 'Colour',
          subtitle:
              'Blue acts. Ice blue highlights. Green and red only for '
              'outcomes.',
          child: _ColourPalette(),
        ),
        DsSection(
          title: 'Typography',
          subtitle: 'Inter, bundled',
          child: _TypeScale(),
        ),
        DsSection(
          title: 'Spacing',
          subtitle: '8-point scale',
          child: _SpacingScale(),
        ),
        DsSection(
          title: 'Radius',
          subtitle: 'Larger = more prominent',
          child: _RadiusScale(),
        ),
        DsSection(
          title: 'Icons',
          subtitle: 'Material, outlined by default, filled when selected',
          child: _IconSet(),
        ),
      ],
    );
  }
}

/// A titled block on the design system page.
class DsSection extends StatelessWidget {
  const DsSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          Gap.v16,
          child,
        ],
      ),
    );
  }
}

/// Small caption above a group of examples.
class DsLabel extends StatelessWidget {
  const DsLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8, top: AppSpacing.s8),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.caption.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Swatch {
  const _Swatch(this.name, this.color, this.usage);

  final String name;
  final Color color;
  final String usage;
}

class _ColourPalette extends StatelessWidget {
  const _ColourPalette();

  static final _groups = {
    'Surfaces': [
      _Swatch('Background', AppColors.background, 'Screen base'),
      _Swatch('Background 2', AppColors.backgroundSecondary, 'Bars, sheets'),
      _Swatch('Surface', AppColors.surface, 'Cards, inputs'),
      _Swatch('Elevated', AppColors.surfaceElevated, 'Raised cards, tiles'),
      _Swatch('Divider', AppColors.divider, 'Borders, rules'),
    ],
    'Brand': [
      _Swatch('Primary', AppColors.primary, 'CTAs, selection'),
      _Swatch('Secondary', AppColors.primarySecondary, 'Routes, accents'),
      _Swatch('Ice blue', AppColors.iceBlue, 'Selected icons, links'),
      _Swatch('Interaction', AppColors.interactionBlue, 'Press, focus'),
    ],
    'Text': [
      _Swatch('Primary', AppColors.textPrimary, 'Headings, values'),
      _Swatch('Secondary', AppColors.textSecondary, 'Body copy'),
      _Swatch('Muted', AppColors.textMuted, 'Metadata, hints'),
    ],
    'Status': [
      _Swatch('Success', AppColors.success, 'Completed only'),
      _Swatch('Warning', AppColors.warning, 'Delays, pending'),
      _Swatch('Error', AppColors.error, 'Emergency, errors'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final MapEntry(key: group, value: swatches)
            in _groups.entries) ...[
          DsLabel(group),
          AdaptiveGrid(
            minTileWidth: 140,
            children: [for (final s in swatches) _SwatchTile(swatch: s)],
          ),
          Gap.v16,
        ],
      ],
    );
  }
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile({required this.swatch});

  final _Swatch swatch;

  String get _hex =>
      '#${(swatch.color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppElevation.card(radius: AppRadius.mdAll),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: AppSpacing.s48,
            decoration: BoxDecoration(
              color: swatch.color,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(swatch.name, style: AppTypography.bodyStrong),
                Text(
                  _hex,
                  style: AppTypography.caption.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Gap.v4,
                Text(swatch.usage, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  static final _styles = [
    ('Display', '34 / 700', AppTypography.display, 'Get back on the road'),
    (
      'Heading large',
      '28 / 700',
      AppTypography.headingLarge,
      'Need help on the road?',
    ),
    (
      'Section heading',
      '20 / 600',
      AppTypography.headingSection,
      'Active request',
    ),
    ('Card title', '16 / 600', AppTypography.cardTitle, 'Dead Battery'),
    (
      'Body large',
      '16 / 400',
      AppTypography.bodyLarge,
      'Find fast assistance from verified providers.',
    ),
    (
      'Body',
      '14 / 400',
      AppTypography.body,
      'Your provider will call when they are five minutes away.',
    ),
    ('Body strong', '14 / 500', AppTypography.bodyStrong, 'Arrives in 12 min'),
    ('Label', '12 / 500', AppTypography.label, 'Registration number'),
    ('Caption', '12 / 400', AppTypography.caption, 'Updated 2 min ago'),
    ('Button', '16 / 600', AppTypography.button, 'Request Assistance'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.cardInsetsLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (name, spec, style, sample)) in _styles.indexed) ...[
            if (i > 0) const Divider(height: AppSpacing.s32),
            Row(
              children: [
                Expanded(child: Text(name, style: AppTypography.caption)),
                Text(spec, style: AppTypography.caption),
              ],
            ),
            Gap.v8,
            Text(
              sample,
              style: style.copyWith(
                color: style.color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpacingScale extends StatelessWidget {
  const _SpacingScale();

  static const _values = [
    (AppSpacing.s4, 'Icon–label'),
    (AppSpacing.s8, 'Tight groups'),
    (AppSpacing.s12, 'Grid gaps'),
    (AppSpacing.s16, 'Card padding'),
    (AppSpacing.s20, 'Screen gutter'),
    (AppSpacing.s24, 'Sheet padding'),
    (AppSpacing.s32, 'Section gap'),
    (AppSpacing.s40, ''),
    (AppSpacing.s48, ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (value, usage) in _values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Row(
              children: [
                SizedBox(
                  width: AppSpacing.s32,
                  child: Text(
                    value.toInt().toString(),
                    style: AppTypography.bodyStrong,
                  ),
                ),
                Container(
                  width: value * 2,
                  height: AppSpacing.s12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.smAll,
                  ),
                ),
                Gap.h12,
                Expanded(child: Text(usage, style: AppTypography.caption)),
              ],
            ),
          ),
      ],
    );
  }
}

class _RadiusScale extends StatelessWidget {
  const _RadiusScale();

  static const _values = [
    (AppRadius.sm, 'sm', 'Thumbnails'),
    (AppRadius.md, 'md', 'Buttons, inputs'),
    (AppRadius.lg, 'lg', 'Cards'),
    (AppRadius.xl, 'xl', 'Active request'),
    (AppRadius.xxl, 'xxl', 'Hero, sheets'),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveGrid(
      minTileWidth: 96,
      maxColumns: 5,
      children: [
        for (final (radius, name, usage) in _values)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: AppColors.primarySecondary),
                  ),
                ),
              ),
              Gap.v8,
              Text(
                '$name · ${radius.toInt()}',
                style: AppTypography.bodyStrong,
              ),
              Text(usage, style: AppTypography.caption),
            ],
          ),
      ],
    );
  }
}

class _IconSet extends StatelessWidget {
  const _IconSet();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DsLabel('Services · default and selected'),
        AppCard(
          child: AdaptiveGrid(
            minTileWidth: 120,
            children: [
              for (final type in ServiceType.values)
                Row(
                  children: [
                    Icon(
                      AppIcons.service(type),
                      size: AppSizes.iconLg,
                      color: AppColors.textSecondary,
                    ),
                    Gap.h8,
                    Icon(
                      AppIcons.service(type, selected: true),
                      size: AppSizes.iconLg,
                      color: AppColors.iceBlue,
                    ),
                    Gap.h12,
                    Expanded(
                      child: Text(
                        type.shortLabel,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const DsLabel('Sizes'),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final size in const [
                AppSizes.iconXs,
                AppSizes.iconSm,
                AppSizes.iconMd,
                AppSizes.iconLg,
                AppSizes.iconXl,
              ])
                Column(
                  children: [
                    Icon(
                      AppIcons.location,
                      size: size,
                      color: AppColors.iceBlue,
                    ),
                    Gap.v8,
                    Text(size.toInt().toString(), style: AppTypography.caption),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
