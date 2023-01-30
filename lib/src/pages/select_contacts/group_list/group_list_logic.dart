import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';

import '../select_contacts_logic.dart';

class SelectByGroupListLogic extends GetxController {
  final groupList = <GroupInfo>[].obs;
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  @override
  void onReady() {
    queryGroupList();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void queryGroupList() async {
    var list = await OpenIM.iMManager.groupManager.getJoinedGroupList();
    groupList.addAll(list);
  }

  void selectedGroup(GroupInfo info) {
    selectContactsLogic.selectedGroup(info);
  }
}
