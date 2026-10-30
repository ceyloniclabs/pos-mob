import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:pos/core/controllers/app_config_controller.dart';
import 'package:pos/core/controllers/persistent_data_controller.dart';
import 'package:pos/core/enums.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/domain/usecases/get_customer_by_id_use_case.dart';
import 'package:pos/features/manage_sales/data/datasources/sale_data_source_factory.dart';
import 'package:pos/features/manage_sales/data/repositories/sale_repository_impl.dart';
import 'package:pos/features/manage_sales/domain/entities/sale.dart';
import 'package:pos/features/manage_sales/domain/repositories/sale_repository.dart';
import 'package:pos/features/manage_sales/domain/usecases/get_sales_use_case.dart';

class CustomerDetailController extends GetxController
    with GetTickerProviderStateMixin {
  final GetCustomerByIdUseCase? getCustomerByIdUseCase;
  final GetSalesUseCase? getSalesUseCase;

  CustomerDetailController({
    this.getCustomerByIdUseCase,
    this.getSalesUseCase,
  });

  static const int _salesPageSize = 10;

  late final TabController tabController;

  final Rxn<Customer> customerRx = Rxn<Customer>();
  Customer get customer => customerRx.value!;
  bool get hasCustomer => customerRx.value != null;
  final RxBool isLoading = false.obs;

  final PagingController<int, Sale> salesPagingController =
      PagingController(firstPageKey: 1);

  GetSalesUseCase get _salesUseCase =>
      getSalesUseCase ??
      (Get.isRegistered<GetSalesUseCase>()
          ? Get.find<GetSalesUseCase>()
          : GetSalesUseCase(
              Get.isRegistered<SaleRepository>()
                  ? Get.find<SaleRepository>()
                  : SaleRepositoryImpl(
                      SaleDataSourceFactory.create(
                        Get.isRegistered<AppConfigController>()
                            ? Get.find<AppConfigController>()
                                .currentBackend
                                .value
                            : BackendProviderType.laravel,
                      ),
                    ),
            ));

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Customer) {
      customerRx.value = args;
    } else if (args is int) {
      loadCustomerById(args);
    }
    tabController = TabController(length: 2, vsync: this);

    salesPagingController.addPageRequestListener((pageKey) {
      fetchSales(pageKey);
    });
  }

  Future<void> loadCustomerById(int id) async {
    try {
      isLoading.value = true;
      final useCase = getCustomerByIdUseCase ??
          (Get.isRegistered<GetCustomerByIdUseCase>()
              ? Get.find<GetCustomerByIdUseCase>()
              : null);
      if (useCase == null) {
        throw Exception('GetCustomerByIdUseCase not registered.');
      }
      final fetched = await useCase.execute(id);
      customerRx.value = fetched;
    } catch (e) {
      ScaffoldMessageUtils.showError('Failed to load customer: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSales(int pageKey) async {
    final customerId = customerRx.value?.id;
    if (customerId == null) {
      salesPagingController.appendLastPage([]);
      return;
    }

    try {
      final sales = await _salesUseCase.execute(
        page: pageKey,
        filters: {
          'customer_id': customerId,
          'per_page': _salesPageSize,
          'limit': _salesPageSize,
        },
      );

      salesPagingController.appendPageResult(
        newItems: sales,
        currentPageKey: pageKey,
        defaultPageSize: _salesPageSize,
        idSelector: (s) => s.id.toString(),
      );
    } catch (e) {
      salesPagingController.error = e;
    }
  }

  void refreshCustomer() {
    final currentId = customerRx.value?.id;
    if (currentId != null) {
      loadCustomerById(currentId);
    }
    refreshSales();
  }

  void refreshSales() {
    salesPagingController.refresh();
  }

  String getCountryName(String id) {
    try {
      final parsedId = int.tryParse(id) ?? 0;
      final country = PersistentDataController.to.findCountryById(parsedId);
      return country?.name ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    salesPagingController.dispose();
    super.onClose();
  }
}
