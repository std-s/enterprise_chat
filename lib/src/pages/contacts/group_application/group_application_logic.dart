import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';

import '../../../utils/data_persistence.dart';
import '../../../utils/im_util.dart';
import '../../home/home_logic.dart';

class GroupApplicationLogic extends GetxController {
  var list = <GroupApplicationInfo>[].obs;
  var groupList = <String, GroupInfo>{}.obs;
  var imLogic = Get.find<IMController>();
  var homeLogic = Get.find<HomeLogic>();
  var memberList = <GroupMembersInfo>[].obs;
  var userInfoList = <UserInfo>[].obs;

  bool _isInvite(GroupApplicationInfo info) {
    if (info.joinSource == 2) {
      return info.inviterUserID != null && info.inviterUserID!.isNotEmpty;
    }
    return false;
  }

  void getApplicationList() async {
    var list =
        await OpenIM.iMManager.groupManager.getRecvGroupApplicationList();
    list.sort((a, b) {
      if (a.reqTime! > b.reqTime!) {
        return -1;
      } else if (a.reqTime! < b.reqTime!) {
        return 1;
      }
      return 0;
    });
    var map = <String, List<String>>{};
    var inviterList = <String>[];
    var haveReadList = DataPersistence.getHaveReadUnHandleGroupApplication();
    haveReadList ??= <String>[];
    list.forEach((a) {
      var id = IMUtil.buildGroupApplicationID(a);
      if (!haveReadList!.contains(id)) {
        haveReadList.add(id);
      }
      if (_isInvite(a)) {
        if (!map.containsKey(a.groupID)) {
          map[a.groupID!] = [a.inviterUserID!];
        } else {
          if (!map[a.groupID!]!.contains(a.inviterUserID!)) {
            map[a.groupID!]!.add(a.inviterUserID!);
          }
        }
        if (!inviterList.contains(a.inviterUserID!)) {
          inviterList.add(a.inviterUserID!);
        }
      }
    });

    DataPersistence.putHaveReadUnHandleGroupApplication(haveReadList);

    await Future.forEach<MapEntry>(map.entries, (element) {
      OpenIM.iMManager.groupManager
          .getGroupMembersInfo(groupId: element.key, uidList: element.value)
          .then((list) => memberList.assignAll(list));
    });

    if (inviterList.isNotEmpty) {
      await OpenIM.iMManager.userManager
          .getUsersInfo(uidList: inviterList)
          .then((list) => userInfoList.assignAll(list));
    }

    // list.sort((a, b) {
    //   if (a.createTime! > b.createTime!) {
    //     return -1;
    //   } else if (a.createTime! < b.createTime!) {
    //     return 1;
    //   }
    //   return 0;
    // });
    this.list.assignAll(list);
  }

  void getJoinedGroup() {
    OpenIM.iMManager.groupManager.getJoinedGroupList().then((list) {
      var map = <String, GroupInfo>{};
      list.forEach((e) {
        map[e.groupID] = e;
      });
      groupList.addAll(map);
    });
  }

  String getGroupName(gid) {
    return groupList[gid]?.groupName ?? '';
  }

  void handle(GroupApplicationInfo info) async {
    var result = await AppNavigator.startHandleGroupApplication(
      groupList[info.groupID]!,
      info,
    );
    if (result is int) {
      info.handleResult = result;
      list.refresh();
    }
  }

  @override
  void onReady() {
    getApplicationList();
    getJoinedGroup();
    super.onReady();
  }

  @override
  void onInit() {
    // imLogic.onGroupApplicationProcessed = (gid, op, agreeOrReject, opReason) {
    //   getApplicationList();
    // };
    super.onInit();
  }

  GroupMembersInfo? getMemberInfo(String inviterUserID) =>
      memberList.firstWhereOrNull((e) => e.userID == inviterUserID);

  UserInfo? getUserInfo(String inviterUserID) =>
      userInfoList.firstWhereOrNull((e) => e.userID == inviterUserID);

  @override
  void onClose() {
    homeLogic.getUnhandledGroupApplicationCount();
    super.onClose();
  }
}
