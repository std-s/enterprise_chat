import 'package:get/get.dart';

import 'set_member_mute_logic.dart';

class SetMemberMuteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SetMemberMuteLogic());
  }
}
