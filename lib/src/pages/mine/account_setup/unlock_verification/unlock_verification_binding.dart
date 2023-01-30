import 'package:get/get.dart';

import 'unlock_verification_logic.dart';

class UnlockVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UnlockVerificationLogic());
  }
}
