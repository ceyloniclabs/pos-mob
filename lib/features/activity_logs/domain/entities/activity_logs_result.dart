import 'activity_filter_options.dart';
import 'activity_log_entity.dart';

class ActivityLogsResult {
  final List<ActivityLogEntity> logs;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final String? nextPageUrl;
  final bool hasNextPageLink;
  final List<ActivityActionOption> availableActions;
  final List<ActivityStaffOption> availableStaffMembers;

  const ActivityLogsResult({
    required this.logs,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
    this.hasNextPageLink = false,
    required this.availableActions,
    required this.availableStaffMembers,
  });

  bool get hasMorePages {
    if (hasNextPageLink) {
      return nextPageUrl != null &&
          nextPageUrl!.isNotEmpty &&
          nextPageUrl != 'null';
    }
    return currentPage < lastPage;
  }
}
