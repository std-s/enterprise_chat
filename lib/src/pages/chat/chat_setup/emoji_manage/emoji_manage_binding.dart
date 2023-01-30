import 'package:get/get.dart';

import 'emoji_manage_logic.dart';

class EmojiManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmojiManageLogic());
  }
}
