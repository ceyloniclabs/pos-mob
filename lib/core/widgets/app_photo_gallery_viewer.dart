import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/utils/device_utils.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Full-screen in-app photo gallery viewer with horizontal swipe between
/// images, interactive pinch-to-zoom, image counter, and external open support.
class AppPhotoGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String title;
  final List<String>? captions;

  const AppPhotoGalleryViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    required this.title,
    this.captions,
  });

  /// Opens the gallery viewer with a smooth fade transition.
  static Future<void> show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
    required String title,
    List<String>? captions,
  }) {
    if (imageUrls.isEmpty) return Future.value();
    final safeIndex = initialIndex.clamp(0, imageUrls.length - 1);

    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) => AppPhotoGalleryViewer(
          imageUrls: imageUrls,
          initialIndex: safeIndex,
          title: title,
          captions: captions,
        ),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<AppPhotoGalleryViewer> createState() => _AppPhotoGalleryViewerState();
}

class _AppPhotoGalleryViewerState extends State<AppPhotoGalleryViewer> {
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
    final isDark = Theme.of(Get.context ?? context).brightness == Brightness.dark;
    DeviceUtils.updateSystemOverlay(isDark: isDark);
    super.dispose();
  }

  Future<void> _openExternal() async {
    final currentUrl = widget.imageUrls[_currentIndex];
    try {
      if (await canLaunchUrlString(currentUrl)) {
        await launchUrlString(currentUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessageUtils.showError('Unable to open image externally.');
      }
    } catch (_) {
      ScaffoldMessageUtils.showError('Unable to open image link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = AColors.bgDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
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
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Photo ${_currentIndex + 1} of ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
              tooltip: 'Open in external app',
              onPressed: _openExternal,
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final url = widget.imageUrls[index];

                  return InteractiveViewer(
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
                                size: 56,
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
                  );
                },
              ),
              if (widget.captions != null &&
                  widget.captions!.length > _currentIndex &&
                  widget.captions![_currentIndex].isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.captions![_currentIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
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
