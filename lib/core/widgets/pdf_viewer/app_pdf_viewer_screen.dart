import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_cache_manager.dart';
import 'package:pos/core/widgets/pdf_viewer/app_pdf_download_sheet.dart';

/// Arguments to pass to [AppPdfViewerScreen] either via [AppPdfViewerScreen.open]
/// or via [Get.toNamed] with arguments.
class AppPdfViewerArgs {
  final String? url;
  final String? filePath;
  final String title;
  final String? fileName;
  final Map<String, String>? headers;
  final bool isSimulation;

  const AppPdfViewerArgs({
    this.url,
    this.filePath,
    required this.title,
    this.fileName,
    this.headers,
    this.isSimulation = false,
  }) : assert(
          url != null || filePath != null || isSimulation,
          'Either url or filePath must be provided, or isSimulation must be true',
        );
}

/// A common, reusable in-app PDF Viewer Screen matching the application's
/// theme, providing progressive background download/caching, page navigation,
/// zoom controls, jump to page, and external open fallback.
class AppPdfViewerScreen extends StatefulWidget {
  final AppPdfViewerArgs? args;

  const AppPdfViewerScreen({super.key, this.args});

  /// Opens the PDF viewer. If remote and not cached, displays a dedicated,
  /// sleek download progress bottom sheet first, then opens the viewer
  /// directly with the cached file for a seamless user experience.
  static Future<void> open(
    BuildContext context, {
    String? url,
    String? filePath,
    required String title,
    String? fileName,
    Map<String, String>? headers,
  }) async {
    // 1. Direct local file path
    if (filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (await file.exists()) {
        if (!context.mounted) return;
        return _pushViewer(
          context,
          AppPdfViewerArgs(
            filePath: filePath,
            title: title,
            fileName: fileName,
            headers: headers,
          ),
        );
      }
    }

    // 2. Remote URL: Check if already cached first
    if (url != null && url.trim().isNotEmpty) {
      final cachedPath =
          await AppPdfCacheManager.getCachedFilePath(url, fileName);
      if (cachedPath != null && context.mounted) {
        // Already downloaded! Opens instantly with zero loading screen.
        return _pushViewer(
          context,
          AppPdfViewerArgs(
            filePath: cachedPath,
            url: url,
            title: title,
            fileName: fileName,
            headers: headers,
          ),
        );
      }

      if (!context.mounted) return;

      // Not cached yet: Show the dedicated, sleek download bottom sheet
      final downloadedPath = await AppPdfDownloadSheet.show(
        context,
        url: url,
        title: title,
        fileName: fileName,
        headers: headers,
      );

      // Once successfully downloaded, open viewer directly with local file
      if (downloadedPath != null && context.mounted) {
        return _pushViewer(
          context,
          AppPdfViewerArgs(
            filePath: downloadedPath,
            url: url,
            title: title,
            fileName: fileName,
            headers: headers,
          ),
        );
      }
      return;
    }

    ScaffoldMessageUtils.showError('No valid document URL or file path provided.');
  }

  static Future<void> _pushViewer(BuildContext context, AppPdfViewerArgs args) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AppPdfViewerScreen(args: args),
      ),
    );
  }

  /// Opens the PDF viewer directly without showing the download progress bottom sheet.
  /// The viewer screen itself handles progressive background downloading, caching,
  /// and loading indicator.
  static Future<void> openDirect(
    BuildContext context, {
    String? url,
    String? filePath,
    required String title,
    String? fileName,
    Map<String, String>? headers,
  }) async {
    if ((url != null && url.trim().isNotEmpty) ||
        (filePath != null && filePath.trim().isNotEmpty)) {
      return _pushViewer(
        context,
        AppPdfViewerArgs(
          url: url,
          filePath: filePath,
          title: title,
          fileName: fileName,
          headers: headers,
        ),
      );
    }
    ScaffoldMessageUtils.showError('No valid document URL or file path provided.');
  }

  /// Opens the PDF viewer in simulated download mode to inspect and confirm the full-screen loading UI.
  static Future<void> openSimulated(
    BuildContext context, {
    String? url,
    String title = 'Rental Agreement Template',
    String? fileName = 'rental_agreement_template.pdf',
  }) {
    return _pushViewer(
      context,
      AppPdfViewerArgs(
        url: url ?? '',
        title: title,
        fileName: fileName,
        isSimulation: true,
      ),
    );
  }

  @override
  State<AppPdfViewerScreen> createState() => _AppPdfViewerScreenState();
}

