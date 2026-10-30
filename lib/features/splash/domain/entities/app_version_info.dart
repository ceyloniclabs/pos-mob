class AppVersionInfo {
  final String latestVersion;
  final int latestBuildNumber;
  final bool isForceUpdate;
  final String? updateMessage;
  final String? storeUrl;
  final bool isMaintenance;
  final String? maintenanceMessage;
  final String? maintenanceEta;

  const AppVersionInfo({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.isForceUpdate,
    this.updateMessage,
    this.storeUrl,
    this.isMaintenance = false,
    this.maintenanceMessage,
    this.maintenanceEta,
  });

  AppVersionInfo copyWith({
    String? latestVersion,
    int? latestBuildNumber,
    bool? isForceUpdate,
    String? updateMessage,
    String? storeUrl,
    bool? isMaintenance,
    String? maintenanceMessage,
    String? maintenanceEta,
  }) {
    return AppVersionInfo(
      latestVersion: latestVersion ?? this.latestVersion,
      latestBuildNumber: latestBuildNumber ?? this.latestBuildNumber,
      isForceUpdate: isForceUpdate ?? this.isForceUpdate,
      updateMessage: updateMessage ?? this.updateMessage,
      storeUrl: storeUrl ?? this.storeUrl,
      isMaintenance: isMaintenance ?? this.isMaintenance,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      maintenanceEta: maintenanceEta ?? this.maintenanceEta,
    );
  }
}
