import 'package:get/get.dart';

import 'friend_list_logic.dart';

class SelectByFriendListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectByFriendListLogic());
  }
}
