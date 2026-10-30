import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/widgets/custom_button.dart';

/// Clean bottom action bar conforming to Material 3 and flutter-uiux-design guidelines.
/// Places primary actions thumb-accessible above navigation/home indicators with clean outline border.
class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    required this.child,
    this.padding,
  });

  /// Factory helper for creating standard primary CTA bottom bars.
  factory AppBottomActionBar.primaryAction({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Widget? leading,
  }) {
    return AppBottomActionBar(
      key: key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading,
            AppSpacing.gapMd,
          ],
          AppButton(
            label: label,
            icon: icon,
            isLoading: isLoading,
            onPressed: onPressed,
            type: AppButtonType.primary,
            expand: true,
          ),
        ],
      ),
    );
  }

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: child,
          ),
        ),
      ),
    );
  }
}
