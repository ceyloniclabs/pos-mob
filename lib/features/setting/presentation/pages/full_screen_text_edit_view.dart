import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/app_bottom_action_bar.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';

/// Professional Full Screen Legal & Policy Document Editor.
/// Redesigned with:
/// - Compact, maximum-height text editor with responsive zero-overflow header
/// - High-contrast, clearly visible Cancel button alongside primary Apply CTA
/// - Real-time word and character counter
/// - Dual mode: Edit Mode & Formatted Preview Mode
/// - Quick utility actions: Copy, Clear, and Starter Template generation
class FullScreenTextEditView extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final String hint;

  const FullScreenTextEditView({
    super.key,
    required this.title,
    required this.controller,
    required this.hint,
  });

  @override
  State<FullScreenTextEditView> createState() => _FullScreenTextEditViewState();
}

class _FullScreenTextEditViewState extends State<FullScreenTextEditView> {
  late String _initialText;
  int _tabIndex = 0; // 0: Edit, 1: Preview
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _initialText = widget.controller.text;
    _focusNode = FocusNode();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  int get _charCount => widget.controller.text.length;

  void _copyToClipboard() {
    final text = widget.controller.text;
    if (text.trim().isEmpty) {
      ScaffoldMessageUtils.showError('No text to copy');
      return;
    }
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessageUtils.showSuccess('Copied to clipboard');
  }

