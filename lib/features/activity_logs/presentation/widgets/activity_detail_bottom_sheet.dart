import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_data_formatter.dart';
import '../../../../core/utils/app_date_time_utils.dart';
import '../../../../core/utils/scaffold_message_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/activity_log_entity.dart';

/// A modern, clean, and adaptive bottom sheet to inspect activity log details.
///
/// Features:
/// - Dynamic intrinsic height (does not stretch to full screen if content is short).
/// - Sticky pinned footer & header with smooth scrolling for 10+ details.
/// - Human-friendly labels and visual pills (Currencies, Statuses, Booleans, Diffs).
/// - One-tap copy for IDs, dates, and references.
/// - Clean drag-to-dismiss support.
class ActivityDetailBottomSheet extends StatelessWidget {
  const ActivityDetailBottomSheet({
    super.key,
    required this.log,
  });

  final ActivityLogEntity log;

  /// Displays the Activity Detail Bottom Sheet.
  static Future<void> show(BuildContext context, ActivityLogEntity log) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ActivityDetailBottomSheet(log: log),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessageUtils.showSuccess('$label copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    final (icon, color) = _getActivityVisuals(context, log.action);
    final relativeTime =
        AppDataFormatter.customTimeAgo(log.createdAt.toIso8601String());

    final metadata = log.metadata;
    final hasMetadata = metadata != null && metadata.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top Drag Handle ───────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant.withValues(alpha: 0.8),
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),

