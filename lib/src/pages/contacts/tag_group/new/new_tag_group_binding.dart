import 'package:get/get.dart';

import 'new_tag_group_logic.dart';

class NewTagGroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NewTagGroupLogic());
  }
}
