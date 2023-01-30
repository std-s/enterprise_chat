import 'package:get/get.dart';

import 'file_logic.dart';

class SearchFileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchFileLogic());
  }
}