            // ── Hero Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(
                        color: color.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.action,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGapXxs,
                        Row(
                          children: [
                            // Log ID Pill (tap to copy)
                            InkWell(
                              onTap: () => _copyToClipboard(
                                '${log.id}',
                                'Log ID #${log.id}',
                              ),
                              borderRadius: AppRadius.xsAll,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: AppRadius.xsAll,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Iconsax.hashtag,
                                      size: 11,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${log.id}',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppSpacing.hGapXs,
                            Text(
                              '•',
                              style: TextStyle(
                                color: scheme.outline,
                                fontSize: 12,
                              ),
                            ),
                            AppSpacing.hGapXs,
                            Icon(
                              Iconsax.clock,
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                relativeTime,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Scrollable Body Content (Fluid with Bouncing Physics) ─────
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Unified Operator & Timestamp Context Card
                    _buildUnifiedContextCard(context),

                    AppSpacing.vGapMd,

                    // 2. Section Header: Activity Details
                    _buildSectionHeader(context, hasMetadata),

                    AppSpacing.vGapSm,

                    // 3. Dynamic Visual Metadata Content
                    if (!hasMetadata)
                      _buildEmptyMetadataCard(context)
                    else
                      _buildAdaptiveMetadataList(context),

                    AppSpacing.vGapMd,
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // ── Bottom Pinned CTA (Always visible regardless of scroll) ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Context Card: Staff Member & Timestamp
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUnifiedContextCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final semantics = context.semanticColors;

    final roleColor = log.isAdmin ? scheme.primary : semantics.info;
    final timeFormatted =
        DateFormat('MMM dd, yyyy • hh:mm:ss a').format(log.createdAt);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Operator row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: roleColor.withValues(alpha: 0.15),
                child: Text(
                  log.userName.isNotEmpty
                      ? log.userName.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.userName,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (log.userId != null)
                      Text(
                        'User ID #${log.userId}',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullAll,
                  border: Border.all(
                    color: roleColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  log.role.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: roleColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),

          // Timestamp row
          Row(
            children: [
              Icon(
                Iconsax.calendar_1,
                size: 16,
                color: scheme.primary,
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  timeFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _copyToClipboard(timeFormatted, 'Timestamp'),
                borderRadius: AppRadius.xsAll,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Iconsax.copy,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section Header: Activity Details
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, bool hasMetadata) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final fieldCount = log.metadata?.length ?? 0;

    return Row(
      children: [
        Icon(
          Iconsax.note_21,
          size: 18,
          color: scheme.primary,
        ),
        AppSpacing.hGapXs,
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Activity Details',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasMetadata) ...[
                AppSpacing.hGapXs,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: AppRadius.fullAll,
                  ),
                  child: Text(
                    '$fieldCount ${fieldCount == 1 ? 'item' : 'items'}',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty Metadata State
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyMetadataCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.document_1,
              size: 22,
              color: scheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.vGapSm,
          Text(
            'No Additional Details',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vGapXxs,
          Text(
            'This activity was recorded successfully without extra custom parameters.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Adaptive Polymorphic Metadata List
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAdaptiveMetadataList(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entries = log.metadata!.entries.toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildMetadataEntryRow(context, entry.key, entry.value);
          },
        ),
      ),
    );
  }

  Widget _buildMetadataEntryRow(
    BuildContext context,
    String key,
    dynamic value,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final humanKey = _humanizeKey(key);
    final keyIcon = _getKeyIcon(key);

    // If value is a diff object (contains before/after or old/new)
    if (value is Map && _isDiffMap(value)) {
      return _buildDiffSection(context, humanKey, keyIcon, value);
    }

    // If value is a nested Map/Object
    if (value is Map<String, dynamic> || value is Map) {
      final mapValue = (value as Map).cast<String, dynamic>();
      return _buildNestedMapSection(context, humanKey, keyIcon, mapValue);
    }

    // If value is a List
    if (value is List) {
      return _buildListSection(context, humanKey, keyIcon, value);
    }

    // If value is a multiline string or note
    if (value is String && (value.contains('\n') || value.length > 50)) {
      return _buildMultilineSection(context, humanKey, keyIcon, value);
    }

    // Standard inline row
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            keyIcon,
            size: 15,
            color: scheme.primary.withValues(alpha: 0.8),
          ),
          AppSpacing.hGapSm,
          Expanded(
            flex: 4,
            child: Text(
              humanKey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSpacing.hGapSm,
          Flexible(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildSmartValueWidget(context, key, value),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Smart Value Widgets: Currencies, Statuses, Booleans, IDs, URLs
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSmartValueWidget(
    BuildContext context,
    String key,
    dynamic value,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final semantics = context.semanticColors;

    if (value == null) {
      return Text(
        '—',
        style: textTheme.bodySmall?.copyWith(
          color: scheme.outline,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final lowerKey = key.toLowerCase();
    final strVal = value.toString();

    // 1. Boolean Values
    if (value is bool || strVal == 'true' || strVal == 'false') {
      final isTrue = value is bool ? value : strVal == 'true';
      final boolColor = isTrue ? semantics.success : scheme.error;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: boolColor.withValues(alpha: 0.12),
          borderRadius: AppRadius.fullAll,
          border: Border.all(color: boolColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTrue ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 12,
              color: boolColor,
            ),
            const SizedBox(width: 4),
            Text(
              isTrue ? 'Yes' : 'No',
              style: textTheme.labelSmall?.copyWith(
                color: boolColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Status / State Tags
    if (_isStatusKey(lowerKey)) {
      final (statusBg, statusFg) = _getStatusBadgeColors(context, strVal);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: AppRadius.fullAll,
          border: Border.all(color: statusFg.withValues(alpha: 0.25)),
        ),
        child: Text(
          strVal.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: statusFg,
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
            letterSpacing: 0.4,
          ),
        ),
      );
    }

    // 3. Monetary Amounts
    if (_isCurrencyKey(lowerKey)) {
      final formatted = AppDataFormatter.formatCurrency(value);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: AppRadius.xsAll,
        ),
        child: Text(
          formatted,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      );
    }

    // 4. Dates & Timestamps
    if (_isDateKey(lowerKey, strVal)) {
      final parsed = AppDateTimeUtils.toLocal(strVal);
      if (parsed != null) {
        final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(parsed);
        return Text(
          dateStr,
          textAlign: TextAlign.end,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        );
      }
    }

    // 5. IDs, Reference Numbers, Hashes (Copyable)
    if (_isIdOrCodeKey(lowerKey)) {
      return InkWell(
        onTap: () => _copyToClipboard(strVal, _humanizeKey(key)),
        borderRadius: AppRadius.xsAll,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: AppRadius.xsAll,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  strVal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Iconsax.copy,
                size: 11,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      );
    }

    // 6. URLs
    if (strVal.startsWith('http://') || strVal.startsWith('https://')) {
      return InkWell(
        onTap: () => _copyToClipboard(strVal, 'URL'),
        borderRadius: AppRadius.xsAll,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.link,
              size: 12,
              color: scheme.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                strVal,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                  decoration: TextDecoration.underline,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 7. General String / Number fallback
    return SelectableText(
      strVal,
      textAlign: TextAlign.end,
      style: textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Diff View Renderer (Before vs After)
  // ─────────────────────────────────────────────────────────────────────────
  bool _isDiffMap(Map map) {
    final keys = map.keys.map((k) => k.toString().toLowerCase()).toSet();
    return (keys.contains('before') && keys.contains('after')) ||
        (keys.contains('old') && keys.contains('new'));
  }

  Widget _buildDiffSection(
    BuildContext context,
    String humanKey,
    IconData icon,
    Map map,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final semantics = context.semanticColors;

    final beforeVal = map['before'] ?? map['old'];
    final afterVal = map['after'] ?? map['new'];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: scheme.primary),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  humanKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.hGapXs,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                  borderRadius: AppRadius.xsAll,
                ),
                child: Text(
                  'CHANGE',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onTertiaryContainer,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGapXs,
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadius.smAll,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                // Before badge
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.error.withValues(alpha: 0.08),
                      borderRadius: AppRadius.xsAll,
                    ),
                    child: Text(
                      beforeVal?.toString() ?? 'none',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Iconsax.arrow_right_3,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                // After badge
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: semantics.success.withValues(alpha: 0.1),
                      borderRadius: AppRadius.xsAll,
                    ),
                    child: Text(
                      afterVal?.toString() ?? 'none',
                      style: textTheme.bodySmall?.copyWith(
                        color: semantics.success,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Nested Map Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNestedMapSection(
    BuildContext context,
    String humanKey,
    IconData icon,
    Map<String, dynamic> map,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: scheme.primary),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  humanKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
              AppSpacing.hGapXs,
              Text(
                '(${map.length} items)',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          AppSpacing.vGapXs,
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadius.smAll,
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.smAll,
              child: Column(
                children: map.entries.map((subEntry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            _humanizeKey(subEntry.key),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          flex: 6,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _buildSmartValueWidget(
                              context,
                              subEntry.key,
                              subEntry.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // List Section (Chips for Primitives or Subcards for Objects)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildListSection(
    BuildContext context,
    String humanKey,
    IconData icon,
    List list,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isObjectList = list.isNotEmpty && list.first is Map;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: scheme.primary),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  humanKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
              AppSpacing.hGapXs,
              Text(
                '(${list.length} ${list.length == 1 ? 'item' : 'items'})',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          AppSpacing.vGapXs,
          if (list.isEmpty)
            Text(
              'Empty list',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.outline,
                fontStyle: FontStyle.italic,
              ),
            )
          else if (!isObjectList)
            // Primitive List (Wrap of Chips)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: list.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: AppRadius.xsAll,
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(
                    item.toString(),
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      color: scheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            )
          else
            // Objects List (Structured sub-cards)
            Column(
              children: list.asMap().entries.map((indexedItem) {
                final idx = indexedItem.key + 1;
                final mapItem =
                    (indexedItem.value as Map).cast<String, dynamic>();

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.xsAll,
                            ),
                            child: Text(
                              '#$idx',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGapXxs,
                      ...mapItem.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  _humanizeKey(e.key),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                flex: 6,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _buildSmartValueWidget(
                                    context,
                                    e.key,
                                    e.value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Multiline Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMultilineSection(
    BuildContext context,
    String humanKey,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: scheme.primary),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  humanKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _copyToClipboard(text, humanKey),
                borderRadius: AppRadius.xsAll,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Iconsax.copy,
                    size: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGapXxs,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadius.smAll,
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
            child: SelectableText(
              text,
              style: textTheme.bodySmall?.copyWith(
                height: 1.45,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Intelligent Helper Functions
  // ─────────────────────────────────────────────────────────────────────────
  static String _humanizeKey(String raw) {
    if (raw.isEmpty) return raw;

    if (raw.toLowerCase() == 'id') return 'ID';
    if (raw.toLowerCase() == 'ip') return 'IP Address';
    if (raw.toLowerCase() == 'url') return 'URL';
    if (raw.toLowerCase() == 'api') return 'API';

    final words = raw
        .replaceAll(RegExp(r'[\-_]'), ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (Match m) => '${m[1]} ${m[2]}',
        )
        .split(' ');

    return words
        .where((w) => w.isNotEmpty)
        .map((w) {
          final upper = w.toUpperCase();
          if (upper == 'ID' ||
              upper == 'IP' ||
              upper == 'URL' ||
              upper == 'PCT') {
            return upper == 'PCT' ? '(%)' : upper;
          }
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(' ');
  }

  static IconData _getKeyIcon(String key) {
    final lower = key.toLowerCase();
    if (lower.contains('amount') ||
        lower.contains('price') ||
        lower.contains('fee') ||
        lower.contains('cost') ||
        lower.contains('total') ||
        lower.contains('deposit') ||
        lower.contains('payment')) {
      return Iconsax.money_2;
    }
    if (lower.contains('status') || lower.contains('state')) {
      return Iconsax.status;
    }
    if (lower.contains('date') ||
        lower.contains('time') ||
        lower.endsWith('_at')) {
      return Iconsax.calendar_1;
    }
    if (lower.contains('id') ||
        lower.contains('code') ||
        lower.contains('reference') ||
        lower.contains('no') ||
        lower.contains('num')) {
      return Iconsax.hashtag;
    }
    if (lower.contains('user') ||
        lower.contains('customer') ||
        lower.contains('staff') ||
        lower.contains('person')) {
      return Iconsax.user;
    }
    if (lower.contains('note') ||
        lower.contains('remark') ||
        lower.contains('reason') ||
        lower.contains('comment') ||
        lower.contains('desc')) {
      return Iconsax.note_text;
    }
    if (lower.contains('item') ||
        lower.contains('board') ||
        lower.contains('product') ||
        lower.contains('equipment')) {
      return Iconsax.box;
    }
    if (lower.contains('change') || lower.contains('diff')) {
      return Iconsax.arrow_swap_horizontal;
    }
    if (lower.contains('url') || lower.contains('link')) {
      return Iconsax.link;
    }
    return Iconsax.document_text;
  }

  static bool _isCurrencyKey(String lowerKey) {
    return lowerKey.contains('amount') ||
        lowerKey.contains('price') ||
        lowerKey.contains('fee') ||
        lowerKey.contains('cost') ||
        lowerKey.contains('total') ||
        lowerKey.contains('deposit') ||
        lowerKey.contains('refund') ||
        lowerKey.contains('discount') ||
        lowerKey.contains('balance');
  }

  static bool _isStatusKey(String lowerKey) {
    return lowerKey == 'status' ||
        lowerKey == 'state' ||
        lowerKey.endsWith('_status') ||
        lowerKey.endsWith('_state');
  }

  static bool _isIdOrCodeKey(String lowerKey) {
    return lowerKey == 'id' ||
        lowerKey.endsWith('_id') ||
        lowerKey.contains('code') ||
        lowerKey.contains('ref') ||
        lowerKey.contains('reference') ||
        lowerKey.contains('invoice_no') ||
        lowerKey.contains('agreement_no');
  }

  static bool _isDateKey(String lowerKey, String value) {
    if (lowerKey.endsWith('_at') ||
        lowerKey.endsWith('_date') ||
        lowerKey.contains('timestamp') ||
        lowerKey == 'date') {
      return true;
    }
    return RegExp(r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}').hasMatch(value);
  }

  static (Color, Color) _getStatusBadgeColors(
      BuildContext context, String status) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantics = context.semanticColors;
    final lower = status.toLowerCase();

    if (lower.contains('complete') ||
        lower.contains('active') ||
        lower.contains('paid') ||
        lower.contains('success') ||
        lower.contains('approved') ||
        lower.contains('returned')) {
      return (semantics.success.withValues(alpha: 0.12), semantics.success);
    }
    if (lower.contains('pending') ||
        lower.contains('progress') ||
        lower.contains('hold') ||
        lower.contains('waiting')) {
      return (semantics.warning.withValues(alpha: 0.14), semantics.warning);
    }
    if (lower.contains('cancel') ||
        lower.contains('fail') ||
        lower.contains('damage') ||
        lower.contains('reject') ||
        lower.contains('delete')) {
      return (scheme.error.withValues(alpha: 0.12), scheme.error);
    }
    return (
      scheme.surfaceContainerHighest,
      scheme.onSurfaceVariant,
    );
  }

  static (IconData, Color) _getActivityVisuals(
      BuildContext context, String action) {
    final theme = Theme.of(context);
    final semantics = context.semanticColors;
    final lower = action.toLowerCase();

    if (lower.contains('delete')) {
      return (Iconsax.trash, theme.colorScheme.error);
    } else if (lower.contains('damage')) {
      return (Iconsax.warning_2, theme.colorScheme.error);
    } else if (lower.contains('create') || lower.contains('add')) {
      return (Iconsax.add_circle, semantics.success);
    } else if (lower.contains('update') || lower.contains('edit')) {
      return (Iconsax.edit_2, theme.colorScheme.primary);
    } else if (lower.contains('logged in') || lower.contains('login')) {
      return (Iconsax.login, semantics.info);
    } else if (lower.contains('logged out') || lower.contains('logout')) {
      return (Iconsax.logout, theme.colorScheme.onSurfaceVariant);
    } else if (lower.contains('payment')) {
      return (Iconsax.card, semantics.warning);
    } else if (lower.contains('rental')) {
      return (Iconsax.calendar_1, theme.colorScheme.primary);
    } else if (lower.contains('sale')) {
      return (Iconsax.shopping_bag, semantics.success);
    } else if (lower.contains('customer') || lower.contains('user')) {
      return (Iconsax.user, semantics.info);
    } else if (lower.contains('voucher') || lower.contains('promo')) {
      return (Iconsax.discount_shape, semantics.warning);
    } else {
      return (Iconsax.activity, theme.colorScheme.primary);
    }
  }
}
