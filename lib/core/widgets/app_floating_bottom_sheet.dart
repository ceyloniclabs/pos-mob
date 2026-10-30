import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_durations.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A reusable floating bottom sheet conforming to Material 3 & flutter-uiux-design guidelines.
///
/// Features:
/// - Floating visual style: elevated card hovering above bottom edge with outer padding & rounded corners.
/// - Default intrinsic height: opens taking the natural height of inside widgets.
/// - Drag to expand: users can drag the handle/header upward to expand up to [maxHeightFactor].
/// - Drag to dismiss: users can drag downward to dismiss.
/// - Tap to toggle: tapping the drag handle toggles between default and expanded view.
/// - Pinned footer support: keeps primary CTA buttons pinned at the bottom while content scrolls.
/// - Keyboard aware: automatically floats above software keyboard.
class AppFloatingBottomSheet extends StatefulWidget {
  const AppFloatingBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.header,
    this.footer,
    this.contentPadding,
    this.footerPadding,
    this.maxWidth = 600.0,
    this.maxHeightFactor = 0.88,
    this.borderRadius,
    this.onClose,
    this.isFloating = true,
  });

  /// The scrollable or flex content widget inside the sheet.
  final Widget child;

  /// Optional sheet title.
  final String? title;

  /// Optional descriptive subtitle under the title.
  final String? subtitle;

  /// Optional leading widget in header (e.g., an icon container).
  final Widget? leading;

  /// Optional trailing widget in header (placed next to close button).
  final Widget? trailing;

  /// Whether to show a close icon button in the header. Default `true`.
  final bool showCloseButton;

  /// Whether to show the top drag handle bar. Default `true`.
  final bool showDragHandle;

  /// Custom header widget. If provided, replaces the default header.
  final Widget? header;

  /// Pinned bottom footer (e.g. action buttons).
  final Widget? footer;

  /// Padding around the scrollable [child].
  final EdgeInsetsGeometry? contentPadding;

  /// Padding around the pinned [footer].
  final EdgeInsetsGeometry? footerPadding;

  /// Max horizontal constraint for tablet/desktop responsiveness.
  final double maxWidth;

  /// Maximum screen height fraction when fully expanded (0.0 - 1.0).
  final double maxHeightFactor;

  /// Corner radius of the floating sheet. Defaults to 20dp when floating, or 24dp top radius when docked.
  final BorderRadius? borderRadius;

  /// Callback when close button is tapped. Defaults to `Navigator.of(context).pop()`.
  final VoidCallback? onClose;

  /// Whether the sheet floats with margins on all sides ([isFloating] = true)
  /// or docks to the bottom edge as a standard bottom sheet ([isFloating] = false).
  final bool isFloating;

  /// Convenience method to display the floating bottom sheet as a modal.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    bool showCloseButton = true,
    bool showDragHandle = true,
    Widget? header,
    Widget? footer,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? footerPadding,
    double maxWidth = 600.0,
    double maxHeightFactor = 0.88,
    BorderRadius? borderRadius,
    bool isDismissible = true,
    VoidCallback? onClose,
    bool isFloating = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isDismissible: isDismissible,
      enableDrag: false,
      builder: (context) => AppFloatingBottomSheet(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        showCloseButton: showCloseButton,
        showDragHandle: showDragHandle,
        header: header,
        footer: footer,
        contentPadding: contentPadding,
        footerPadding: footerPadding,
        maxWidth: maxWidth,
        maxHeightFactor: maxHeightFactor,
        borderRadius: borderRadius,
        onClose: onClose,
        isFloating: isFloating,
        child: child,
      ),
    );
  }

  @override
  State<AppFloatingBottomSheet> createState() => _AppFloatingBottomSheetState();
}

