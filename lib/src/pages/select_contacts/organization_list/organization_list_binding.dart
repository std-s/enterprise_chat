import 'package:get/get.dart';

import 'organization_list_logic.dart';

class SelectByOrganizationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectByOrganizationListLogic());
  }
}
