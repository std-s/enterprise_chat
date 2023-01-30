import 'package:collection/collection.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart' as im;
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/models/group_member_info.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/custom_dialog.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

enum OpAction { DELETE, ADMIN_TRANSFER, GROUP_CALL, AT }

class GroupMemberListLogic extends GetxController {
  var refreshCtrl = RefreshController();
  var memberList = <GroupMembersInfo>[].obs;
  var currentCheckedList = <GroupMembersInfo>[].obs;
  var defaultCheckedUidList = <String>[];
  var action = OpAction.DELETE;
  late String gid;
  var maxCount = 9;
  var curCount = 0.obs;
  var pageSize = 40;
  im.GroupMembersInfo? myMemberInfo;

  @override
  void onInit() {
    gid = Get.arguments['gid'];
    // var allList = Get.arguments['list'];
    var checkedList = Get.arguments['defaultCheckedUidList'];
    var ac = Get.arguments['action'];
    if (null != ac) action = ac;
    // memberList.addAll(allList ?? []);
    defaultCheckedUidList.addAll(checkedList ?? []);
    // if (memberList.isNotEmpty) {
    //   IMUtil.convertToAZList(memberList);
    //   if (action == OpAction.AT) {
    //     maxCount = memberList.length;
    //     _insertAtAllTagItem();
    //   }
    // } else {
    //   _queryGroupMembers();
    // }

    super.onInit();
  }

  int getFilter() {
    int filter = 0;
    if (action == OpAction.DELETE) {
      if (myMemberInfo?.roleLevel == im.GroupRoleLevel.owner) {
        filter = 4;
      } else if (myMemberInfo?.roleLevel == im.GroupRoleLevel.admin) {
        filter = 1;
      }
    }
    print('===============filter:$filter');
    return filter;
  }

  void loadMember() async {
    var list = await im.OpenIM.iMManager.groupManager.getGroupMemberListMap(
      groupId: gid,
      offset: memberList.length,
      count: pageSize,
      filter: getFilter(),
    );
    var l = list.map((e) => GroupMembersInfo.fromJson(e)).toList();
    _excludeMembers(l);
    memberList.addAll(l);
    if (list.length < pageSize) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }
  }

  void _queryGroupMembers() async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      var members = await im.OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupId: gid,
        uidList: [im.OpenIM.iMManager.uid],
      );
      myMemberInfo = members.firstOrNull;

      var list = await im.OpenIM.iMManager.groupManager.getGroupMemberListMap(
        groupId: gid,
        offset: memberList.length,
        count: pageSize,
        filter: getFilter(),
      );
      var l = list.map((e) => GroupMembersInfo.fromJson(e)).toList();
      _excludeMembers(l);
      memberList.assignAll(l);
      // IMUtil.convertToAZList(memberList);
      if (action == OpAction.AT) {
        // maxCount = memberList.length;
        _insertAtAllTagItem();
      }
      if (list.length < pageSize) {
        refreshCtrl.loadNoData();
      } else {
        refreshCtrl.loadComplete();
      }
    });
  }

  void _excludeMembers(List<GroupMembersInfo> list) {
    if (list.isNotEmpty) {
      if (action == OpAction.AT || action == OpAction.ADMIN_TRANSFER) {
        // 不能at 自己，不能再把群权限转移给自己
        list.removeWhere(_isMyself);
      } /*else if (action == OpAction.DELETE) {
        // 只有删除比自己等级低的
      }*/
    }
  }

  bool _isMyself(GroupMembersInfo info) =>
      info.userID == im.OpenIM.iMManager.uid;

  void selectedMember(index) async {
    var info = memberList.elementAt(index);
    if (info.nickname == StrRes.everyone && action == OpAction.AT) {
      // @所有人
      Get.back(result: <GroupMembersInfo>[info]);
      return;
    }
    if (action == OpAction.DELETE ||
        action == OpAction.GROUP_CALL ||
        action == OpAction.AT) {
      if (currentCheckedList.contains(info)) {
        currentCheckedList.remove(info);
      } else {
        if (action == OpAction.GROUP_CALL && curCount.value == maxCount) {
          return;
        }
        currentCheckedList.add(info);
      }
      curCount.value = currentCheckedList.length;
    } else if (action == OpAction.ADMIN_TRANSFER) {
      var confirm = await Get.dialog(CustomDialog(
        title: sprintf(StrRes.confirmTransferGroupToUser, [info.nickname]),
      ));
      if (confirm == true) {
        Get.back(result: info);
      }
    }
  }

  void confirmSelected() async {
    if (curCount.value == 0) return;
    if (action == OpAction.DELETE) {
      var confirm = await Get.dialog(CustomDialog(
        title: StrRes.confirmDelMember,
        rightText: StrRes.sure,
      ));
      if (confirm == true) {
        Get.back(result: currentCheckedList.value);
      }
    } else if (action == OpAction.GROUP_CALL) {
      Get.back(result: currentCheckedList.map((e) => e.userID!).toList());
    } else if (action == OpAction.AT) {
      Get.back(result: currentCheckedList);
    }
  }

  void removeContacts(GroupMembersInfo info) {
    currentCheckedList.remove(info);
    curCount.value = currentCheckedList.length;
  }

  bool isMultiModel() {
    return action == OpAction.DELETE ||
        action == OpAction.GROUP_CALL ||
        action == OpAction.AT;
  }

  bool isMultiModelConfirm() {
    return action == OpAction.GROUP_CALL || action == OpAction.AT;
  }

  void search() async {
    var info = await AppNavigator.startSearchMember(
      groupID: gid,
      info: myMemberInfo,
      action: action,
    );
    if (null != info) {
      if (!currentCheckedList.contains(info)) {
        currentCheckedList.add(info);
      }
      curCount.value = currentCheckedList.length;
      if (action == OpAction.ADMIN_TRANSFER) {
        var confirm = await Get.dialog(CustomDialog(
          title: sprintf(StrRes.confirmTransferGroupToUser, [info.nickName]),
        ));
        if (confirm == true) {
          Get.back(result: info);
        }
      }
    }
  }

  @override
  void onReady() {
    _queryGroupMembers();
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void _insertAtAllTagItem() async {
    var tag = await im.OpenIM.iMManager.conversationManager.getAtAllTag();
    memberList.insert(
        0,
        GroupMembersInfo.fromJson({
          'userID': tag,
          'nickname': StrRes.everyone,
          'tagIndex': '↑',
        }));
  }

  bool isEveryoneTag(String nickname) => nickname == StrRes.everyone;
}
