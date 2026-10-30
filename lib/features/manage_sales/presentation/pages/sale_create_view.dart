import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';
import 'package:pos/features/manage_sales/presentation/widgets/sale_pos_bottom_dock.dart';
import 'package:pos/features/manage_sales/presentation/widgets/sale_pos_catalog.dart';
import 'package:pos/features/manage_sales/presentation/widgets/sale_pos_customer_header.dart';

class SaleCreateView extends GetView<SaleCreateController> {
  const SaleCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomeAppBar(
        title: Obx(() => Text(
              controller.isEditMode ? 'Edit Sale' : 'Quick Sale',
              style: Theme.of(context).textTheme.titleSmall,
            )),
        centerTitle: true,
        showbackArrow: Navigator.canPop(context),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.scan_barcode, size: 22),
            tooltip: 'Scan Items QR',
            onPressed: controller.openContinuousQrScanner,
          ),
          const SalePosCustomerHeader(),
        ],
      ),
      body: const Column(
        children: [
          // Instant Product Search, Category Pills & Quick-Add Grid
          Expanded(
            child: SalePosCatalog(),
          ),
        ],
      ),
      // Persistent Live Floating Dock (Cart Summary & Fast Checkout)
      bottomNavigationBar: const SalePosBottomDock(),
    );
  }
}
