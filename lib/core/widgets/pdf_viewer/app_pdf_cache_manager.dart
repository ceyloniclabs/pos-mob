import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Centralized cache manager for downloaded PDF documents.
/// Provides directory resolution, file existence checks, and cleanup.
class AppPdfCacheManager {
  const AppPdfCacheManager._();

  /// Gets or creates the local temporary directory for cached PDFs.
  static Future<Directory> getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/pdf_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Sanitizes and resolves a valid filename ending in `.pdf`.
  static String resolveFileName(String url, String? explicitName) {
    if (explicitName != null && explicitName.trim().isNotEmpty) {
      final sanitized = explicitName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      return sanitized.toLowerCase().endsWith('.pdf') ? sanitized : '$sanitized.pdf';
    }

    try {
      final uri = Uri.parse(url);
      final lastSegment =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'document.pdf';
      final sanitized = lastSegment.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      return sanitized.toLowerCase().endsWith('.pdf') ? sanitized : '$sanitized.pdf';
    } catch (_) {
      return 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }
  }

  /// Returns the path to the cached file if it exists and has content, or null otherwise.
  static Future<String?> getCachedFilePath(String url, String? explicitName) async {
    try {
      final cacheDir = await getCacheDirectory();
      final fileName = resolveFileName(url, explicitName);
      final file = File('${cacheDir.path}/$fileName');
      if (await file.exists() && await file.length() > 0) {
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  /// Formats byte count into human-readable B, KB, or MB string.
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Clears all cached PDF files from disk.
  static Future<void> clearCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (_) {}
  }
}
