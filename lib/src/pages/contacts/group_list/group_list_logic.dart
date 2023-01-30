import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/pages/conversation/conversation_logic.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';

import '../../../res/strings.dart';
import '../../../res/styles.dart';
import '../../../widgets/bottom_sheet_view.dart';

class GroupListLogic extends GetxController {
  var index = 0.obs;
  var iCreatedList = <GroupInfo>[].obs;
  var iJoinedList = <GroupInfo>[].obs;
  var list = <GroupInfo>[];
  var conversationLogic = Get.find<ConversationLogic>();

  void getJoinedGroupList() async {
    list = await OpenIM.iMManager.groupManager.getJoinedGroupList();
    list.forEach((e) {
      if (e.ownerUserID == OpenIM.iMManager.uid) {
        iCreatedList.add(e);
      } else {
        iJoinedList.add(e);
      }
    });
  }

  void toGroupChat(GroupInfo info) {
    conversationLogic.startChat(
      groupID: info.groupID,
      nickname: info.groupName,
      faceURL: info.faceURL,
      sessionType: info.sessionType,
    );
  }

  void createGroup() {
    // AppNavigator.startSelectContacts(
    //   action: SelAction.CRATE_GROUP,
    //   defaultCheckedUidList: [OpenIM.iMManager.uid],
    // );
    Get.bottomSheet(
      BottomSheetView(
        itemBgColor: PageStyle.c_FFFFFF,
        items: [
          SheetItem(
            label: StrRes.generalGroup,
            onTap: () => AppNavigator.createGroup(),
          ),
          SheetItem(
            label: StrRes.workGroup,
            onTap: () => AppNavigator.createGroup(groupType: GroupType.work),
          ),
        ],
      ),
    );
  }

  void searchGroup() {
    AppNavigator.startSearchGroup(list: list);
    // Get.toNamed(AppRoutes.SEARCH_GROUP, arguments: list);
  }

  void switchTab(i) {
    index.value = i;
  }

  @override
  void onReady() {
    getJoinedGroupList();
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
