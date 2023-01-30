import 'package:get/get.dart';

import 'all_user_logic.dart';

class AllUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllUsersLogic());
  }
}
