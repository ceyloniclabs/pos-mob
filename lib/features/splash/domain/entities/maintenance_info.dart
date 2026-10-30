class MaintenanceInfo {
  final String message;
  final String? estimatedEndTime;
  final bool isFullMaintenance;
  final String? affectedFeature;

  const MaintenanceInfo({
    required this.message,
    this.estimatedEndTime,
    this.isFullMaintenance = true,
    this.affectedFeature,
  });

  factory MaintenanceInfo.fromJson(Map<String, dynamic> json) {
    return MaintenanceInfo(
      message: json['maintenance_message']?.toString() ??
          json['message']?.toString() ??
          'System is currently undergoing routine maintenance. Please try again soon.',
      estimatedEndTime: json['maintenance_eta']?.toString() ??
          json['estimated_end_time']?.toString(),
      isFullMaintenance: json['is_full_maintenance'] ?? true,
      affectedFeature: json['affected_feature']?.toString(),
    );
  }
}
