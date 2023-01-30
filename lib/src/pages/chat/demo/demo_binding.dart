import 'package:get/get.dart';

import 'demo_logic.dart';

class ChatDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatDemoLogic());
  }
}