  Future<bool?> _showActionDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required IconData icon,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final primaryColor =
        isDestructive ? colorScheme.error : colorScheme.primary;
    final onPrimaryColor =
        isDestructive ? colorScheme.onError : colorScheme.onPrimary;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 6,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 460,
            minWidth: 320,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Badge icon + Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Message text
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2),
                  child: Text(
                    message,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Actions row: Aligned to end
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: primaryColor,
                        foregroundColor: onPrimaryColor,
                        minimumSize: const Size(88, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearContent() {
    if (widget.controller.text.isEmpty) return;
    _showActionDialog(
      title: 'Clear Document Text?',
      message:
          'Are you sure you want to clear all text in this document? This action cannot be undone unless discarded.',
      confirmLabel: 'Clear',
      icon: Iconsax.trash,
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        widget.controller.clear();
      }
    });
  }

  void _insertTemplate() {
    final isPrivacy = widget.title.toLowerCase().contains('privacy');
    final template = isPrivacy ? _privacyPolicyTemplate : _termsConditionsTemplate;

    if (widget.controller.text.trim().isNotEmpty) {
      _showActionDialog(
        title: 'Replace with Template?',
        message:
            'Inserting a sample template will replace your current text. Do you want to proceed?',
        confirmLabel: 'Replace',
        icon: Iconsax.document_download,
        isDestructive: false,
      ).then((confirmed) {
        if (confirmed == true) {
          widget.controller.text = template;
          ScaffoldMessageUtils.showSuccess('Standard template applied');
        }
      });
    } else {
      widget.controller.text = template;
      ScaffoldMessageUtils.showSuccess('Standard template inserted');
    }
  }

  void _revertChanges() {
    widget.controller.text = _initialText;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomeAppBar(
        title: widget.title,
        showbackArrow: true,
        leadingOnPressed: () {
          Get.back();
        },
        actions: [
          IconButton(
            icon: const Icon(Iconsax.copy, size: 20),
            tooltip: 'Copy all',
            onPressed: _copyToClipboard,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.more, size: 20),
            tooltip: 'More actions',
            onSelected: (val) {
              if (val == 'template') _insertTemplate();
              if (val == 'clear') _clearContent();
              if (val == 'revert') _revertChanges();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [
                    Icon(Iconsax.document_download, size: 18),
                    SizedBox(width: 10),
                    Text('Insert Standard Template'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'revert',
                child: Row(
                  children: [
                    Icon(Iconsax.refresh, size: 18),
                    SizedBox(width: 10),
                    Text('Revert to Original'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 18, color: colorScheme.error),
                    const SizedBox(width: 10),
                    Text('Clear All Text',
                        style: TextStyle(color: colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapXs,
        ],
      ),
      bottomNavigationBar: AppBottomActionBar(
        child: Row(
          children: [
            // Prominent, highly visible Cancel button
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () {
                  widget.controller.text = _initialText;
                  Get.back();
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 1.2,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
              ),
            ),
            AppSpacing.gapMd,
            // Primary Apply / Done button
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Iconsax.tick_circle, size: 18),
                label: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 760,
          child: Column(
            children: [
              // Responsive, compact top bar (Overflow-free)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Compact Segmented Mode Selector
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTabButton(
                            index: 0,
                            label: 'Edit',
                            icon: Iconsax.edit,
                          ),
                          _buildTabButton(
                            index: 1,
                            label: 'Preview',
                            icon: Iconsax.eye,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Responsive Word Count Badge (Never overflows)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.textalign_left,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$_wordCount words',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Editor / Preview Body
              Expanded(
                child: _tabIndex == 0
                    ? _buildEditorView(theme)
                    : _buildPreviewView(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = _tabIndex == index;

    return InkWell(
      onTap: () {
        if (_tabIndex != index) {
          setState(() {
            _tabIndex = index;
            if (index == 0) {
              _focusNode.requestFocus();
            } else {
              _focusNode.unfocus();
            }
          });
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorView(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.55,
                  letterSpacing: 0.15,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.hint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Compact bottom helper row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  size: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tap Apply below to save changes to the shop profile.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_charCount chars',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView(ThemeData theme) {
    final text = widget.controller.text.trim();

    if (text.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.document_text,
                size: 40,
                color: theme.colorScheme.outline,
              ),
              AppSpacing.gapSm,
              Text(
                'No content to preview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapXs,
              Text(
                'Switch back to the Edit tab or insert a template to get started.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapMd,
              FilledButton.tonalIcon(
                onPressed: _insertTemplate,
                icon: const Icon(Iconsax.magicpen, size: 16),
                label: const Text('Insert Standard Template'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            backgroundColor: theme.colorScheme.surfaceContainerLowest,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Iconsax.verify,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Customer-facing legal document',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                SelectableText(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    letterSpacing: 0.15,
                  ),
                ),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.shield_tick,
                        size: 15,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Displayed on customer receipts, booking agreements, and rental contracts.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapLg,
        ],
      ),
    );
  }

  static const String _privacyPolicyTemplate = '''1. Information We Collect
We collect personal identification information, including name, email address, phone number, and identification documents (e.g. passport or national ID) required for surfboard rental agreements and security deposits.

2. How We Use Your Information
Your information is strictly used to:
- Process and manage surfboard equipment rentals and returns.
- Communicate regarding booking status, return reminders, and damage reports.
- Maintain safety records and emergency contact details while you are on the water.

3. Equipment Security & Identification
Identification copies or security deposit records are kept secure during the active rental period and processed in accordance with applicable consumer protection guidelines.

4. Data Protection & Third Parties
We do not sell, trade, or transfer your personal data to outside parties. Your information is retained solely for accounting, tax compliance, and shop operations.

5. Inquiries & Updates
If you have questions regarding this Privacy Policy or wish to request data updates, please contact the shop administration directly.''';

  static const String _termsConditionsTemplate = '''1. Rental Agreement & Equipment Inspection
The renter agrees that all surfboards, leashes, fins, and accessories have been inspected prior to departure and are received in good working condition.

2. Proper Care & Operating Responsibility
The renter agrees to use equipment safely, within designated surfing zones, and acknowledges that ocean activities involve inherent risks. Equipment must not be lent, sublet, or transferred to third parties.

3. Return Times & Grace Period
Equipment must be returned promptly at or before the scheduled return time. Late returns exceeding the authorized grace period will incur additional rental hourly or daily charges according to shop policy.

4. Damage, Loss, & Repair Policy
In the event of ding, fracture, broken fin box, snapped board, or lost accessories (including leash or fins), the renter agrees to pay the standard repair or replacement fees as assessed by the shop manager.

5. Deposit & Refund Policy
Security deposits are refunded in full upon safe and undamaged return of all rented gear. Failure to return equipment constitutes theft and may be reported to local authorities.''';
}
