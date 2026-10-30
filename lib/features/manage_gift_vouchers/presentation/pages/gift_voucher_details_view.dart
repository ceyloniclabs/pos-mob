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
import '../../domain/entities/gift_voucher.dart';
import '../controllers/gift_voucher_controller.dart';

class GiftVoucherDetailsView extends GetView<GiftVoucherController> {
  const GiftVoucherDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final initialVoucher = Get.arguments as GiftVoucher;
    final role = AuthController.to.user.value?.role;
    final canManage = AccessPolicy.allows(role, AppPermission.managePromotions);

    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Voucher Details',
        centerTitle: true,
        showbackArrow: true,
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Iconsax.edit_2, size: 20),
              tooltip: 'Edit Voucher',
              onPressed: () async {
                final currentVoucher = controller.giftVouchers.firstWhere(
                  (e) => e.id == initialVoucher.id,
                  orElse: () => initialVoucher,
                );
                controller.initForm(currentVoucher);
                final result = await Get.toNamed(
                  Routes.GIFT_VOUCHER_EDIT,
                  arguments: currentVoucher,
                );
                if (result == true) {
                  controller.fetchGiftVouchers();
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
            final voucher = controller.giftVouchers.firstWhere(
              (e) => e.id == initialVoucher.id,
              orElse: () => initialVoucher,
            );

            final isExpired = voucher.expireDate.isBefore(DateTime.now());

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Voucher Card ─────────────────────────────────────
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
                                    Iconsax.ticket_discount,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  AppSpacing.gapXxs,
                                  Text(
                                    voucher.code,
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
                                color: voucher.isActive && !isExpired
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.red.withValues(alpha: 0.3),
                                borderRadius: AppRadius.fullAll,
                              ),
                              child: Text(
                                !voucher.isActive
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
                          'Available Balance',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpacing.vGapXxs,
                        Text(
                          '${voucher.currency} ${voucher.balance.toStringAsFixed(2)}',
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
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
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Initial: ${voucher.currency} ${voucher.initialAmount.toStringAsFixed(2)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.calendar,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  AppSpacing.gapXxs,
                                  Text(
                                    'Expires: ${DateFormat('MMM dd, yyyy').format(voucher.expireDate)}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.gapLg,

                  // ── Section 1: Financial & Ownership ──────────────────────
                  _buildSectionHeader(
                    context,
                    title: 'Voucher Details',
                    icon: Iconsax.card_pos,
                  ),
                  _DetailCard(
                    children: [
                      _DetailTile(
                        icon: Iconsax.ticket_discount,
                        label: 'Voucher Code',
                        value: voucher.code,
                        actionTooltip: 'Copy voucher code',
                        onAction: () => _copyToClipboard(
                          voucher.code,
                          'Voucher code copied',
                        ),
                      ),
                      _DetailTile(
                        icon: Iconsax.user,
                        label: 'Owner / Recipient',
                        value: voucher.owner,
                      ),
                      _DetailTile(
                        icon: Iconsax.money_recive,
                        label: 'Initial Amount',
                        value:
                            '${voucher.currency} ${voucher.initialAmount.toStringAsFixed(2)}',
                      ),
                      _DetailTile(
                        icon: Iconsax.wallet_3,
                        label: 'Remaining Balance',
                        value:
                            '${voucher.currency} ${voucher.balance.toStringAsFixed(2)}',
                      ),
                      _DetailTile(
                        icon: Iconsax.coin,
                        label: 'Currency',
                        value: voucher.currency,
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
                            DateFormat('MMMM dd, yyyy').format(voucher.expireDate),
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
                        value: voucher.isActive ? 'Active' : 'Inactive',
                        badge: _buildPillBadge(
                          context,
                          label: voucher.isActive ? 'ACTIVE' : 'INACTIVE',
                          color: voucher.isActive
                              ? const Color(0xFF16A34A)
                              : theme.colorScheme.error,
                        ),
                      ),
                      if (voucher.description != null &&
                          voucher.description!.trim().isNotEmpty)
                        _DetailTile(
                          icon: Iconsax.document_text,
                          label: 'Description',
                          value: voucher.description!,
                        ),
                      if (voucher.createdAt != null)
                        _DetailTile(
                          icon: Iconsax.clock,
                          label: 'Created Date',
                          value: DateFormat('MMM dd, yyyy • HH:mm')
                              .format(voucher.createdAt!),
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
