import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_data_formatter.dart';
import '../../../../core/utils/device_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custome_app_bar.dart';
import '../../../../core/widgets/entity_qr_dialog.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/sale_item.dart';
import '../controllers/sale_item_detail_controller.dart';

/// Clean, high-quality Material 3 Sale Item Details screen adhering to
/// senior Flutter UI/UX guidelines and the surf-mobapp design system.
class SaleItemDetailView extends GetView<SaleItemDetailController> {
  const SaleItemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final semantics = context.semanticColors;
    final isDark = theme.brightness == Brightness.dark;
    final navBarColor =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8FAFC);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: navBarColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.saleItem.value == null) {
          return const Scaffold(
            appBar: CustomeAppBar(
              title: 'Sale Item Details',
              centerTitle: true,
              showbackArrow: true,
            ),
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        final item = controller.saleItem.value;
        if (item == null) {
          return Scaffold(
            appBar: const CustomeAppBar(
              title: 'Sale Item Details',
              centerTitle: true,
              showbackArrow: true,
            ),
            body: RefreshIndicator(
              onRefresh: controller.refreshSaleItem,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(
                      'Sale item details not available.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: CustomeAppBar(
            title: 'Sale Item Details',
            centerTitle: true,
            showbackArrow: true,
            actions: [
              EntityQrActionButton(
                table: 'sale_items',
                id: item.id,
                title: '${item.name} QR',
              ),
            ],
          ),
          body: SafeArea(
            child: ResponsiveCenter(
              maxWidth: 720,
              child: RefreshIndicator(
                onRefresh: controller.refreshSaleItem,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Primary Details Header Card (Includes in-card photos & specs) ──
                      _buildPrimaryHeaderCard(
                        context,
                        theme,
                        textTheme,
                        semantics,
                        item,
                      ),
                      AppSpacing.gapMd,

                      // ── Classification & Details Card ──────────────
                      _buildClassificationCard(context, theme, textTheme, item),
                      AppSpacing.gapMd,

                      // ── Description Card (if available) ────────────
                      if (item.description != null &&
                          item.description!.trim().isNotEmpty) ...[
                        _buildDescriptionCard(
                          theme,
                          textTheme,
                          item.description!,
                        ),
                        AppSpacing.gapMd,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomActions(context, theme, item),
        );
      }),
    );
  }

  // ── Primary Header Card ────────────────────────────────────────────────────
  Widget _buildPrimaryHeaderCard(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    AppSemanticColors semantics,
    SaleItem item,
  ) {
    final brandName =
        (item.brandName != null && item.brandName!.trim().isNotEmpty)
            ? item.brandName!
            : 'UNKNOWN BRAND';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandName.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Item ID: #${item.id}',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hGapXs,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    label: item.isActive ? 'Active' : 'Inactive',
                    type: item.isActive
                        ? StatusType.success
                        : StatusType.error,
                  ),
                  if (item.stockQuantity <= 0) ...[
                    const SizedBox(height: 4),
                    const StatusBadge(
                      label: 'Out of Stock',
                      type: StatusType.error,
                      icon: Iconsax.close_circle,
                    ),
                  ] else if (item.stockQuantity <= 3) ...[
                    const SizedBox(height: 4),
                    StatusBadge(
                      label: 'Low Stock (${item.stockQuantity})',
                      type: StatusType.warning,
                      icon: Iconsax.warning_2,
                    ),
                  ],
                ],
              ),
            ],
          ),
          AppSpacing.gapMd,
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          AppSpacing.gapMd,

          // Quick Specs / Stats Summary Row (3 stats with vertical dividers)
          Row(
            children: [
              Expanded(
                child: _buildStatCell(
                  label: 'Selling Price',
                  value: AppDataFormatter.formatCurrency(item.sellingPrice),
                  valueColor: theme.colorScheme.primary,
                  isBold: true,
                  theme: theme,
                  textTheme: textTheme,
                ),
              ),
              _buildVerticalDivider(theme),
              Expanded(
                child: _buildStatCell(
                  label: 'Buying Price',
                  value: AppDataFormatter.formatCurrency(item.buyingPrice),
                  theme: theme,
                  textTheme: textTheme,
                ),
              ),
              _buildVerticalDivider(theme),
              Expanded(
                child: _buildStatCell(
                  label: 'Stock Quantity',
                  value: '${item.stockQuantity} units',
                  valueColor: item.stockQuantity <= 0
                      ? theme.colorScheme.error
                      : (item.stockQuantity <= 3
                          ? semantics.warning
                          : null),
                  theme: theme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),

          // ── In-Card Photos Strip (Bound to this card) ─────────────────
          if (item.photos.isNotEmpty) ...[
            AppSpacing.gapMd,
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            AppSpacing.gapSm,
            Row(
              children: [
                Icon(
                  Iconsax.gallery,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                AppSpacing.hGapXs,
                Text(
                  'Photos (${item.photos.length})',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap to view full screen',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: item.photos.length,
                separatorBuilder: (_, _) => AppSpacing.hGapSm,
                itemBuilder: (context, index) {
                  final photo = item.photos[index];
                  final photoUrl = _resolvePhotoUrl(photo);
                  final isPrimary = _isPhotoPrimary(photo, index);

                  return GestureDetector(
                    onTap: () => _openFullScreenViewer(
                      context,
                      item.photos,
                      index,
                      itemName: item.name,
                    ),
                    child: Container(
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.smAll,
                        border: Border.all(
                          color: isPrimary
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.6),
                          width: isPrimary ? 2.0 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, _) => Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, _, error) => Center(
                                child: Icon(
                                  Iconsax.image,
                                  size: 22,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (isPrimary)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PRIMARY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Classification & Details Card ─────────────────────────────────────────
  Widget _buildClassificationCard(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    SaleItem item,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme,
            textTheme,
            icon: Iconsax.category_2,
            title: 'Classification & Details',
          ),
          AppSpacing.gapSm,
          _buildInfoRow(
            theme,
            textTheme,
            label: 'Category',
            value: item.categoryName ?? '—',
            icon: Iconsax.category,
          ),
          _buildInfoRow(
            theme,
            textTheme,
            label: 'Sub Category',
            value: item.subcategoryName ?? '—',
            icon: Iconsax.element_3,
          ),
          _buildInfoRow(
            theme,
            textTheme,
            label: 'Brand',
            value: item.brandName ?? '—',
            icon: Iconsax.award,
          ),
          _buildInfoRow(
            theme,
            textTheme,
            label: 'Stock Status',
            value: item.stockQuantity > 0
                ? '${item.stockQuantity} in stock'
                : 'Out of stock',
            icon: item.stockQuantity > 0
                ? Iconsax.tick_circle
                : Iconsax.close_circle,
          ),
          _buildInfoRow(
            theme,
            textTheme,
            label: 'Status',
            value: item.isActive ? 'Active' : 'Inactive',
            icon: Iconsax.info_circle,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Description Card ──────────────────────────────────────────────────────
  Widget _buildDescriptionCard(
    ThemeData theme,
    TextTheme textTheme,
    String description,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme,
            textTheme,
            icon: Iconsax.document_text,
            title: 'Description',
          ),
          AppSpacing.gapSm,
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Actions ─────────────────────────────────────────────
  Widget _buildBottomActions(
    BuildContext context,
    ThemeData theme,
    SaleItem item,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.confirmAndDelete,
                icon: const Icon(Iconsax.trash, size: 18),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                  minimumSize: const Size(0, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.smAll,
                  ),
                ),
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: controller.goToEdit,
                icon: const Icon(Iconsax.edit, size: 18),
                label: const Text('Edit Item'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(0, 48),
                  elevation: 1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.smAll,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    ThemeData theme,
    TextTheme textTheme, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        AppSpacing.hGapXs,
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCell({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    required ThemeData theme,
    required TextTheme textTheme,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? theme.colorScheme.onSurface,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 36,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    TextTheme textTheme, {
    required String label,
    required String value,
    required IconData icon,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.hGapXs,
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Full-Screen Photo Viewer ───────────────────────────────────────────────
  void _openFullScreenViewer(
    BuildContext context,
    List<dynamic> photos,
    int initialIndex, {
    required String itemName,
  }) {
    Get.to(
      () => _FullScreenPhotoViewer(
        photos: photos,
        initialIndex: initialIndex,
        itemName: itemName,
      ),
      transition: Transition.fadeIn,
    );
  }

  static String _resolvePhotoUrl(dynamic photo) {
    String raw = '';
    if (photo is PhotoModel) {
      raw = photo.photoUrl;
    } else if (photo is Map) {
      raw = photo['photo_url']?.toString() ?? '';
    } else {
      try {
        raw = (photo as dynamic).photoUrl?.toString() ?? '';
      } catch (_) {
        raw = photo.toString();
      }
    }
    if (raw.startsWith('http')) return raw;
    return '${EndPoints.baseUrl.replaceAll('/api/', '')}$raw';
  }

  static bool _isPhotoPrimary(dynamic photo, [int index = 0]) {
    if (photo is PhotoModel) return photo.isPrimary == 1;
    if (photo is Map) {
      return photo['is_primary'] == 1 || photo['is_primary'] == '1';
    }
    try {
      if ((photo as dynamic).isPrimary == 1) return true;
    } catch (_) {}
    return index == 0;
  }
}

/// Dedicated full-screen photo viewer screen with an opaque dark background,
/// horizontal swipe between photos, pinch-to-zoom, and thumbnail dot indicators.
class _FullScreenPhotoViewer extends StatefulWidget {
  final List<dynamic> photos;
  final int initialIndex;
  final String itemName;

  const _FullScreenPhotoViewer({
    required this.photos,
    required this.initialIndex,
    required this.itemName,
  });

  @override
  State<_FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<_FullScreenPhotoViewer> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    DeviceUtils.updateSystemOverlay(
      isDark: Theme.of(Get.context!).brightness == Brightness.dark,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Match the app's signature background color (AColors.bgDark = Color(0xFF101F22))
    // so the canvas, app bar, and phone's system navigation bar flow seamlessly.
    final bgColor = isDark ? theme.scaffoldBackgroundColor : AColors.bgDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 26),
            tooltip: 'Close',
            onPressed: () => Get.back(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.itemName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Photo ${_currentIndex + 1} of ${widget.photos.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${_currentIndex + 1} / ${widget.photos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.photos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final photo = widget.photos[index];
                  final url = SaleItemDetailView._resolvePhotoUrl(photo);
                  final isPrimary =
                      SaleItemDetailView._isPhotoPrimary(photo, index);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 5.0,
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            placeholder: (context, _) => const Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, _, error) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 60,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image failed to load',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isPrimary)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'PRIMARY PHOTO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Bottom thumbnail indicator row if multiple photos exist
              if (widget.photos.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.photos.length, (i) {
                          final isSelected = i == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isSelected ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
