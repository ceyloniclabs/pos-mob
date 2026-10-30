import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/app_data_formatter.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_viewer_screen.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';

class SaleInvoiceBottomSheet extends StatelessWidget {
  const SaleInvoiceBottomSheet({
    super.key,
    required this.sale,
    required this.invoiceUrl,
  });

  final Sale sale;
  final String invoiceUrl;

  static Future<void> show(
    BuildContext context, {
    required Sale sale,
    required String invoiceUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SaleInvoiceBottomSheet(
        sale: sale,
        invoiceUrl: invoiceUrl,
      ),
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    Navigator.of(context).pop();
    final invoiceTitle = 'Sales Invoice #${sale.id}';
    final invoiceFileName = 'invoice_${sale.id}.pdf';

    await AppPdfViewerScreen.openDirect(
      context,
      url: invoiceUrl,
      title: invoiceTitle,
      fileName: invoiceFileName,
    );
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: invoiceUrl));
    ScaffoldMessageUtils.showSuccess('Invoice link copied to clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final customerName = sale.customer != null && sale.customer!.name.trim().isNotEmpty
        ? sale.customer!.name.trim()
        : 'Walk-in Customer';

    final invoiceFileName = 'invoice_${sale.id}.pdf';

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewPadding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: AppRadius.fullAll,
              ),
            ),
          ),
          AppSpacing.vGapSm,

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  Iconsax.receipt_2,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale Invoice',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      sale.transactionId != null && sale.transactionId!.isNotEmpty
                          ? sale.transactionId!
                          : 'Invoice #${sale.id}',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          AppSpacing.vGapMd,

          // Invoice File Card
          Container(
            padding: AppSpacing.cardCompact,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.red,
                      size: 26,
                    ),
                  ),
                ),
                AppSpacing.gapSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoiceFileName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vGapXxs,
                      Text(
                        'PDF Document • Ready to view/download',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapSm,

          // Summary Mini-Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  theme,
                  label: 'Customer',
                  value: customerName,
                ),
                const Divider(height: 14),
                _buildInfoRow(
                  theme,
                  label: 'Payment Method',
                  value: sale.paymentMethod.toUpperCase(),
                ),
                const Divider(height: 14),
                _buildInfoRow(
                  theme,
                  label: 'Total Amount',
                  value: AppDataFormatter.formatCurrency(sale.totalAmount),
                  isHighlight: true,
                ),
              ],
            ),
          ),
          AppSpacing.vGapMd,

          // Action Buttons
          ElevatedButton.icon(
            onPressed: () => _openPdf(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll,
              ),
            ),
            icon: const Icon(Iconsax.document_text, size: 18),
            label: const Text(
              'Open Invoice (PDF)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          AppSpacing.vGapXs,

          OutlinedButton.icon(
            onPressed: _copyLink,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll,
              ),
            ),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy PDF Link'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme, {
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