class _AppFloatingBottomSheetState extends State<AppFloatingBottomSheet>
    with SingleTickerProviderStateMixin {
  final GlobalKey _sheetKey = GlobalKey();

  double? _initialHeight;
  double? _currentHeight;
  double _dragDownOffset = 0.0;
  bool _isExpanded = false;

  double _dragStartY = 0.0;
  double _startHeight = 0.0;

  late final AnimationController _animController;
  Animation<double>? _heightAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _sheetKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        setState(() {
          _initialHeight = box.size.height;
          _currentHeight = _initialHeight;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _calculateMaxHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topOffset = widget.isFloating ? 32.0 : 16.0;
    final available = mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        mediaQuery.viewInsets.bottom -
        topOffset;
    return available * widget.maxHeightFactor;
  }

  void _animateTo(double targetHeight, {required bool expanded}) {
    _animController.stop();
    final start = _currentHeight ?? _initialHeight ?? targetHeight;
    _heightAnim = Tween<double>(begin: start, end: targetHeight).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    )..addListener(() {
        setState(() {
          _currentHeight = _heightAnim!.value;
          _isExpanded = expanded;
        });
      });

    _animController.forward(from: 0.0);
  }

  void _onDragStart(DragStartDetails details) {
    _animController.stop();
    _dragStartY = details.globalPosition.dy;
    _startHeight = _currentHeight ?? _initialHeight ?? 300.0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final deltaY = _dragStartY - details.globalPosition.dy; // positive when dragging UP
    final maxH = _calculateMaxHeight(context);
    final minH = _initialHeight ?? 200.0;

    if (deltaY >= 0) {
      // Dragging UP -> expand
      _dragDownOffset = 0.0;
      final targetH = (_startHeight + deltaY).clamp(minH, maxH);
      setState(() {
        _isExpanded = targetH > (minH + 24.0);
        _currentHeight = targetH;
      });
    } else {
      // Dragging DOWN
      final targetH = _startHeight + deltaY;
      if (targetH >= minH) {
        setState(() {
          _dragDownOffset = 0.0;
          _isExpanded = targetH > (minH + 24.0);
          _currentHeight = targetH;
        });
      } else {
        // Pulled below baseline -> rubber band down towards dismiss
        setState(() {
          _currentHeight = minH;
          _isExpanded = false;
          _dragDownOffset = (minH - targetH).clamp(0.0, 160.0);
        });
      }
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0; // positive is downwards
    final maxH = _calculateMaxHeight(context);
    final minH = _initialHeight ?? 200.0;

    if (_dragDownOffset > 45.0 || velocity > 350.0) {
      // Dragged down sufficiently -> dismiss
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.of(context).pop();
      }
    } else if (velocity < -350.0) {
      // Flung up -> snap to max
      _animateTo(maxH, expanded: true);
    } else {
      // Settle
      if (_dragDownOffset > 0.0) {
        setState(() => _dragDownOffset = 0.0);
      }
      final current = _currentHeight ?? minH;
      final threshold = minH + (maxH - minH) * 0.35;
      if (current > threshold) {
        _animateTo(maxH, expanded: true);
      } else {
        _animateTo(minH, expanded: false);
      }
    }
  }

  void _toggleExpanded() {
    final maxH = _calculateMaxHeight(context);
    final minH = _initialHeight ?? 200.0;
    if (_isExpanded) {
      _animateTo(minH, expanded: false);
    } else {
      _animateTo(maxH, expanded: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final maxH = _calculateMaxHeight(context);

    final bottomMargin = widget.isFloating
        ? (math.max(mediaQuery.padding.bottom, AppSpacing.md) +
            mediaQuery.viewInsets.bottom)
        : mediaQuery.viewInsets.bottom;

    final outerPadding = widget.isFloating
        ? EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: bottomMargin,
            top: mediaQuery.padding.top + AppSpacing.md,
          )
        : EdgeInsets.only(
            left: 0,
            right: 0,
            bottom: bottomMargin,
            top: mediaQuery.padding.top + AppSpacing.xs,
          );

    final sheetBorderRadius = widget.borderRadius ??
        (widget.isFloating
            ? BorderRadius.circular(20.0)
            : const BorderRadius.vertical(top: Radius.circular(24.0)));

    final defaultFooterPadding = widget.isFloating
        ? const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.md,
          )
        : EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            math.max(mediaQuery.padding.bottom, AppSpacing.md),
          );

    final defaultContentPadding = widget.isFloating
        ? const EdgeInsets.symmetric(horizontal: AppSpacing.lg)
        : EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            widget.footer != null
                ? 0
                : math.max(mediaQuery.padding.bottom, AppSpacing.md),
          );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: outerPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
            maxHeight: maxH,
          ),
          child: Transform.translate(
            offset: Offset(0, _dragDownOffset),
            child: Material(
              color: theme.colorScheme.surface,
              elevation: widget.isFloating ? 8 : 4,
              shadowColor: Colors.black.withValues(
                alpha: widget.isFloating ? 0.28 : 0.18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: sheetBorderRadius,
                side: BorderSide(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                key: _sheetKey,
                height: _currentHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Draggable Handle & Header area
                    _buildDraggableHeader(context),

                    // Scrollable content body
                    Flexible(
                      fit: _isExpanded ? FlexFit.tight : FlexFit.loose,
                      child: SingleChildScrollView(
                        padding: widget.contentPadding ?? defaultContentPadding,
                        physics: const ClampingScrollPhysics(),
                        child: widget.child,
                      ),
                    ),

                    // Pinned bottom footer (e.g. action buttons)
                    if (widget.footer != null) ...[
                      Padding(
                        padding: widget.footerPadding ?? defaultFooterPadding,
                        child: widget.footer!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle Bar ──────────────────────────────────────────
          if (widget.showDragHandle)
            InkWell(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                ),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: AppRadius.fullAll,
                    ),
                  ),
                ),
              ),
            ),

          // ── Header Title & Actions ───────────────────────────────────
          if (widget.header != null)
            widget.header!
          else if (widget.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    AppSpacing.gapSm,
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title!,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    widget.trailing!,
                    AppSpacing.gapXs,
                  ],
                  if (widget.showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
