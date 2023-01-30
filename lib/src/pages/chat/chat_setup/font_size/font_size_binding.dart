import 'package:get/get.dart';

import 'font_size_logic.dart';

class FontSizeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FontSizeLogic());
  }
}
