import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/routes/app_pages.dart';

class ShortcutController extends GetxController {
  final shortcuts = [
    {'label': 'Quick Sale', 'icon': Iconsax.shop, 'route': Routes.SALE_ADD},
    {'label': 'Orders', 'icon': Iconsax.receipt_item, 'route': Routes.SALES},
    {'label': 'Products', 'icon': Iconsax.box, 'route': Routes.SALE_ITEM_LIST},
    {'label': 'Customers', 'icon': Iconsax.people, 'route': Routes.CUSTOMER_LIST},
    {'label': 'Reports', 'icon': Iconsax.document, 'route': Routes.REPORT},
    {'label': 'Staff', 'icon': Iconsax.user_octagon, 'route': Routes.STAFF},
    {'label': 'Promo Codes', 'icon': Iconsax.discount_shape, 'route': Routes.PROMO_CODE_LIST},
    {'label': 'Settings', 'icon': Iconsax.setting, 'route': Routes.SETTING},
  ];
}
