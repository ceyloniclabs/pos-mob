import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pos/core/constants/api_endpoints.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/app_image_preview_dialog.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_viewer_screen.dart';
import 'package:pos/features/manage_customers/presentation/controllers/customer_detail_controller.dart';

class CustomerInfoTab extends GetView<CustomerDetailController> {
  const CustomerInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Obx(() {
      final customer = controller.customer;
      final isLocal =
          customer.customerType.toLowerCase() == CustomerType.local.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Section 1: Personal & Contact Information â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildSectionHeader(
              context,
              title: 'Personal & Contact Information',
              icon: Iconsax.user,
            ),
            _DetailCard(
              children: [
                _DetailTile(
                  icon: Iconsax.user,
                  label: 'Full Name',
                  value: customer.name,
                ),
                _DetailTile(
                  icon: Iconsax.call,
                  label: 'Phone Number',
                  value: customer.phone,
                  actionTooltip: 'Copy phone number',
                  onAction: () => _copyToClipboard(
                    context,
                    customer.phone,
                    'Phone number copied',
                  ),
                ),
                _DetailTile(
                  icon: Iconsax.sms,
                  label: 'Email Address',
                  value: customer.email.isNotEmpty
                      ? customer.email
                      : 'Not provided',
                  isMuted: customer.email.isEmpty,
                  actionTooltip:
                      customer.email.isNotEmpty ? 'Copy email' : null,
                  onAction: customer.email.isNotEmpty
                      ? () => _copyToClipboard(
                            context,
                            customer.email,
                            'Email copied',
                          )
                      : null,
                ),
              ],
            ),
            AppSpacing.gapLg,

            // â”€â”€ Section 2: Identification & Nationality â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildSectionHeader(
              context,
              title: 'Identification & Nationality',
              icon: Iconsax.card,
            ),
            _DetailCard(
              children: [
                _DetailTile(
                  icon: isLocal ? Iconsax.location : Iconsax.global,
                  label: 'Customer Classification',
                  value: isLocal ? 'Local Customer' : 'Foreign Customer',
                  badge: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      isLocal ? 'NIC' : 'Passport',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                if (isLocal)
                  _DetailTile(
                    icon: Iconsax.card,
                    label: 'National Identity Card (NIC)',
                    value: (customer.nic != null && customer.nic!.isNotEmpty)
                        ? customer.nic!
                        : 'Not provided',
                    isMuted: customer.nic == null || customer.nic!.isEmpty,
                    actionTooltip: customer.nic != null && customer.nic!.isNotEmpty
                        ? 'Copy NIC'
                        : null,
                    onAction: customer.nic != null && customer.nic!.isNotEmpty
                        ? () => _copyToClipboard(
                              context,
                              customer.nic!,
                              'NIC copied',
                            )
                        : null,
                  )
                else
                  _DetailTile(
                    icon: Iconsax.document_text,
                    label: 'Passport Number',
                    value: (customer.passportId != null &&
                            customer.passportId!.isNotEmpty)
                        ? customer.passportId!
                        : 'Not provided',
                    isMuted: customer.passportId == null ||
                        customer.passportId!.isEmpty,
                    actionTooltip: customer.passportId != null &&
                            customer.passportId!.isNotEmpty
                        ? 'Copy Passport Number'
                        : null,
                    onAction: customer.passportId != null &&
                            customer.passportId!.isNotEmpty
                        ? () => _copyToClipboard(
                              context,
                              customer.passportId!,
                              'Passport Number copied',
                            )
                        : null,
                  ),
                _DetailTile(
                  icon: Iconsax.map,
                  label: 'Country of Origin',
                  value: isLocal
                      ? 'Sri Lanka'
                      : (controller
                              .getCountryName(customer.countryId.toString())
                              .isNotEmpty
                          ? controller
                              .getCountryName(customer.countryId.toString())
                          : 'Not specified'),
                ),
              ],
            ),
            AppSpacing.gapLg,

            // â”€â”€ Section 3: Demographics & Membership â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildSectionHeader(
              context,
              title: 'Demographics & Membership',
              icon: Iconsax.profile_2user,
            ),
            _DetailCard(
              children: [
                _DetailTile(
                  icon: _getGenderIcon(customer.gender),
                  label: 'Gender',
                  value: customer.gender.capitalizeFirst ?? customer.gender,
                ),
                _DetailTile(
                  icon: Iconsax.award,
                  label: 'Membership Tier',
                  value: customer.membershipLevel.capitalizeFirst ??
                      customer.membershipLevel,
                  badge: _buildTierBadge(
                    context,
                    customer.membershipLevel,
                  ),
                ),
              ],
            ),
            AppSpacing.gapLg,

            // â”€â”€ Section 4: Identity Document â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildSectionHeader(
              context,
              title: 'Identity Document',
              icon: Iconsax.document_upload,
            ),
            _buildDocumentAttachmentSection(
              context,
              theme,
              textTheme,
              customer.documentPhotoUrl,
            ),
            AppSpacing.gapXxl,
          ],
        ),
      );
    });
  }

  // â”€â”€ Section Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Document Attachment Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDocumentAttachmentSection(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    String? rawUrl,
  ) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.document,
                size: 24,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              'No Identity Document Attached',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.vGapXxs,
            Text(
              'No identification image or PDF uploaded for this customer',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final fullUrl = rawUrl.startsWith('http')
        ? rawUrl
        : '${EndPoints.baseUrl.replaceAll('/api/', '')}$rawUrl';

    final isPdf = fullUrl.toLowerCase().contains('.pdf');
    final fileName = rawUrl.split(RegExp(r'[/\\]')).last;

    if (isPdf) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: () => AppPdfViewerScreen.open(
              context,
              url: fullUrl,
              title: '${controller.customer.name} - Identity Document',
              fileName: fileName,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: AppRadius.smAll,
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf_rounded,
                              color: theme.colorScheme.error,
                              size: 22,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'PDF',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpacing.vGapXxs,
                            Text(
                              'PDF Document â€¢ Tap to view in-app',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Divider(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => AppPdfViewerScreen.open(
                              context,
                              url: fullUrl,
                              title: '${controller.customer.name} - Identity Document',
                              fileName: fileName,
                            ),
                            icon: const Icon(Icons.visibility_rounded, size: 16),
                            label: Text(
                              'Preview PDF',
                              style: textTheme.labelMedium?.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.hGapSm,
                        IconButton.filledTonal(
                          onPressed: () => _openUrl(fullUrl),
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          tooltip: 'Open in external app',
                          style: IconButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            minimumSize: const Size(36, 36),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Image Document Card
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => AppImagePreviewDialog.show(
              context,
              imageUrl: fullUrl,
              title: '${controller.customer.name} - Identity Document',
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CachedNetworkImage(
                  imageUrl: fullUrl,
                  height: 170,
                  width: double.infinity,
                  memCacheHeight: 400,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 170,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 32,
                          ),
                          AppSpacing.gapXs,
                          Text(
                            'Document image preview unavailable',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        // SizedBox(width: 4),
                        // Text(
                        //   'Tap to zoom',
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 11,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: Document Name (Full width)
                Text(
                  fileName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGapXxs,

                // Line 2: Attached Image label
                Text(
                  'Attached Image â€¢ Verified on record',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
                AppSpacing.gapMd,

                // Line 3: Preview Image button and External open button
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => AppImagePreviewDialog.show(
                          context,
                          imageUrl: fullUrl,
                          title: '${controller.customer.name} - Identity Document',
                        ),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: Text(
                          'Preview Image',
                          style: textTheme.labelMedium?.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.hGapSm,
                    IconButton.filledTonal(
                      onPressed: () => _openUrl(fullUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      tooltip: 'Open in external browser',
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Helper Badges & Icons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'female':
        return Icons.female_rounded;
      case 'other':
        return Icons.transgender_rounded;
      case 'male':
      default:
        return Icons.male_rounded;
    }
  }

  Widget _buildTierBadge(BuildContext context, String level) {
    final textTheme = Theme.of(context).textTheme;
    Color tierColor;
    switch (level.toLowerCase()) {
      case 'silver':
        tierColor = const Color(0xFF94A3B8);
        break;
      case 'gold':
        tierColor = const Color(0xFFEAB308);
        break;
      case 'platinum':
        tierColor = const Color(0xFFA855F7);
        break;
      case 'bronze':
      default:
        tierColor = const Color(0xFFCD7F32);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: tierColor.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        level.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: tierColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    String text,
    String feedbackMessage,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessageUtils.showSuccess(feedbackMessage);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessageUtils.showError('Unable to open document link.');
      }
    } catch (_) {
      ScaffoldMessageUtils.showError('Unable to open document link.');
    }
  }
}

// â”€â”€ Detail Card Container â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€ Detail Tile Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
    this.isMuted = false,
    this.actionTooltip,
    this.onAction,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? badge;
  final bool isMuted;
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
                          color: isMuted
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
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
