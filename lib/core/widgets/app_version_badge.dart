import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/app_info_service.dart';
import '../theme/app_spacing.dart';

/// Common reusable widget displaying app branding, version, and copyright notice.
/// 
/// Supported options:
/// - [showIcon]: Toggle circular app icon (defaults to true).
/// - [showCopyright]: Toggle copyright statement (defaults to true).
/// - [showBuildNumber]: Toggle build number display (defaults to false).
/// - [appName]: App name display (defaults to 'SurfDesk').
/// - [iconSize]: Size of circular app icon (defaults to 44.0).
class AppVersionBadge extends StatelessWidget {
  final bool showIcon;
  final bool showCopyright;
  final bool showBuildNumber;
  final String appName;
  final double iconSize;

  const AppVersionBadge({
    super.key,
    this.showIcon = true,
    this.showCopyright = true,
    this.showBuildNumber = false,
    this.appName = 'SurfDesk',
    this.iconSize = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final infoFuture = Get.isRegistered<AppInfoService>()
        ? Get.find<AppInfoService>().packageInfo
        : PackageInfo.fromPlatform();

    final copyrightColor = isDark ? Colors.white60 : Colors.black54;

    return FutureBuilder<PackageInfo>(
      future: infoFuture,
      builder: (context, snapshot) {
        final versionText = snapshot.hasError
            ? 'Version unavailable'
            : snapshot.hasData
                ? (showBuildNumber
                    ? 'Version ${snapshot.data!.version} (Build ${snapshot.data!.buildNumber})'
                    : 'Version ${snapshot.data!.version}')
                : 'Loading version...';

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular App Icon
            if (showIcon) ...[
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(
                        alpha: isDark ? 0.35 : 0.06,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/appstore.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              AppSpacing.gapSm,
            ],

            // Field 1: App Name
            Text(
              appName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),

            // Field 2: Version
            Text(
              versionText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),

            // Field 3: Copyright
            if (showCopyright) ...[
              const SizedBox(height: 4),
              Text(
                '© ${DateTime.now().year} $appName. All rights reserved.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: copyrightColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
