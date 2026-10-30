import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/core/models/base_get_list_response_model.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/features/manage_customers/domain/repositories/customer_repository.dart';
import 'package:pos/features/manage_customers/domain/usecases/get_customers_use_case.dart';

class SelectCustomer extends StatefulWidget {
  const SelectCustomer({super.key});

  @override
  State<SelectCustomer> createState() => _SelectCustomerState();
}

class _SelectCustomerState extends State<SelectCustomer> {
  final PagingController<int, Customer> _pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 1);
  static const int _pageSize = 15;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _loadPage(pageKey);
    });
  }

  Future<void> _loadPage(int pageKey) async {
    try {
      final GetCustomersUseCase getCustomersUseCase =
          Get.isRegistered<GetCustomersUseCase>()
              ? Get.find<GetCustomersUseCase>()
              : GetCustomersUseCase(Get.find<CustomerRepository>());

      final customers = await getCustomersUseCase.execute(
        page: pageKey,
        perPage: _pageSize,
        search: _searchQuery.trim().isNotEmpty ? _searchQuery.trim() : null,
      );

      if (!mounted) return;
      _pagingController.appendPageResult(
        newItems: customers,
        currentPageKey: pageKey,
        defaultPageSize: _pageSize,
        idSelector: (c) => c.id.toString(),
      );
    } catch (e) {
      if (!mounted) return;
      _pagingController.error = e;
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Select Customer',
        centerTitle: true,
        showbackArrow: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.scan_barcode, size: 25.w),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search customer name or phone...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          Expanded(
            child: PagedListView<int, Customer>(
              pagingController: _pagingController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              builderDelegate: PagedChildBuilderDelegate<Customer>(
                firstPageProgressIndicatorBuilder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
                newPageProgressIndicatorBuilder: (context) => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  ),
                ),
                noItemsFoundIndicatorBuilder: (context) => const Center(
                  child: Text('No customers found.'),
                ),
                itemBuilder: (context, customer, index) {
                  return ListTile(
                    leading: const Icon(Iconsax.user),
                    title: Text(customer.name),
                    subtitle: Text(customer.email.isNotEmpty
                        ? customer.email
                        : customer.phone),
                    trailing: TextButton(
                      onPressed: () {
                        Get.back(result: customer);
                      },
                      child: Text(
                        "Select",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
