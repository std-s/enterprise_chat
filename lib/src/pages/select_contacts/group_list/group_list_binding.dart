import 'package:get/get.dart';

import 'group_list_logic.dart';

class SelectByGroupListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectByGroupListLogic());
  }
}
