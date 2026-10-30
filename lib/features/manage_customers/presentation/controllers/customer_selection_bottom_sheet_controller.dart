import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source.dart';
import 'package:pos/features/manage_customers/data/datasources/customer_data_source_factory.dart';
import 'package:pos/features/manage_customers/data/repositories/customer_repository_impl.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/domain/repositories/customer_repository.dart';
import 'package:pos/features/manage_customers/domain/usecases/get_customers_use_case.dart';

class CustomerSelectionBottomSheetController extends GetxController {
  final GetCustomersUseCase _getCustomersUseCase;

  CustomerSelectionBottomSheetController({GetCustomersUseCase? getCustomersUseCase})
      : _getCustomersUseCase = getCustomersUseCase ?? _resolveUseCase();

  static GetCustomersUseCase _resolveUseCase() {
    if (Get.isRegistered<GetCustomersUseCase>()) {
      return Get.find<GetCustomersUseCase>();
    }
    final customerRepo = Get.isRegistered<CustomerRepository>()
        ? Get.find<CustomerRepository>()
        : CustomerRepositoryImpl(
            Get.isRegistered<CustomerDataSource>()
                ? Get.find<CustomerDataSource>()
                : CustomerDataSourceFactory.create(
                    Get.find<AppConfigController>().currentBackend.value,
                  ),
          );
    final useCase = GetCustomersUseCase(customerRepo);
    Get.lazyPut<GetCustomersUseCase>(() => useCase, fenix: true);
    return useCase;
  }

  final PagingController<int, Customer> pagingController =
      PagingController(
        firstPageKey: 1,
        invisibleItemsThreshold: 1,
      );

  static const int pageSize = 15;

  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    pagingController.addPageRequestListener((pageKey) {
      loadCustomersPage(pageKey);
    });

    _searchWorker = debounce(
      searchQuery,
      (_) => pagingController.refresh(),
      time: const Duration(milliseconds: 350),
    );
  }

  Future<void> loadCustomersPage(int pageKey) async {
    try {
      final query = searchQuery.value.trim();
      final fetchedCustomers = await _getCustomersUseCase.execute(
        search: query.isNotEmpty ? query : null,
        perPage: pageSize,
        page: pageKey,
      );

      if (isClosed) return;
      pagingController.appendPageResult(
        newItems: fetchedCustomers,
        currentPageKey: pageKey,
        defaultPageSize: pageSize,
        idSelector: (c) => c.id.toString(),
      );
    } catch (e) {
      if (isClosed) return;
      pagingController.error = e;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    pagingController.refresh();
  }

  void refreshList() {
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
