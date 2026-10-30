import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_version_label.dart';

import '../controllers/connection_mode_controller.dart';

/// Screen allowing the user to choose their operational mode:
/// 1. Synced with the Shop Web App (Laravel dedicated backend via QR pairing)
/// 2. Standalone Mobile App (Direct cloud/Firebase without local web server)
///
/// Designed to flawlessly harmonize with the SurfDesk dark/light ocean theme.
class ConnectionModeView extends GetView<ConnectionModeController> {
  const ConnectionModeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Ambient ocean glow at top center (signature SurfDesk atmospheric lighting)
          Positioned(
            top: -90,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.14),
                      colorScheme.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: ResponsiveCenter(
              maxWidth: 440,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 680;

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: isCompact ? AppSpacing.xs : AppSpacing.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 1. Header Section
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: isCompact ? 48 : 54,
                                    height: isCompact ? 48 : 54,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: AppRadius.lgAll,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.16,
                                          ),
                                          blurRadius: 18,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.8),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: AppRadius.lgAll,
                                      child: Image.asset(
                                        'assets/appstore.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  AppSpacing.gapSm,
                                  Text(
                                    'How will you use SurfDesk?',
                                    textAlign: TextAlign.center,
                                    style:
                                        (isCompact
                                                ? textTheme.titleLarge
                                                : textTheme.headlineSmall)
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.5,
                                            ),
                                  ),
                                  AppSpacing.gapXxs,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                    ),
                                    child: Text(
                                      'Select the setup that matches your shop and daily workflow.',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // 2. Option 1: Shop Web App Users (Primary Ocean Blue)
                              Obx(
                                () => _ModeOptionCard(
                                  isSelected:
                                      controller.selectedMode.value ==
                                      BackendProviderType.laravel,
                                  icon: Iconsax.monitor_mobbile,
                                  badgeText: 'Shop Web System',
                                  accentColor: colorScheme.primary,
                                  title: 'Connect with Shop Web App',
                                  description: 'Pair this phone by scanning the QR code on your SurfDesk web dashboard.',
                                  featurePills: const [
                                    'Live Web Sync',
                                    'Terminal Mode',
                                  ],
                                  onTap: controller.selectWebShopMode,
                                ),
                              ),

                              // 3. Option 2: Standalone Mobile Users (Primary Teal)
                              Obx(
                                () => _ModeOptionCard(
                                  isSelected:
                                      controller.selectedMode.value ==
                                      BackendProviderType.firebase,
                                  icon: Iconsax.mobile,
                                  badgeText: 'Mobile Only',
                                  accentColor: colorScheme.secondary,
                                  title: 'Use Mobile App Only',
                                  description: 'Use SurfDesk directly on your phone with independent cloud storage.',
                                  featurePills: const [
                                    'Direct Phone Access',
                                    'No Server Needed',
                                  ],
                                  onTap: controller.selectStandaloneMobileMode,
                                ),
                              ),

                              // 4. Footer Section
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Icon(
                                      //   Iconsax.info_circle,
                                      //   size: 14,
                                      //   color: colorScheme.onSurfaceVariant,
                                      // ),
                                      // AppSpacing.gapXs,
                                      Flexible(
                                        child: Text(
                                          'You can switch your setup mode at any time in Settings.',
                                          textAlign: TextAlign.center,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapXxl,
                                  AppVersionLabel(
                                    prefix: 'SurfDesk v',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String badgeText;
  final Color accentColor;
  final String title;
  final String description;
  final List<String> featurePills;
  final VoidCallback onTap;

  const _ModeOptionCard({
    required this.isSelected,
    required this.icon,
    required this.badgeText,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.featurePills,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        splashColor: accentColor.withValues(alpha: 0.08),
        highlightColor: accentColor.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : colorScheme.outlineVariant.withValues(alpha: 0.7),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 14 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon container + Badge + Chevron / Check
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  AppSpacing.gapSm,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: AppRadius.fullAll,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: textTheme.labelSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor
                          : colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : colorScheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(
                      isSelected ? Iconsax.tick_circle : Iconsax.arrow_right_3,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapSm,

              // Title
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
              AppSpacing.gapXxs,

              // Description
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
              AppSpacing.gapXs,

              // Feature Pills
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: featurePills.map((pill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: AppRadius.smAll,
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      pill,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
