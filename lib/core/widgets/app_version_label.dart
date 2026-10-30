import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pos/core/services/app_info_service.dart';

class AppVersionLabel extends StatelessWidget {
  final String prefix;
  final TextStyle? style;

  const AppVersionLabel({super.key, this.prefix = 'Version ', this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: Get.find<AppInfoService>().packageInfo,
      builder: (context, snapshot) {
        final label = snapshot.hasError
            ? 'Version unavailable'
            : snapshot.hasData
            ? '$prefix${snapshot.data!.version}'
            : 'Loading version...';
        return Text(label, style: style);
      },
    );
  }
}
