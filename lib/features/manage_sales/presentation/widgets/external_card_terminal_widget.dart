import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';

class ExternalCardTerminalWidget extends GetView<SaleCreateController> {
  const ExternalCardTerminalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Icon(
                Iconsax.card,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  'EXTERNAL CARD TERMINAL TRANSACTION',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,

          // Transaction Reference Field
          Text(
            'TRANSACTION REFERENCE (OPTIONAL)',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapXxs,
          TextField(
            controller: controller.transactionRefController,
            style: textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter trace ID or ref...',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.smAll,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
