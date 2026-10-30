import 'package:flutter/material.dart';

/// Window size classes according to Material 3 standard.
enum ScreenSize { compact, medium, expanded }

/// Extension on BuildContext for quick and performant responsive measurements.
/// Uses MediaQuery.sizeOf(context) to avoid unnecessary rebuilds on unrelated media changes.
extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize {
    final w = MediaQuery.sizeOf(this).width;
    if (w < 600) return ScreenSize.compact;
    if (w < 840) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isMedium => screenSize == ScreenSize.medium;
  bool get isExpanded => screenSize == ScreenSize.expanded;
}

/// Centers and constrains content (forms, details, dialogs) on wider screens (tablets, foldables).
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

/// Adaptive builder switching between compact (phone), medium (foldable/tablet), and expanded layouts.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    return switch (context.screenSize) {
      ScreenSize.expanded => (expanded ?? medium ?? compact)(context),
      ScreenSize.medium => (medium ?? compact)(context),
      ScreenSize.compact => compact(context),
    };
  }
}
