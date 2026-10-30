import '../../domain/entities/app_version_info.dart';

class AppVersionInfoModel extends AppVersionInfo {
  const AppVersionInfoModel({
    required super.latestVersion,
    required super.latestBuildNumber,
    required super.isForceUpdate,
    super.updateMessage,
    super.storeUrl,
    super.isMaintenance,
    super.maintenanceMessage,
    super.maintenanceEta,
  });

  factory AppVersionInfoModel.fromJson(Map<String, dynamic> json) {
    return AppVersionInfoModel(
      latestVersion: json['latest_version']?.toString() ?? '1.0.0',
      latestBuildNumber: int.tryParse(json['latest_build']?.toString() ?? '0') ?? 0,
      isForceUpdate: json['is_force_update'] == true,
      updateMessage: json['update_message']?.toString(),
      storeUrl: json['store_url']?.toString(),
      isMaintenance: json['maintenance'] == true,
      maintenanceMessage: json['maintenance_message']?.toString(),
      maintenanceEta: json['maintenance_eta']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_version': latestVersion,
      'latest_build': latestBuildNumber,
      'is_force_update': isForceUpdate,
      'update_message': updateMessage,
      'store_url': storeUrl,
      'maintenance': isMaintenance,
      'maintenance_message': maintenanceMessage,
      'maintenance_eta': maintenanceEta,
    };
  }

  factory AppVersionInfoModel.fromEntity(AppVersionInfo entity) {
    return AppVersionInfoModel(
      latestVersion: entity.latestVersion,
      latestBuildNumber: entity.latestBuildNumber,
      isForceUpdate: entity.isForceUpdate,
      updateMessage: entity.updateMessage,
      storeUrl: entity.storeUrl,
      isMaintenance: entity.isMaintenance,
      maintenanceMessage: entity.maintenanceMessage,
      maintenanceEta: entity.maintenanceEta,
    );
  }
}
