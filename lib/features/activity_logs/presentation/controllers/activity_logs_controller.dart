import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/app_logger.dart';
import 'package:pos/features/manage_staff/domain/entities/staff.dart';

import '../../domain/entities/activity_filter_options.dart';
import '../../domain/entities/activity_filter_params.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/usecases/get_activity_logs_use_case.dart';

class ActivityLogsController extends GetxController {
  final GetActivityLogsUseCase getActivityLogsUseCase;

  ActivityLogsController({
    required this.getActivityLogsUseCase,
  });

  static const int _pageSize = 10;

  final PagingController<int, ActivityLogEntity> pagingController =
      PagingController(
        firstPageKey: 1,
        invisibleItemsThreshold: 1,
      );

  final TextEditingController searchInputController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxList<ActivityActionOption> availableActions =
      <ActivityActionOption>[].obs;
  final RxList<ActivityStaffOption> availableStaffMembers =
      <ActivityStaffOption>[].obs;

  final Rxn<ActivityStaffOption> selectedStaff = Rxn<ActivityStaffOption>();
  final RxString selectedRole = 'all'.obs;
  final Rxn<ActivityActionOption> selectedAction = Rxn<ActivityActionOption>();
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();

    // Check if arguments were passed (e.g. from StaffDetailsView)
    final args = Get.arguments;
    if (args is Staff) {
      selectedStaff.value = ActivityStaffOption(
        id: args.id,
        name: args.name,
        email: args.email,
        role: args.role,
      );
      if (args.role.isNotEmpty && args.role.toLowerCase() != 'all') {
        selectedRole.value = args.role.toLowerCase();
      }
    } else if (args is Map) {
      if (args['staffId'] != null) {
        selectedStaff.value = ActivityStaffOption(
          id: args['staffId'] is int
              ? args['staffId'] as int
              : (int.tryParse(args['staffId'].toString()) ?? 0),
          name: args['staffName']?.toString() ?? 'Staff Member',
          email: args['email']?.toString() ?? '',
          role: args['role']?.toString() ?? 'staff',
        );
      }
      if (args['role'] != null && args['role'].toString().toLowerCase() != 'all') {
        selectedRole.value = args['role'].toString().toLowerCase();
      }
    }

    pagingController.addPageRequestListener((pageKey) {
      fetchLogs(pageKey);
    });

    debounce(
      searchQuery,
      (_) => pagingController.refresh(),
      time: const Duration(milliseconds: 350),
    );
  }

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedStaff.value != null ||
      selectedRole.value != 'all' ||
      selectedAction.value != null ||
      startDate.value != null ||
      endDate.value != null;

  int get activeFilterCount {
    int count = 0;
    if (selectedStaff.value != null) count++;
    if (selectedRole.value != 'all') count++;
    if (selectedAction.value != null) count++;
    if (startDate.value != null || endDate.value != null) count++;
    return count;
  }

  Future<void> fetchLogs(int pageKey) async {
    try {
      final params = ActivityFilterParams(
        page: pageKey,
        perPage: _pageSize,
        userId: selectedStaff.value?.id,
        role: selectedRole.value == 'all' ? null : selectedRole.value,
        action: selectedAction.value?.value,
        startDate: startDate.value,
        endDate: endDate.value,
        search: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
      );

      AppLogger.debug(
        '📜 [ActivityLogsController] Fetching logs: page=$pageKey, params=${params.toQueryParameters()}',
      );

      final result = await getActivityLogsUseCase.execute(params);

      AppLogger.debug(
        '📜 [ActivityLogsController] Page $pageKey loaded ${result.logs.length} logs (currentPage=${result.currentPage}, lastPage=${result.lastPage}, total=${result.total}, hasMore=${result.hasMorePages})',
      );

      // Populate filter option lists if not yet populated
      if (availableActions.isEmpty && result.availableActions.isNotEmpty) {
        availableActions.assignAll(result.availableActions);
      }
      if (availableStaffMembers.isEmpty &&
          result.availableStaffMembers.isNotEmpty) {
        availableStaffMembers.assignAll(result.availableStaffMembers);
      }

      if (isClosed) return;
      pagingController.appendPageResult(
        newItems: PaginatedList<ActivityLogEntity>(
          result.logs,
          meta: PaginationMeta(
            currentPage: result.currentPage,
            lastPage: result.lastPage,
            perPage: result.perPage,
            total: result.total,
            nextPageUrl: result.nextPageUrl,
            hasNextPageLink: result.hasNextPageLink,
          ),
        ),
        currentPageKey: pageKey,
        defaultPageSize: _pageSize,
        idSelector: (log) => log.id,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load activity logs on page $pageKey: $error',
          error: error, stackTrace: stackTrace);
      if (isClosed) return;
      pagingController.error = error;
    }
  }

  void clearSearch() {
    searchInputController.clear();
    searchQuery.value = '';
  }

  void clearDateRange() {
    startDate.value = null;
    endDate.value = null;
    pagingController.refresh();
  }

  void clearStaff() {
    selectedStaff.value = null;
    pagingController.refresh();
  }

  void clearRole() {
    selectedRole.value = 'all';
    pagingController.refresh();
  }

  void clearAction() {
    selectedAction.value = null;
    pagingController.refresh();
  }

  void resetAllFilters() {
    clearSearch();
    selectedStaff.value = null;
    selectedRole.value = 'all';
    selectedAction.value = null;
    startDate.value = null;
    endDate.value = null;
    pagingController.refresh();
  }

  @override
  void onClose() {
    pagingController.dispose();
    searchInputController.dispose();
    super.onClose();
  }
}
