import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:pos/core/access/access_policy.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/promo_code.dart';
import '../controllers/promo_code_controller.dart';

class PromoCodeDetailsView extends GetView<PromoCodeController> {
  const PromoCodeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final initialCode = Get.arguments as PromoCode;
    final role = AuthController.to.user.value?.role;
    final canManage = AccessPolicy.allows(role, AppPermission.managePromotions);

    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Promo Code Details',
        centerTitle: true,
        showbackArrow: true,
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Iconsax.edit_2, size: 20),
              tooltip: 'Edit Promo Code',
              onPressed: () async {
                final currentCode = controller.promoCodes.firstWhere(
                  (e) => e.id == initialCode.id,
                  orElse: () => initialCode,
                );
                controller.initForm(currentCode);
                final result = await Get.toNamed(
                  Routes.PROMO_CODE_EDIT,
                  arguments: currentCode,
                );
                if (result == true) {
                  controller.fetchPromoCodes();
                }
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 720,
          child: Obx(() {
            final code = controller.promoCodes.firstWhere(
              (e) => e.id == initialCode.id,
              orElse: () => initialCode,
            );

            final isExpired = code.expireDate.isBefore(DateTime.now());

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Promo Code Card ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.82),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.lgAll,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs + 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: AppRadius.smAll,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.discount_shape,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  AppSpacing.gapXxs,
                                  Text(
                                    code.code,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs + 1,
                              ),
                              decoration: BoxDecoration(
                                color: code.isActive && !isExpired
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.red.withValues(alpha: 0.3),
                                borderRadius: AppRadius.fullAll,
                              ),
                              child: Text(
                                !code.isActive
                                    ? 'Inactive'
                                    : isExpired
                                        ? 'Expired'
                                        : 'Active',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapLg,
                        Text(
                          'Discounts Offered',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpacing.vGapXxs,
                        Row(
                          children: [
                            Text(
                              '${code.salesPercentage.toStringAsFixed(0)}% Sales',
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            AppSpacing.gapMd,
                            Container(
                              width: 1.5,
                              height: 22,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            AppSpacing.gapMd,
                            Text(
                              '${code.rentalPercentage.toStringAsFixed(0)}% Rental',
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapMd,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.user,
                                color: Colors.white,
                                size: 14,
                              ),
                              AppSpacing.gapXxs,
                              Expanded(
                                child: Text(
                                  code.referral,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Iconsax.calendar,
                                color: Colors.white,
                                size: 14,
                              ),
                              AppSpacing.gapXxs,
                              Text(
                                'Expires: ${DateFormat('MMM dd, yyyy').format(code.expireDate)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.gapLg,

                  // ── Section 1: Discount Information ───────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Promo Code Information',
                    icon: Iconsax.ticket_discount,
                  ),
                  _DetailCard(
                    children: [
                      _DetailTile(
                        icon: Iconsax.ticket_discount,
                        label: 'Promo Code',
                        value: code.code,
                        actionTooltip: 'Copy promo code',
                        onAction: () => _copyToClipboard(
                          code.code,
                          'Promo code copied',
                        ),
                      ),
                      _DetailTile(
                        icon: Iconsax.user,
                        label: 'Referral / Partner',
                        value: code.referral,
                      ),
                      _DetailTile(
                        icon: Iconsax.percentage_square,
                        label: 'Sales Discount',
                        value: '${code.salesPercentage.toStringAsFixed(2)}%',
                      ),
                      _DetailTile(
                        icon: Iconsax.percentage_circle,
                        label: 'Rental Discount',
                        value: '${code.rentalPercentage.toStringAsFixed(2)}%',
                      ),
                    ],
                  ),

                  AppSpacing.gapLg,

                  // ── Section 2: Validity & Metadata ────────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Validity & Timeline',
                    icon: Iconsax.calendar_tick,
                  ),
                  _DetailCard(
                    children: [
                      _DetailTile(
                        icon: Iconsax.calendar_1,
                        label: 'Expiration Date',
                        value:
                            DateFormat('MMMM dd, yyyy').format(code.expireDate),
                        badge: isExpired
                            ? _buildPillBadge(
                                context,
                                label: 'EXPIRED',
                                color: theme.colorScheme.error,
                              )
                            : null,
                      ),
                      _DetailTile(
                        icon: Iconsax.status,
                        label: 'Status',
                        value: code.isActive ? 'Active' : 'Inactive',
                        badge: _buildPillBadge(
                          context,
                          label: code.isActive ? 'ACTIVE' : 'INACTIVE',
                          color: code.isActive
                              ? const Color(0xFF16A34A)
                              : theme.colorScheme.error,
                        ),
                      ),
                      if (code.description != null &&
                          code.description!.trim().isNotEmpty)
                        _DetailTile(
                          icon: Iconsax.document_text,
                          label: 'Description',
                          value: code.description!,
                        ),
                      if (code.createdAt != null)
                        _DetailTile(
                          icon: Iconsax.clock,
                          label: 'Created Date',
                          value: DateFormat('MMM dd, yyyy • HH:mm')
                              .format(code.createdAt!),
                        ),
                    ],
                  ),

                  AppSpacing.gapXxl,
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxs + 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              icon,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          AppSpacing.hGapXs,
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessageUtils.showSuccess(message);
  }
}

// ── Detail Card Container ────────────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                indent: 48,
              ),
          ],
        ],
      ),
    );
  }
}

// ── Detail Tile Row ──────────────────────────────────────────────────────────
class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
    this.actionTooltip,
    this.onAction,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? badge;
  final String? actionTooltip;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.6,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      badge!,
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onAction != null)
            IconButton(
              icon: const Icon(Iconsax.copy, size: 16),
              tooltip: actionTooltip ?? 'Copy',
              visualDensity: VisualDensity.compact,
              color: theme.colorScheme.onSurfaceVariant,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}
