import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/features/activity_logs/domain/entities/activity_filter_params.dart';
import 'package:pos/features/activity_logs/domain/entities/activity_log_entity.dart';
import 'package:pos/features/activity_logs/domain/usecases/get_activity_logs_use_case.dart';

import '../../domain/entities/operational_metrics.dart';
import '../../domain/entities/staff.dart';
import '../../domain/usecases/create_staff_use_case.dart';
import '../../domain/usecases/delete_staff_use_case.dart';
import '../../domain/usecases/get_operational_metrics_use_case.dart';
import '../../domain/usecases/get_staff_by_id_use_case.dart';
import '../../domain/usecases/get_staff_use_case.dart';
import '../../domain/usecases/update_staff_status_use_case.dart';
import '../../domain/usecases/update_staff_use_case.dart';

class StaffController extends GetxController {
  final GetStaffUseCase getStaffUseCase;
  final GetStaffByIdUseCase getStaffByIdUseCase;
  final CreateStaffUseCase createStaffUseCase;
  final UpdateStaffUseCase updateStaffUseCase;
  final DeleteStaffUseCase deleteStaffUseCase;
  final UpdateStaffStatusUseCase updateStaffStatusUseCase;
  final GetOperationalMetricsUseCase? getOperationalMetricsUseCase;
  final GetActivityLogsUseCase? getActivityLogsUseCase;

  StaffController({
    required this.getStaffUseCase,
    required this.getStaffByIdUseCase,
    required this.createStaffUseCase,
    required this.updateStaffUseCase,
    required this.deleteStaffUseCase,
    required this.updateStaffStatusUseCase,
    this.getOperationalMetricsUseCase,
    this.getActivityLogsUseCase,
  });

  // 1. Reactive observable states & Pagination
  final PagingController<int, Staff> pagingController =
      PagingController(firstPageKey: 1);
  static const int _pageSize = 10;
  Worker? _searchWorker;
  Worker? _roleWorker;
  Worker? _statusWorker;

  final RxList<Staff> staffList = <Staff>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<StaffRole> selectedRole = StaffRole.all.obs;
  final Rx<StaffStatus> selectedStatus = StaffStatus.all.obs;
  final RxBool isFiltersVisible = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isActiveEdit = true.obs;
  final Rxn<Staff> detailStaff = Rxn<Staff>();
  final RxBool isLoadingDetail = false.obs;

  // Operational Metrics Observables
  final Rxn<OperationalMetrics> operationalMetrics = Rxn<OperationalMetrics>();
  final RxBool isLoadingMetrics = false.obs;
  final RxInt selectedDaysWindow = 7.obs;

  // Recent Staff Activity Observables
  final RxList<ActivityLogEntity> recentStaffActivities = <ActivityLogEntity>[].obs;
  final RxBool isLoadingActivities = false.obs;

  // 2. Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController joinDateController = TextEditingController();

  final GlobalKey<FormState> staffFormKey = GlobalKey<FormState>();

  List<Staff> get filteredStaffList {
    List<Staff> list = staffList
        .where((staff) =>
            staff.role.toLowerCase() != 'developer_admin' &&
            !staff.role.toLowerCase().contains('developer_admin'))
        .toList();
    // Sort: Admin first, then alphabetical by name
    list.sort((a, b) {
      final aIsAdmin = a.role.toLowerCase() == 'admin';
      final bIsAdmin = b.role.toLowerCase() == 'admin';
      if (aIsAdmin && !bIsAdmin) return -1;
      if (bIsAdmin && !aIsAdmin) return 1;
      return a.name.compareTo(b.name);
    });
    return list;
  }

  // 3. Lifecycle Hooks
  @override
  void onInit() {
    super.onInit();

    pagingController.addPageRequestListener((pageKey) {
      loadStaffPage(pageKey);
    });

    _searchWorker = debounce(
      searchQuery,
      (_) => pagingController.refresh(),
      time: const Duration(milliseconds: 400),
    );

    _roleWorker = ever(selectedRole, (_) => pagingController.refresh());
    _statusWorker = ever(selectedStatus, (_) => pagingController.refresh());
  }

  // 4. Methods

  /// Initializes the staff form.
  void initForm([Staff? staff]) {
    if (staff != null) {
      nameController.text = staff.name;
      emailController.text = staff.email;
      phoneNumberController.text = staff.phoneNumber ?? '';
      joinDateController.text = staff.joinDate ?? '';
      isActiveEdit.value = staff.isActive;
    } else {
      nameController.clear();
      emailController.clear();
      phoneNumberController.clear();
      joinDateController.clear();
      isActiveEdit.value = true;
    }
    passwordController.clear();
    isPasswordVisible.value = false;
  }

  /// Triggers a refresh of the paginated staff list.
  Future<void> fetchStaff() async {
    pagingController.refresh();
  }

