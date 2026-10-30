import 'package:get/get.dart';

import 'package:pos/features/shortcut/presentation/controllers/shortcut_controller.dart';

class ShortcutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShortcutController>(
      () => ShortcutController(),
    );
  }
}
