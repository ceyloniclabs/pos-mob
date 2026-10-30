import '../../domain/entities/activity_logs_result.dart';
import 'activity_filter_models.dart';
import 'activity_log_model.dart';

class ActivityLogsResponseModel extends ActivityLogsResult {
  const ActivityLogsResponseModel({
    required super.logs,
    required super.currentPage,
    required super.lastPage,
    required super.total,
    required super.perPage,
    super.nextPageUrl,
    super.hasNextPageLink = false,
    required super.availableActions,
    required super.availableStaffMembers,
  });

  factory ActivityLogsResponseModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse data list
    final rawData = json['data'] as List? ?? [];
    final logs = rawData
        .map((e) => ActivityLogModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    // 2. Parse meta & links
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final currentPage = meta['current_page'] is int
        ? meta['current_page'] as int
        : (int.tryParse(meta['current_page']?.toString() ?? '1') ?? 1);
    final lastPage = meta['last_page'] is int
        ? meta['last_page'] as int
        : (int.tryParse(meta['last_page']?.toString() ?? '1') ?? 1);
    final total = meta['total'] is int
        ? meta['total'] as int
        : (int.tryParse(meta['total']?.toString() ?? '0') ?? 0);
    final perPage = meta['per_page'] is int
        ? meta['per_page'] as int
        : (int.tryParse(meta['per_page']?.toString() ?? '10') ?? 10);

    String? nextPageUrl;
    bool hasNextPageLink = false;
    if (json['links'] is Map && (json['links'] as Map).containsKey('next')) {
      hasNextPageLink = true;
      nextPageUrl = (json['links'] as Map)['next']?.toString();
    }

    // 3. Parse actions list
    final rawActions = json['actions'] as List? ?? [];
    final actions = rawActions
        .map((e) => ActivityActionOptionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    // 4. Parse staff_members list
    final rawStaff = json['staff_members'] as List? ?? [];
    final staff = rawStaff
        .map((e) => ActivityStaffOptionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ActivityLogsResponseModel(
      logs: logs,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      perPage: perPage,
      nextPageUrl: nextPageUrl,
      hasNextPageLink: hasNextPageLink,
      availableActions: actions,
      availableStaffMembers: staff,
    );
  }
}
