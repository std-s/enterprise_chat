import 'package:get/get.dart';

import 'set_info_logic.dart';

class SetFriendInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SetFriendInfoLogic());
  }
}
