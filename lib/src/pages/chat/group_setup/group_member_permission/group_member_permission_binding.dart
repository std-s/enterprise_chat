import 'package:get/get.dart';

import 'group_member_permission_logic.dart';

class GroupMemberPermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupMemberPermissionLogic());
  }
}
