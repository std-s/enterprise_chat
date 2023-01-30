import 'package:get/get.dart';

import 'message_read_logic.dart';

class GroupMessageReadListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupMessageReadListLogic());
  }
}
