import 'package:get/get.dart';

import 'login_pc_logic.dart';

class LoginPcBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginPcLogic());
  }
}
