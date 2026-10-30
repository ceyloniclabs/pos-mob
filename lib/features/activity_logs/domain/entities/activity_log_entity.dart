class ActivityLogEntity {
  final int id;
  final int? userId;
  final String userName;
  final String role;
  final String action;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const ActivityLogEntity({
    required this.id,
    this.userId,
    required this.userName,
    required this.role,
    required this.action,
    required this.createdAt,
    this.metadata,
  });

  ActivityLogEntity copyWith({
    int? id,
    int? userId,
    String? userName,
    String? role,
    String? action,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return ActivityLogEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isStaff => role.toLowerCase() == 'staff';
}
