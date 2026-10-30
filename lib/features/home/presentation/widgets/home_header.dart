import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppDataFormatter.greeting(),
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapXxs,
              Obx(
                () => Text(
                  AuthController.to.user.value?.name ?? 'Welcome to POS!',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(Routes.GLOBAL_SCANNER),
          icon: const Icon(Iconsax.scan_barcode, size: 22),
          tooltip: 'Scan Barcode',
        ),
        IconButton(
          onPressed: () => Get.toNamed(Routes.SHORTCUT),
          icon: const Icon(Iconsax.element_plus, size: 22),
          tooltip: 'Quick Actions',
        ),
      ],
    );
  }
}
