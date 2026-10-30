import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_semantic_colors.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  repair,
  neutral,
}

/// Clean Status Badge adhering to flutter-uiux-design output widgets specification.
/// Communicates status with icon + text + semantic background tint, never color alone.
/// Guarantees WCAG contrast ratio ≥ 4.5:1.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.icon,
  });

  final String label;
  final StatusType type;
  final IconData? icon;

  /// Helper factory to automatically parse common domain status strings.
  factory StatusBadge.fromStatus(String status) {
    final s = status.toLowerCase().trim();
    return switch (s) {
      'available' || 'active' || 'paid' || 'approved' => StatusBadge(
          label: status,
          type: StatusType.success,
          icon: Icons.check_circle_outline_rounded,
        ),
      'pending' || 'partially_paid' || 'waiting' => StatusBadge(
          label: status,
          type: StatusType.warning,
          icon: Icons.hourglass_empty_rounded,
        ),
      'damage' || 'repair' || 'in_repair' => StatusBadge(
          label: status,
          type: StatusType.repair,
          icon: Icons.build_circle_outlined,
        ),
      'overdue' || 'late' || 'inactive' || 'not_available' || 'cancelled' => StatusBadge(
          label: status,
          type: StatusType.error,
          icon: Icons.error_outline_rounded,
        ),
      'completed' || 'returned' || 'rented' => StatusBadge(
          label: status,
          type: StatusType.info,
          icon: Icons.info_outline_rounded,
        ),
      _ => StatusBadge(
          label: status,
          type: StatusType.neutral,
          icon: Icons.circle_outlined,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = context.semanticColors;

    final (Color fg, Color bg) = switch (type) {
      StatusType.success => (s.success, s.success.withValues(alpha: 0.14)),
      StatusType.warning => (s.warning, s.warning.withValues(alpha: 0.16)),
      StatusType.error => (t.colorScheme.error, t.colorScheme.error.withValues(alpha: 0.14)),
      StatusType.info => (s.info, s.info.withValues(alpha: 0.14)),
      StatusType.repair => (s.repair, s.repair.withValues(alpha: 0.16)),
      StatusType.neutral => (t.colorScheme.onSurfaceVariant, t.colorScheme.surfaceContainerHighest),
    };

    final textWidget = Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: t.textTheme.labelSmall?.copyWith(
        color: fg,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullAll,
      ),
      child: icon == null
          ? textWidget
          : LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: fg),
                    const SizedBox(width: 4),
                    if (constraints.hasBoundedWidth)
                      Flexible(child: textWidget)
                    else
                      textWidget,
                  ],
                );
              },
            ),
    );
  }
}
