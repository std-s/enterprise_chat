import 'package:get/get.dart';

import 'search_logic.dart';

class SearchSelectContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchSelectContactsLogic());
  }
}
