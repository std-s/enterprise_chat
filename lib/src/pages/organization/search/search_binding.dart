import 'package:get/get.dart';

import 'search_logic.dart';

class SearchOrganizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchOrganizationLogic());
  }
}
