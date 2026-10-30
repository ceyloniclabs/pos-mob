import 'package:get/get.dart';
import 'package:pos/features/report/presentation/bindings/report_binding.dart';
import 'package:pos/features/home/presentation/bindings/home_binding.dart';
import 'package:pos/features/manage_sales/presentation/bindings/sale_binding.dart';
import 'package:pos/features/manage_sales/presentation/bindings/sale_create_binding.dart';
import 'package:pos/features/manage_sale_items/presentation/bindings/sale_item_list_binding.dart';
import 'package:pos/features/manage_sale_categories/presentation/bindings/sale_category_list_binding.dart';
import 'package:pos/features/manage_sale_sub_categories/presentation/bindings/sale_sub_category_list_binding.dart';
import 'package:pos/features/manage_sale_brands/presentation/bindings/sale_brand_list_binding.dart';
import 'package:pos/features/setting/presentation/bindings/setting_binding.dart';
import 'package:pos/features/main/presentation/controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(
      () => MainController(),
    );

    // Initialize core page bindings
    HomeBinding().dependencies();
    SaleBinding().dependencies();
    SaleCreateBinding().dependencies();
    ReportBinding().dependencies();
    SettingBinding().dependencies();

    // Catalog bindings
    SaleItemListBinding().dependencies();
    SaleCategoryListBinding().dependencies();
    SaleSubCategoryListBinding().dependencies();
    SaleBrandListBinding().dependencies();
  }
}
