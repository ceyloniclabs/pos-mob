import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/enums.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/app_logger.dart';
import 'package:pos/features/manage_customers/domain/usecases/get_customers_use_case.dart';
import 'package:pos/features/manage_customers/domain/usecases/delete_customer_use_case.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/core/widgets/confirm_delete_dialog.dart';

class CustomerListController extends GetxController {
  // 1. Dependencies and final fields
  final GetCustomersUseCase _getCustomersUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;
  static const int _pageSize = 10;

  CustomerListController({
    required this._getCustomersUseCase,
    required this._deleteCustomerUseCase,
  });

  // 2. Observable states and pagination controllers
  /// The search query query string to filter customers.
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final Rx<CustomerFilterType> selectedType = CustomerFilterType.all.obs;
  final Rx<MembershipFilterLevel> selectedMembership =
      MembershipFilterLevel.all.obs;
  final RxBool isFiltersVisible = false.obs;
  Worker? _searchWorker;

  /// Paging controller handling paginated customers.
  final PagingController<int, Customer> pagingController =
      PagingController(
        firstPageKey: 1,
        invisibleItemsThreshold: 1,
      );

  @override
  void onInit() {
    super.onInit();

    pagingController.addPageRequestListener((pageKey) {
      _fetchCustomers(pageKey);
    });

    _searchWorker = debounce(searchQuery, (_) {
      pagingController.refresh();
    }, time: const Duration(milliseconds: 350));
  }

  /// Fetches a paginated list of customers from the backend.
  ///
  /// Appends the retrieved results to [pagingController]. Shows a toast error on failure.
  Future<void> _fetchCustomers(int pageKey) async {
    try {
      final trimmedSearch = searchQuery.value.trim();
      AppLogger.debug(
        '👥 [CustomerListController] Fetching customers: page=$pageKey, search="$trimmedSearch", type=${selectedType.value.value}, membership=${selectedMembership.value.value}',
      );

      final customers = await _getCustomersUseCase.execute(
        page: pageKey,
        perPage: _pageSize,
        search: trimmedSearch.isEmpty ? null : trimmedSearch,
        customerType: selectedType.value.value,
        membershipLevel: selectedMembership.value.value,
      );

      AppLogger.debug(
        '👥 [CustomerListController] Page $pageKey loaded ${customers.length} customers (hasMore: ${customers is PaginatedList ? (customers as PaginatedList).hasMore : false})',
      );

      if (isClosed) return;
      pagingController.appendPageResult(
        newItems: customers,
        currentPageKey: pageKey,
        defaultPageSize: _pageSize,
        idSelector: (c) => c.id,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load customers on page $pageKey: $error',
          error: error, stackTrace: stackTrace);
      if (isClosed) return;
      pagingController.error = error;
      ScaffoldMessageUtils.showError(
          'Failed to load customers: ${error.toString()}');
    }
  }

  /// Clears the active search query and resets the text field.
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    pagingController.refresh();
  }

  /// Displays a confirmation dialog before deleting the specified customer [id].
  ///
  /// Calls [_deleteCustomer] internally when confirmed.
  Future<void> confirmAndDelete(int id) async {
    showConfirmDeleteDialog(
      title: 'Delete Customer',
      message:
          'Are you sure you want to delete this customer? This action cannot be undone.',
      onConfirm: () async {
        await _deleteCustomer(id);
      },
    );
  }

  Future<void> _deleteCustomer(int id) async {
    try {
      final result = await _deleteCustomerUseCase.execute(id);
      pagingController.refresh();
      ScaffoldMessageUtils.showSuccess(result);
    } catch (error) {
      ScaffoldMessageUtils.showError(error.toString());
    }
  }

  /// Manually triggers a refresh of the paginated customer list.
  void refreshList() {
    pagingController.refresh();
  }

  void resetFilters() {
    selectedType.value = CustomerFilterType.all;
    selectedMembership.value = MembershipFilterLevel.all;
    pagingController.refresh();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.dispose();
    pagingController.dispose();
    super.onClose();
  }
}
