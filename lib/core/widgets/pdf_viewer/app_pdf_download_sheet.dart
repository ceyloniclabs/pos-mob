import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_cache_manager.dart';

/// A dedicated, elegant modal bottom sheet showing progressive PDF download.
/// Eliminates ugly full-screen loading transitions by displaying a floating,
/// interactive progress card directly on the current screen.
class AppPdfDownloadSheet extends StatefulWidget {
  final String url;
  final String title;
  final String? fileName;
  final Map<String, String>? headers;

  const AppPdfDownloadSheet({
    super.key,
    required this.url,
    required this.title,
    this.fileName,
    this.headers,
  });

  /// Displays the download sheet and returns the local file path on success, or null if cancelled/failed.
  static Future<String?> show(
    BuildContext context, {
    required String url,
    required String title,
    String? fileName,
    Map<String, String>? headers,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isDismissible: false,
      enableDrag: false,
      builder: (_) => AppPdfDownloadSheet(
        url: url,
        title: title,
        fileName: fileName,
        headers: headers,
      ),
    );
  }

  @override
  State<AppPdfDownloadSheet> createState() => _AppPdfDownloadSheetState();
}

class _AppPdfDownloadSheetState extends State<AppPdfDownloadSheet> {
  CancelToken? _cancelToken;

  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  bool _isIndeterminate = true;

  bool _isSuccess = false;
  String? _errorMessage;

  void _safeCancelDownload([String reason = 'Cancelled']) {
    try {
      final token = _cancelToken;
      if (token != null && !token.isCancelled) {
        token.cancel(reason);
      }
    } catch (_) {
      // Safely ignore cancellation exceptions
    }
  }

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void dispose() {
    _safeCancelDownload('Sheet closed');
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = 0;
      _isIndeterminate = true;
      _isSuccess = false;
      _errorMessage = null;
    });

    try {
      final cacheDir = await AppPdfCacheManager.getCacheDirectory();
      final resolvedName = AppPdfCacheManager.resolveFileName(
        widget.url,
        widget.fileName,
      );
      final targetFile = File('${cacheDir.path}/$resolvedName');

      _cancelToken = CancelToken();
      final dio = Dio();

      await dio.download(
        widget.url,
        targetFile.path,
        cancelToken: _cancelToken,
        options: Options(
          headers: widget.headers,
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _receivedBytes = received;
            _totalBytes = total;
            if (total > 0) {
              _isIndeterminate = false;
              _progress = (received / total).clamp(0.0, 1.0);
            } else {
              _isIndeterminate = true;
            }
          });
        },
      );

      if (await targetFile.exists() && await targetFile.length() > 0) {
        if (!mounted) return;
        setState(() {
          _isSuccess = true;
          _progress = 1.0;
        });

        // Brief delay so user sees the 100% completion state smoothly
        await Future.delayed(const Duration(milliseconds: 220));
        if (mounted) {
          Navigator.of(context).pop(targetFile.path);
        }
      } else {
        throw Exception('Downloaded file is empty');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      if (CancelToken.isCancel(e as dynamic)) {
        return;
      }
      if (mounted) {
        setState(() {
          _errorMessage = _humanizeError(e);
        });
      }
    }
  }

  String _humanizeError(dynamic error) {
    final msg = error.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Network connection error. Please check your internet connection.';
    }
    if (msg.contains('404')) {
      return 'The requested PDF document was not found on the server.';
    }
    return 'Failed to download PDF document ($msg).';
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessageUtils.showError('Unable to open link in external browser.');
      }
    } catch (_) {
      ScaffoldMessageUtils.showError('Unable to open browser.');
    }
  }

  void _onCancel() {
    _safeCancelDownload('User cancelled download');
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final resolvedName = widget.fileName ?? 'PDF Document';
    final hasTotal = _totalBytes > 0;
    final percentage = hasTotal ? (_progress * 100).toInt() : null;

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom +
        16.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: bottomPadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row: PDF Icon + Title/Subtitle + Close button
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSuccess
                            ? 'Opening Document...'
                            : (_errorMessage != null
                                ? 'Download Failed'
                                : 'Downloading Document'),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resolvedName,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _onCancel,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Cancel',
                ),
              ],
            ),
            AppSpacing.gapMd,

            // Error View OR Active Progress Card
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapMd,
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _startDownload,
                      icon: const Icon(Iconsax.refresh, size: 16),
                      label: const Text('Try Again'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.smAll,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openExternal,
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Open External'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.smAll,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Progress Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            AppSpacing.hGapXs,
                            Text(
                              _isSuccess
                                  ? 'Download complete'
                                  : (hasTotal
                                      ? 'Downloading PDF file...'
                                      : 'Preparing download...'),
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          percentage != null ? '$percentage%' : '',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapSm,

                    // Animated Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0.0,
                          end: _isIndeterminate ? 0.0 : _progress,
                        ),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedValue, _) {
                          return LinearProgressIndicator(
                            value: _isIndeterminate ? null : animatedValue,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                            minHeight: 8,
                          );
                        },
                      ),
                    ),
                    AppSpacing.gapSm,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            hasTotal
                                ? '${AppPdfCacheManager.formatBytes(_receivedBytes)} of ${AppPdfCacheManager.formatBytes(_totalBytes)}'
                                : AppPdfCacheManager.formatBytes(_receivedBytes),
                            style: textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Secure transfer',
                              style: textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.gapMd,

              // Cancel Action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _onCancel,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Cancel Download'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 42),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.smAll,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
