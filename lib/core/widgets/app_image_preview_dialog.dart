import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';

/// Full-screen in-app image viewer dialog with interactive pinch-to-zoom.
class AppImagePreviewDialog extends StatelessWidget {
  final String imageUrl;
  final String title;

  const AppImagePreviewDialog({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    required String title,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => AppImagePreviewDialog(
        imageUrl: imageUrl,
        title: title,
      ),
    );
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(imageUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessageUtils.showError('Unable to open image externally.');
      }
    } catch (_) {
      ScaffoldMessageUtils.showError('Unable to open image link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Pinch-to-zoom image canvas
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, _) => const Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: (context, _, error) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        margin: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.warning_2,
                              color: Colors.redAccent,
                              size: 36,
                            ),
                            AppSpacing.gapSm,
                            const Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppSpacing.gapMd,
                            FilledButton.tonal(
                              onPressed: _openExternal,
                              child: const Text('Open in Browser'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    AppSpacing.hGapXs,
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
                      tooltip: 'Open in external app',
                      onPressed: _openExternal,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
