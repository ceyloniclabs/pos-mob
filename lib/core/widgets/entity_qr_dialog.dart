import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pos/core/services/qr_scanner/qr_payload.dart';
import 'package:pos/core/theme/app_radius.dart';

/// Reusable Dialog and AppBar action button to generate and display a QR code
/// containing the standardized JSON payload:
/// `{"table":"<table>","id":<id>}`
///
/// Designed to be scanned by the staff Global QR Scanner.
class EntityQrDialog extends StatelessWidget {
  final String table;
  final int id;
  final String? title;
  final String? subtitle;

  const EntityQrDialog({
    super.key,
    required this.table,
    required this.id,
    this.title,
    this.subtitle,
  });

  /// Displays the QR Code dialog with theme-aware styling.
  static Future<void> show(
    BuildContext context, {
    required String table,
    required int id,
    String? title,
    String? subtitle,
  }) async {
    await Get.dialog(
      EntityQrDialog(table: table, id: id, title: title, subtitle: subtitle),
      barrierDismissible: true,
    );
  }

  String get _qrData => QrPayload(table: table, id: id).toJsonString();

  String get _displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    switch (table.toLowerCase()) {
      case 'rent_surf_boards':
        return 'Surfboard QR';
      case 'rentals':
        return 'Rental #$id QR';
      case 'sale_items':
        return 'Sale Item QR';
      case 'sales':
        return 'Sale #$id QR';
      case 'users':
      case 'staff':
        return 'Staff QR';
      case 'customers':
        return 'Customer QR';
      default:
        return 'Record QR';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialogAll),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 360.w),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Row: Icon + Title + Close Button
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: 22.sp,
                      color: scheme.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle ?? 'Table: $table • ID: #$id',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20.sp),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Close',
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // QR Code Container (Always crisp white background for fast camera scanning)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: 210.w,
                  gapless: true,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
              SizedBox(height: 14.h),

              // // Payload preview badge
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              //   decoration: BoxDecoration(
              //     color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              //     borderRadius: BorderRadius.circular(8.r),
              //     border: Border.all(
              //       color: scheme.outlineVariant.withValues(alpha: 0.4),
              //     ),
              //   ),
              //   child: Text(
              //     _qrData,
              //     textAlign: TextAlign.center,
              //     maxLines: 2,
              //     overflow: TextOverflow.ellipsis,
              //     style: textTheme.bodySmall?.copyWith(
              //       fontFamily: 'monospace',
              //       fontSize: 11.sp,
              //       color: scheme.onSurfaceVariant,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),

              // SizedBox(height: 12.h),

              // Text(
              //   'Scan this QR code with the staff scanner to quickly open this record.',
              //   textAlign: TextAlign.center,
              //   style: textTheme.bodySmall?.copyWith(
              //     color: scheme.onSurfaceVariant,
              //     fontSize: 11.5.sp,
              //   ),
              // ),
              // SizedBox(height: 18.h),

              // // Action Buttons Row: Copy JSON + Done
              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         style: OutlinedButton.styleFrom(
              //           padding: EdgeInsets.symmetric(vertical: 10.h),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12.r),
              //           ),
              //         ),
              //         onPressed: () {
              //           Clipboard.setData(ClipboardData(text: _qrData));
              //           ScaffoldMessageUtils.showSuccess('QR JSON copied to clipboard');
              //         },
              //         icon: Icon(Iconsax.copy, size: 16.sp),
              //         label: Text(
              //           'Copy JSON',
              //           style: textTheme.labelMedium?.copyWith(
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 10.w),
              //     Expanded(
              //       child: FilledButton(
              //         style: FilledButton.styleFrom(
              //           padding: EdgeInsets.symmetric(vertical: 10.h),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12.r),
              //           ),
              //         ),
              //         onPressed: () => Get.back(),
              //         child: Text(
              //           'Done',
              //           style: textTheme.labelMedium?.copyWith(
              //             fontWeight: FontWeight.bold,
              //             color: scheme.onPrimary,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience AppBar action button to trigger [EntityQrDialog].
class EntityQrActionButton extends StatelessWidget {
  final String table;
  final int id;
  final String? title;
  final String? subtitle;

  const EntityQrActionButton({
    super.key,
    required this.table,
    required this.id,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_2_rounded),
      tooltip: 'Show QR Code',
      onPressed: () {
        EntityQrDialog.show(
          context,
          table: table,
          id: id,
          title: title,
          subtitle: subtitle,
        );
      },
    );
  }
}