class _AppPdfViewerScreenState extends State<AppPdfViewerScreen> {
  late final AppPdfViewerArgs _args;
  final PdfViewerController _pdfController = PdfViewerController();
  CancelToken? _cancelToken;

  bool _isLoading = true;
  String? _errorMessage;
  String? _localFilePath;

  // Download Progress
  double _downloadProgress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;

  // PDF Document State
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isDocumentLoaded = false;

  @override
  void initState() {
    super.initState();
    final modalArgs = widget.args ?? (Get.arguments as AppPdfViewerArgs?);
    if (modalArgs == null) {
      _errorMessage = 'No document parameters provided.';
      _isLoading = false;
      return;
    }
    _args = modalArgs;
    if (_args.isSimulation) {
      _startSimulation();
    } else {
      _prepareDocument();
    }
  }

  /// Safely cancels download token with try-catch and status check
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

  /// Runs a realistic, smooth download simulation to inspect the full-screen loading UI.
  Future<void> _startSimulation() async {
    _safeCancelDownload('Simulation restarted');
    _cancelToken = CancelToken();

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _downloadProgress = 0.0;
      _totalBytes = 522889;
      _receivedBytes = 0;
      _errorMessage = null;
      _isDocumentLoaded = false;
      _localFilePath = null;
    });

    final steps = [
      (0.15, 300),
      (0.35, 400),
      (0.58, 450),
      (0.79, 450),
      (0.93, 350),
      (1.00, 300),
    ];

    for (final step in steps) {
      await Future.delayed(Duration(milliseconds: step.$2));
      if (!mounted || (_cancelToken?.isCancelled ?? false)) return;
      setState(() {
        _downloadProgress = step.$1;
      });
    }

    // Brief settle time at 100%
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted || (_cancelToken?.isCancelled ?? false)) return;

    // Load actual document so the transition into PDF viewer is seen
    await _prepareDocument(forceRedownload: false);
  }

  @override
  void dispose() {
    _safeCancelDownload('Viewer disposed');
    super.dispose();
  }

  /// Checks if file is already local or downloads & caches remote PDF.
  Future<void> _prepareDocument({bool forceRedownload = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _downloadProgress = 0.0;
      _receivedBytes = 0;
      _totalBytes = 0;
      _isDocumentLoaded = false;
    });

    try {
      // 1. Direct local file path
      if (_args.filePath != null && _args.filePath!.isNotEmpty) {
        final file = File(_args.filePath!);
        if (await file.exists()) {
          setState(() {
            _localFilePath = file.path;
            _isLoading = false;
          });
          return;
        }
      }

      // 2. Remote URL
      final url = _args.url;
      if (url == null || url.trim().isEmpty) {
        throw Exception('Invalid document URL');
      }

      final cacheDir = await _getPdfCacheDirectory();
      final resolvedFileName = _resolveFileName(url, _args.fileName);
      final cachedFile = File('${cacheDir.path}/$resolvedFileName');

      // Check cache if not forcing re-download
      if (!forceRedownload &&
          await cachedFile.exists() &&
          await cachedFile.length() > 0) {
        setState(() {
          _localFilePath = cachedFile.path;
          _isLoading = false;
        });
        return;
      }

      // Download file with progress
      _safeCancelDownload('Preparing new download');
      _cancelToken = CancelToken();
      final dio = Dio();
      await dio.download(
        url,
        cachedFile.path,
        cancelToken: _cancelToken,
        options: Options(
          headers: _args.headers,
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
        onReceiveProgress: (received, total) {
          if (mounted) {
            setState(() {
              _receivedBytes = received;
              _totalBytes = total;
              if (total > 0) {
                _downloadProgress = received / total;
              }
            });
          }
        },
      );

      if (await cachedFile.exists() && await cachedFile.length() > 0) {
        if (mounted) {
          setState(() {
            _localFilePath = cachedFile.path;
            _isLoading = false;
          });
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
          _isLoading = false;
          _errorMessage = _humanizeError(e);
        });
      }
    }
  }

  Future<Directory> _getPdfCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/pdf_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  String _resolveFileName(String url, String? explicitName) {
    if (explicitName != null && explicitName.trim().isNotEmpty) {
      final sanitized = explicitName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      return sanitized.toLowerCase().endsWith('.pdf') ? sanitized : '$sanitized.pdf';
    }

    try {
      final uri = Uri.parse(url);
      final lastSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'document.pdf';
      final sanitized = lastSegment.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      return sanitized.toLowerCase().endsWith('.pdf') ? sanitized : '$sanitized.pdf';
    } catch (_) {
      return 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
    return 'Failed to load PDF document ($msg).';
  }

  Future<void> _openExternal() async {
    if (_localFilePath != null && await File(_localFilePath!).exists()) {
      try {
        final result = await OpenFilex.open(_localFilePath!);
        if (result.type != ResultType.done) {
          _openUrlExternal();
        }
      } catch (_) {
        _openUrlExternal();
      }
    } else {
      _openUrlExternal();
    }
  }

  Future<void> _openUrlExternal() async {
    final url = _args.url;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessageUtils.showError('Unable to open document externally.');
      }
    } else {
      ScaffoldMessageUtils.showError('File path is not available.');
    }
  }

  void _copyLink() {
    if (_args.url != null && _args.url!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _args.url!));
      ScaffoldMessageUtils.showSuccess('Document link copied to clipboard.');
    }
  }

  Future<void> _saveToDevice() async {
    if (_localFilePath == null || !await File(_localFilePath!).exists()) {
      ScaffoldMessageUtils.showWarning('Document is not ready to save yet.');
      return;
    }

    try {
      final rawName = _args.fileName ?? _resolveFileName(_args.url ?? '', 'document.pdf');
      final fileName = rawName.toLowerCase().endsWith('.pdf') ? rawName : '$rawName.pdf';
      final fileBytes = await File(_localFilePath!).readAsBytes();

      String savedDisplayName = fileName;
      String? openablePath = _localFilePath;
      bool saveCompleted = false;

      // 1. Try native FilePicker saveFile (uses Android Storage Access Framework)
      try {
        final Uri? resultUri = await FilePicker.saveFile(
          dialogTitle: 'Save PDF Document',
          fileName: fileName,
          bytes: fileBytes,
          mimeType: 'application/pdf',
        );

        // If user cancelled the picker dialog
        if (resultUri == null) {
          return;
        }

        saveCompleted = true;
        if (resultUri.pathSegments.isNotEmpty) {
          savedDisplayName = resultUri.pathSegments.last;
        } else {
          savedDisplayName = fileName;
        }
      } catch (_) {
        // Picker unavailable on device or threw an exception, fallback to app storage
        saveCompleted = false;
      }

      // 2. Fallback to app-scoped external storage if FilePicker was unavailable
      if (!saveCompleted) {
        Directory? targetDir;
        if (Platform.isAndroid) {
          try {
            final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
            if (dirs != null && dirs.isNotEmpty) {
              targetDir = dirs.first;
            }
          } catch (_) {}
          try {
            targetDir ??= await getExternalStorageDirectory();
          } catch (_) {}
          try {
            targetDir ??= await getApplicationDocumentsDirectory();
          } catch (_) {}
        } else if (Platform.isIOS) {
          try {
            targetDir = await getApplicationDocumentsDirectory();
          } catch (_) {}
        } else {
          try {
            targetDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
          } catch (_) {}
        }

        targetDir ??= await getApplicationDocumentsDirectory();

        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }

        String destinationPath = '${targetDir.path}/$fileName';
        final targetFile = File(destinationPath);
        if (await targetFile.exists()) {
          final baseName = fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
          destinationPath = '${targetDir.path}/${baseName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        }

        await File(_localFilePath!).copy(destinationPath);
        openablePath = destinationPath;
        savedDisplayName = destinationPath.split(Platform.pathSeparator).last;
      }

      Get.snackbar(
        'Saved to Device',
        'Document saved: $savedDisplayName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        mainButton: openablePath != null
            ? TextButton(
                onPressed: () => OpenFilex.open(openablePath!),
                child: const Text(
                  'OPEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      );
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to save file: $e');
    }
  }

  void _showJumpToPageDialog() {
    if (_totalPages <= 1) return;
    final textController = TextEditingController(text: '$_currentPage');
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          title: Text(
            'Jump to Page',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter page number (1 - $_totalPages):',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapSm,
              TextField(
                controller: textController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.smAll,
                  ),
                  hintText: 'Page number',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final page = int.tryParse(textController.text.trim());
                if (page != null && page >= 1 && page <= _totalPages) {
                  Navigator.pop(dialogCtx);
                  _pdfController.goToPage(pageNumber: page);
                } else {
                  ScaffoldMessageUtils.showWarning(
                    'Please enter a valid page number between 1 and $_totalPages.',
                  );
                }
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomeAppBar(
        showbackArrow: true,
        title: _args.title,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_download, size: 22),
            tooltip: 'Download PDF',
            onPressed:
                (_isLoading || _localFilePath == null) ? null : _saveToDevice,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            tooltip: 'More actions',
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
            onSelected: (value) {
              switch (value) {
                case 'download':
                  _saveToDevice();
                  break;
                case 'external':
                  _openExternal();
                  break;
                case 'reload':
                  _prepareDocument(forceRedownload: true);
                  break;
                case 'copy':
                  _copyLink();
                  break;
                case 'jump':
                  _showJumpToPageDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Iconsax.document_download, size: 18),
                    SizedBox(width: 10),
                    Text('Download'),
                  ],
                ),
              ),
              if (_isDocumentLoaded && _totalPages > 1)
                const PopupMenuItem(
                  value: 'jump',
                  child: Row(
                    children: [
                      Icon(Iconsax.direct_up, size: 18),
                      SizedBox(width: 10),
                      Text('Jump to page'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'external',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Open in external app'),
                  ],
                ),
              ),
              if (_args.url != null && _args.url!.isNotEmpty)
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Iconsax.copy, size: 18),
                      SizedBox(width: 10),
                      Text('Copy document link'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'reload',
                child: Row(
                  children: [
                    Icon(Iconsax.refresh, size: 18),
                    SizedBox(width: 10),
                    Text('Reload document'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(theme, textTheme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, TextTheme textTheme) {
    if (_isLoading) {
      return _buildLoadingView(theme, textTheme);
    }

    if (_errorMessage != null) {
      return _buildErrorView(theme, textTheme);
    }

    if (_localFilePath == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // PDF Canvas
        Positioned.fill(
          child: PdfViewer.file(
            _localFilePath!,
            controller: _pdfController,
            params: PdfViewerParams(
              margin: 12.0,
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF1E222A)
                  : const Color(0xFFE2E8F0),
              loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2.5,
                        ),
                      ),
                      AppSpacing.gapSm,
                      Text(
                        'Opening PDF document...',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
              onPageChanged: (pageNumber) {
                if (mounted && pageNumber != null && pageNumber != _currentPage) {
                  setState(() {
                    _currentPage = pageNumber;
                  });
                }
              },
              onViewerReady: (document, controller) {
                if (mounted) {
                  setState(() {
                    _totalPages = controller.pageCount;
                    _isDocumentLoaded = true;
                  });
                }
              },
              errorBannerBuilder: (context, error, stackTrace, documentRef) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.warning_2,
                          size: 40,
                          color: theme.colorScheme.error,
                        ),
                        AppSpacing.gapSm,
                        Text(
                          'Error Rendering PDF',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.vGapXxs,
                        Text(
                          error.toString(),
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.gapMd,
                        FilledButton.tonalIcon(
                          onPressed: _openExternal,
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text('Open Externally'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Subtle top progress bar while document is initializing / rendering
        if (!_isDocumentLoaded)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2.5,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),

        // Floating Bottom Controls Pill
        if (_isDocumentLoaded && _totalPages > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.md,
            child: Center(
              child: _buildBottomFloatingControls(theme, textTheme),
            ),
          ),
      ],
    );
  }

  /// Floating Page Navigator & Controls at bottom center
  Widget _buildBottomFloatingControls(ThemeData theme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous Page Button
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 22),
            tooltip: 'Previous page',
            onPressed: _currentPage > 1
                ? () => _pdfController.goToPage(pageNumber: _currentPage - 1)
                : null,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          AppSpacing.hGapXxs,

          // Page Number Indicator (Clickable to jump)
          InkWell(
            onTap: _totalPages > 1 ? _showJumpToPageDialog : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_currentPage / $_totalPages',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (_totalPages > 1) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
          AppSpacing.hGapXxs,

          // Next Page Button
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 22),
            tooltip: 'Next page',
            onPressed: _currentPage < _totalPages
                ? () => _pdfController.goToPage(pageNumber: _currentPage + 1)
                : null,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

          Container(
            height: 18,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),

          // Fit to width / Reset Zoom Button
          IconButton(
            icon: const Icon(Icons.fit_screen_rounded, size: 18),
            tooltip: 'Fit to screen',
            onPressed: () {
              final fitMatrix = _pdfController.calcMatrixFitWidthForPage(
                pageNumber: _currentPage,
              );
              if (fitMatrix != null) {
                _pdfController.goTo(fitMatrix);
              }
            },
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  /// Full-screen modern loading view with progressive download progress
  Widget _buildLoadingView(ThemeData theme, TextTheme textTheme) {
    final fileName = _args.fileName ?? 'PDF Document';
    final hasTotal = _totalBytes > 0;
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox.expand(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              // ── Centered Content: PDF Icon + Circular Progress + Document Name ──
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── PDF Icon with Circular Progress Indicator around it ──
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ambient soft halo
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(
                                alpha: isDark ? 0.12 : 0.08,
                              ),
                            ),
                          ),

                          // Circular Progress Bar reflecting download progress value (no % text)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: hasTotal ? _downloadProgress.clamp(0.0, 1.0) : 0.0,
                            ),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedVal, _) {
                              return SizedBox(
                                width: 84,
                                height: 84,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.2,
                                  value: hasTotal ? animatedVal : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.15),
                                ),
                              );
                            },
                          ),

                          // Central PDF Icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.35 : 0.08,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.picture_as_pdf_rounded,
                                color: theme.colorScheme.error,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGapLg,

                      // ── Centered Document Name & Details ─────────────────
                      Text(
                        _args.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (fileName.isNotEmpty && fileName != _args.title) ...[
                        AppSpacing.vGapXxs,
                        Text(
                          fileName,
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      AppSpacing.vGapSm,

                      // Subtle status text (NO percentage text)
                      Text(
                        hasTotal && _receivedBytes > 0
                            ? 'Downloading document...'
                            : 'Preparing document...',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Docked Bottom Section: Cancel Text Button ─────────
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: TextButton(
                  onPressed: () {
                    _safeCancelDownload('User cancelled');
                    Navigator.of(context).maybePop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Full-screen Branded Error View with Retry and Fallback External Open
  Widget _buildErrorView(ThemeData theme, TextTheme textTheme) {
    return SizedBox.expand(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.document_download,
                  color: theme.colorScheme.error,
                  size: 48,
                ),
              ),
              AppSpacing.gapXl,
              Text(
                'Could Not Open Document',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapSm,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  _errorMessage ?? 'An error occurred while loading the PDF file.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 2),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _prepareDocument(forceRedownload: true),
                      icon: const Icon(Iconsax.refresh, size: 16),
                      label: const Text('Retry Download'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.smAll,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.vGapSm,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openExternal,
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Open in External App'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.smAll,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapXl,
            ],
          ),
        ),
      ),
    );
  }
}
