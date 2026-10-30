import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custom_button.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';

import '../controllers/connection_mode_controller.dart';

/// Informational landing view for Standalone Mobile Users (Firebase Direct Cloud)
/// while cloud authentication is being rolled out.
/// Designed to Senior Flutter UI/UX standards with balanced viewport fitting,
/// M3 tonal surfaces, and clear user guidance.
class CloudAuthPlaceholderView extends StatelessWidget {
  const CloudAuthPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomeAppBar(
        title: 'Mobile Cloud Setup',
        showbackArrow: true,
        leadingOnPressed: () => Get.back(),
      ),
      body: Stack(
        children: [
          // Ambient teal/ocean glow at top center
          Positioned(
            top: -70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.secondary.withValues(alpha: 0.12),
                      colorScheme.secondary.withValues(alpha: 0.0),
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
                  final isCompact = constraints.maxHeight < 640;

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
                              // 1. Hero & Status Block
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: isCompact ? 64 : 76,
                                    height: isCompact ? 64 : 76,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerLow,
                                      borderRadius: AppRadius.xlAll,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.secondary
                                              .withValues(alpha: 0.18),
                                          blurRadius: 24,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: colorScheme.secondary
                                            .withValues(alpha: 0.35),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Iconsax.cloud_connection,
                                      size: isCompact ? 32 : 38,
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                  AppSpacing.gapMd,
                                  Text(
                                    'Mobile Cloud Edition',
                                    textAlign: TextAlign.center,
                                    style: (isCompact
                                            ? textTheme.titleLarge
                                            : textTheme.headlineSmall)
                                        ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  AppSpacing.gapXs,
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary
                                          .withValues(alpha: 0.12),
                                      borderRadius: AppRadius.fullAll,
                                      border: Border.all(
                                        color: colorScheme.secondary
                                            .withValues(alpha: 0.28),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Iconsax.timer_1,
                                          size: 13,
                                          color: colorScheme.secondary,
                                        ),
                                        AppSpacing.gapXs,
                                        Text(
                                          'Direct Cloud Service • Beta Coming Soon',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.secondary,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // 2. Structured Information Card
                              Container(
                                padding: EdgeInsets.all(
                                  isCompact ? AppSpacing.sm : AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: AppRadius.lgAll,
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _InfoFeatureRow(
                                      icon: Iconsax.info_circle,
                                      iconColor: colorScheme.secondary,
                                      title: 'Standalone Cloud Mode',
                                      description:
                                          'Phone-only registration with independent cloud sync is currently rolling out.',
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.xs,
                                      ),
                                      child: Divider(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    _InfoFeatureRow(
                                      icon: Iconsax.tick_circle,
                                      iconColor: colorScheme.primary,
                                      title: 'Shop Web System Ready',
                                      description:
                                          'If your store uses the SurfDesk web dashboard, you can connect right away by pairing.',
                                    ),
                                  ],
                                ),
                              ),

                              // 3. Action Area (Thumb-zone)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppButton(
                                    label:
                                        'Connect with Shop Web App Instead',
                                    icon: Iconsax.scan_barcode,
                                    type: AppButtonType.primary,
                                    onPressed: () {
                                      if (Get.isRegistered<
                                          ConnectionModeController>()) {
                                        Get.find<ConnectionModeController>()
                                            .selectWebShopMode();
                                      } else {
                                        Get.offNamed(Routes.SCAN_SHOP);
                                      }
                                    },
                                  ),
                                  AppSpacing.gapSm,
                                  AppButton(
                                    label: 'Back to Setup Selection',
                                    type: AppButtonType.secondary,
                                    onPressed: () => Get.back(),
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

class _InfoFeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _InfoFeatureRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
        ),
        AppSpacing.gapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              AppSpacing.gapXxs,
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
