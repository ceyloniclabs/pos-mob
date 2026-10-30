import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Clean Custom AppBar respecting Material 3 design and minimum touch targets.
/// Accepts either a String or a Widget for `title`.
class CustomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomeAppBar({
    super.key,
    this.title,
    this.showbackArrow = false,
    this.leadingIcon,
    this.leading,
    this.actions,
    this.leadingOnPressed,
    this.bottom,
    this.centerTitle = false,
    this.popupMenuItems,
    this.onPopupMenuSelected,
    this.showDrawer = false,
    this.backgroundColor,
    this.elevation,
    this.titleTextStyle,
  });

  /// The title can be passed as a [String] or a custom [Widget].
  final dynamic title;
  final bool showbackArrow;
  final IconData? leadingIcon;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool showDrawer;
  final Color? backgroundColor;
  final double? elevation;
  final TextStyle? titleTextStyle;

  final List<PopupMenuEntry>? popupMenuItems;
  final void Function(dynamic)? onPopupMenuSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (showDrawer) {
      leadingWidget = IconButton(
        icon: const Icon(Iconsax.menu_1, size: 22),
        tooltip: 'Menu',
        onPressed: () => Scaffold.of(context).openDrawer(),
      );
    } else if (showbackArrow) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        tooltip: 'Back',
        onPressed: leadingOnPressed ?? () => Get.back(),
      );
    } else if (leadingIcon != null) {
      leadingWidget = IconButton(
        icon: Icon(leadingIcon, size: 22),
        onPressed: leadingOnPressed,
      );
    }

    Widget? titleWidget;
    if (title is String) {
      titleWidget = Text(
        title as String,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleTextStyle ??
            theme.appBarTheme.titleTextStyle ??
            theme.textTheme.titleMedium?.copyWith(
              fontSize: 18.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
      );
    } else if (title is Widget) {
      titleWidget = title as Widget;
    }

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: leadingWidget,
      title: titleWidget,
      actions: [
        ...?actions,
        if (popupMenuItems != null)
          PopupMenuButton(
            tooltip: 'More options',
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            onSelected: onPopupMenuSelected,
            itemBuilder: (context) => popupMenuItems!,
          ),
        AppSpacing.hGapXs,
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
