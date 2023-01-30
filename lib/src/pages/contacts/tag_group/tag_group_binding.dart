import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/pages/contacts/tag_group/tag_group_logic.dart';

class TagGroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TagGroupLogic());
  }
}
