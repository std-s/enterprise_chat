import 'package:get/get.dart';

import 'search_history_message_logic.dart';

class SearchHistoryMessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchHistoryMessageLogic());
  }
}
