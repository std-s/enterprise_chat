import 'package:get/get.dart';

import 'preview_message_logic.dart';

class PreviewMessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PreviewMessageLogic());
  }
}
