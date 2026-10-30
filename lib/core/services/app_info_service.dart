import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  Future<PackageInfo>? _packageInfo;

  Future<PackageInfo> get packageInfo =>
      _packageInfo ??= PackageInfo.fromPlatform();
}
