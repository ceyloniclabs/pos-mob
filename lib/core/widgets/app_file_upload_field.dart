import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Helper to format byte sizes into human-readable strings.
String formatFileSize(File file) {
  try {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } catch (_) {
    return '';
  }
}

/// Standard empty dropzone container matching Customer Add/Edit document design.
class AppFileUploadDropzone extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onPick;

  const AppFileUploadDropzone({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonLabel = 'Browse File',
    this.icon = Iconsax.document_upload,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onPick,
      borderRadius: AppRadius.mdAll,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 26,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapXxs,
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapMd,
            FilledButton.tonalIcon(
              onPressed: onPick,
              icon: const Icon(Icons.attach_file_rounded, size: 16),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                minimumSize: const Size(130, 38),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.smAll,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard uploaded file tile showing thumbnail, metadata, success dot, and remove action.
class AppUploadedFileTile extends StatelessWidget {
  final String fileName;
  final String subtitle;
  final Widget thumbnail;
  final VoidCallback? onRemove;
  final VoidCallback? onChange;
  final String changeLabel;
  final String statusText;
  final bool showBottomAction;

  const AppUploadedFileTile({
    super.key,
    required this.fileName,
    required this.subtitle,
    required this.thumbnail,
    this.onRemove,
    this.onChange,
    this.changeLabel = 'Change Document',
    this.statusText = 'Attached successfully',
    this.showBottomAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              thumbnail,
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.hGapXxs,
                        Flexible(
                          child: Text(
                            statusText,
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onRemove != null) ...[
                AppSpacing.hGapXs,
                IconButton.filledTonal(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: theme.colorScheme.error,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.error.withValues(
                      alpha: 0.1,
                    ),
                    minimumSize: const Size(32, 32),
                    maximumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  tooltip: 'Remove',
                  onPressed: onRemove,
                ),
              ],
            ],
          ),
          if (showBottomAction && onChange != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Divider(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Center(
                child: TextButton.icon(
                  onPressed: onChange,
                  icon: const Icon(Icons.sync_rounded, size: 15),
                  label: Text(changeLabel),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Thumbnail helper for local file or remote URL.
Widget buildFileThumbnail({
  BuildContext? context,
  File? file,
  String? url,
  double size = 50,
}) {
  final isPdf = file != null
      ? file.path.toLowerCase().endsWith('.pdf')
      : (url?.toLowerCase().endsWith('.pdf') ?? false);

  if (isPdf) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: AppRadius.smAll,
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.25),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_rounded,
            color: Colors.red,
            size: 22,
          ),
          SizedBox(height: 1),
          Text(
            'PDF',
            style: TextStyle(
              color: Colors.red,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: 0.1),
      borderRadius: AppRadius.smAll,
      border: Border.all(
        color: Colors.grey.withValues(alpha: 0.25),
      ),
    ),
    child: ClipRRect(
      borderRadius: AppRadius.smAll,
      child: file != null
          ? Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Iconsax.gallery,
                size: 22,
                color: Colors.grey,
              ),
            )
          : (url != null && url.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: url,
                  width: size,
                  height: size,
                  memCacheWidth: 150,
                  memCacheHeight: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => SizedBox(
                    width: size,
                    height: size,
                    child: const Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, error, stackTrace) => const Icon(
                    Iconsax.gallery,
                    size: 22,
                    color: Colors.grey,
                  ),
                )
              : const Icon(
                  Iconsax.gallery,
                  size: 22,
                  color: Colors.grey,
                ),
    ),
  );
}
