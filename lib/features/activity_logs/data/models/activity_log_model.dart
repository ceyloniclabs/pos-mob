import '../../../../core/utils/app_date_time_utils.dart';
import '../../domain/entities/activity_log_entity.dart';

class ActivityLogModel extends ActivityLogEntity {
  const ActivityLogModel({
    required super.id,
    super.userId,
    required super.userName,
    required super.role,
    required super.action,
    required super.createdAt,
    super.metadata,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse(rawId?.toString() ?? '0') ?? 0);

    final rawUserId = json['user_id'];
    final userId = rawUserId != null
        ? (rawUserId is int ? rawUserId : int.tryParse(rawUserId.toString()))
        : null;

    final userName = json['user_name']?.toString() ?? 'System';
    final role = json['role']?.toString() ?? 'staff';
    final action = json['action']?.toString() ?? '';

    final rawDate = json['created_at'];
    final parsedLocal = AppDateTimeUtils.toLocal(rawDate);
    final createdAt = parsedLocal ?? DateTime.now();

    // Future-proof metadata capture (checks metadata, meta_data, changes, details)
    Map<String, dynamic>? metadata;
    if (json['metadata'] is Map<String, dynamic>) {
      metadata = json['metadata'] as Map<String, dynamic>;
    } else if (json['meta_data'] is Map<String, dynamic>) {
      metadata = json['meta_data'] as Map<String, dynamic>;
    } else if (json['changes'] is Map<String, dynamic>) {
      metadata = json['changes'] as Map<String, dynamic>;
    } else if (json['details'] is Map<String, dynamic>) {
      metadata = json['details'] as Map<String, dynamic>;
    }

    return ActivityLogModel(
      id: id,
      userId: userId,
      userName: userName,
      role: role,
      action: action,
      createdAt: createdAt,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'role': role,
        'action': action,
        'created_at': createdAt.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };
}