  /// Loads a paginated page of staff members from the backend.
  Future<void> loadStaffPage(int pageKey) async {
    try {
      if (pageKey == 1) {
        isLoading.value = true;
      }
      final data = await getStaffUseCase.execute(
        role: selectedRole.value.value,
        status: selectedStatus.value.value,
        search: searchQuery.value.trim().isNotEmpty
            ? searchQuery.value.trim()
            : null,
        page: pageKey,
        perPage: _pageSize,
      );

      // Filter out developer_admin so it is never displayed or operated on in the mobile UI
      final sanitizedData = data
          .where((s) =>
              s.role.toLowerCase() != 'developer_admin' &&
              !s.role.toLowerCase().contains('developer_admin'))
          .toList();

      if (isClosed) return;

      pagingController.appendPageResult(
        newItems: sanitizedData,
        currentPageKey: pageKey,
        defaultPageSize: _pageSize,
        idSelector: (s) => s.id,
      );

      if (pageKey == 1) {
        staffList.assignAll(sanitizedData);
      } else {
        for (final s in sanitizedData) {
          if (!staffList.any((e) => e.id == s.id)) {
            staffList.add(s);
          }
        }
      }
    } catch (e) {
      if (isClosed) return;
      pagingController.error = e;
      ScaffoldMessageUtils.showError('Failed to load staff: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads individual staff details by ID when deep-linked or scanned via QR.
  Future<Staff?> loadStaffById(int id) async {
    try {
      isLoadingDetail.value = true;
      final staff = await getStaffByIdUseCase.execute(id);
      detailStaff.value = staff;
      loadStaffProfileData(staff);
      return staff;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to load staff details: ${e.toString()}');
      return null;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Loads operational metrics and recent activities in parallel.
  Future<void> loadStaffProfileData(Staff staff) async {
    detailStaff.value = staff;
    await Future.wait([
      fetchOperationalMetrics(),
      fetchStaffRecentActivities(staff.id, role: staff.role),
    ]);
  }

  /// Fetches operational metrics from backend for specified days window (7, 30, 90).
  Future<void> fetchOperationalMetrics({int? days}) async {
    final targetDays = days ?? selectedDaysWindow.value;
    selectedDaysWindow.value = targetDays;
    try {
      isLoadingMetrics.value = true;
      if (getOperationalMetricsUseCase != null) {
        final metrics = await getOperationalMetricsUseCase!.execute(days: targetDays);
        operationalMetrics.value = metrics;
      }
    } catch (e) {
      log('Error fetching operational metrics: $e');
    } finally {
      isLoadingMetrics.value = false;
    }
  }

  /// Switches days window and re-fetches operational metrics.
  Future<void> changeDaysWindow(int days) async {
    if (selectedDaysWindow.value == days && operationalMetrics.value != null && !isLoadingMetrics.value) {
      return;
    }
    await fetchOperationalMetrics(days: days);
  }

  /// Fetches recent 4 activities for this specific staff member.
  Future<void> fetchStaffRecentActivities(int staffId, {String? role}) async {
    try {
      isLoadingActivities.value = true;
      if (getActivityLogsUseCase != null) {
        final params = ActivityFilterParams(
          page: 1,
          perPage: 4,
          userId: staffId,
          role: (role != null && role.isNotEmpty && role.toLowerCase() != 'all')
              ? role.toLowerCase()
              : null,
        );
        final result = await getActivityLogsUseCase!.execute(params);
        recentStaffActivities.assignAll(result.logs.take(4).toList());
      }
    } catch (e) {
      log('Error fetching recent staff activities: $e');
    } finally {
      isLoadingActivities.value = false;
    }
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedRole.value = StaffRole.all;
    selectedStatus.value = StaffStatus.all;
    pagingController.refresh();
  }

  /// Adds a new staff member.
  Future<bool> addStaff(String name, String email, String password, {String? phoneNumber, String? joinDate}) async {
    try {
      isSaving.value = true;
      await createStaffUseCase.execute(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        joinDate: joinDate,
      );
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess('Staff added successfully');
      return true;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to add staff: ${e.toString()}');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Deletes a staff member given the [staff] object.
  Future<void> deleteStaff(Staff staff) async {
    try {
      await deleteStaffUseCase.execute(staff.id);
      staffList.removeWhere((element) => element.id == staff.id);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess('Staff deleted successfully');
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to delete staff: ${e.toString()}');
    }
  }

  /// Toggles the active status of the specified [staff].
  Future<void> toggleStaffStatus(Staff staff) async {
    try {
      final newStatus = !staff.isActive;
      await updateStaffStatusUseCase.execute(staff.id, newStatus);
      final index = staffList.indexWhere((element) => element.id == staff.id);
      if (index != -1) {
        staffList[index] = staff.copyWith(isActive: newStatus);
      }
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess('Status updated successfully');
    } catch (e) {
      ScaffoldMessageUtils.showError(
          'Failed to update status: ${e.toString()}');
    }
  }

  /// Updates an existing staff member's details.
  Future<void> updateStaff(
    Staff staff,
    String name,
    String email,
    String password, {
    String? phoneNumber,
    String? joinDate,
  }) async {
    try {
      isSaving.value = true;
      var updatedStaff = await updateStaffUseCase.execute(
        existingStaff: staff,
        name: name,
        email: email,
        password: password.isNotEmpty ? password : null,
        phoneNumber: phoneNumber,
        joinDate: joinDate,
      );

      if (staff.isActive != isActiveEdit.value) {
        await updateStaffStatusUseCase.execute(staff.id, isActiveEdit.value);
        updatedStaff = updatedStaff.copyWith(isActive: isActiveEdit.value);
      }

      final index = staffList.indexWhere((element) => element.id == staff.id);
      if (index != -1) {
        staffList[index] = updatedStaff;
      }
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess('Staff updated successfully');
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to update staff: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  // 5. onClose Hook
  @override
  void onClose() {
    _searchWorker?.dispose();
    _roleWorker?.dispose();
    _statusWorker?.dispose();
    pagingController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    joinDateController.dispose();
    super.onClose();
  }
}
