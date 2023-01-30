import 'package:get/get.dart';

import 'chat_history_logic.dart';

class ChatHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatHistoryLogic());
  }
}
