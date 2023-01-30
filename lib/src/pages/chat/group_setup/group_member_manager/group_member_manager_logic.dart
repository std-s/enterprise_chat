import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/models/contacts_info.dart';
import 'package:openim_enterprise_chat/src/models/group_member_info.dart' as en;
import 'package:openim_enterprise_chat/src/pages/chat/group_setup/group_member_manager/member_list/member_list_logic.dart';
import 'package:openim_enterprise_chat/src/pages/select_contacts/select_contacts_logic.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../widgets/loading_view.dart';
import '../group_setup_logic.dart';

class GroupMemberManagerLogic extends GetxController {
  final refreshCtrl = RefreshController();
  var allList = <en.GroupMembersInfo>[].obs;

  // var _ownerList = <en.GroupMembersInfo>[];
  // var _memberList = <en.GroupMembersInfo>[];
  // var _adminList = <en.GroupMembersInfo>[];
  var _groupSetupLogic = Get.find<GroupSetupLogic>();
  late GroupInfo groupInfo;

  // var _uidList = <String>[];
  var onlineStatus = <String, String>{}.obs;
  var popCtrl = CustomPopupMenuController();
  var isAdmin = false.obs;
  var pageSize = 40;

  void loadMember() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberListMap(
      groupId: groupInfo.groupID,
      count: pageSize,
      offset: allList.length,
    );
    allList.addAll(list.map((e) => en.GroupMembersInfo.fromJson(e)));
    if (list.length < pageSize) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }
  }

  void getGroupMembers() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberListMap(
      groupId: groupInfo.groupID,
      count: pageSize,
      offset: allList.length,
    );
    allList.assignAll(list.map((e) => en.GroupMembersInfo.fromJson(e)));
    if (list.length < pageSize) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }

    // for (var e in list) {
    //   var member = en.GroupMembersInfo.fromJson(e);
    //   // 1普通成员, 2群组，3管理员
    //   if (member.roleLevel == 1) {
    //     _memberList.add(member);
    //   } else if (member.roleLevel == 2) {
    //     _ownerList.add(member..tagIndex = '↑');
    //   } else {
    //     _adminList.add(member..tagIndex = '↑');
    //   }
    //   _uidList.add(member.userID!);
    // }
    // memberList.addAll(IMUtil.convertToAZList(list).cast());
    // _sortList();
    // _queryOnlineStatus();
  }

  bool _isAdmin(en.GroupMembersInfo e) => e.userID == OpenIM.iMManager.uid;

  // void _sortList() {
  //   isAdmin.value = _adminList.firstWhereOrNull(_isAdmin) != null;
  //   IMUtil.convertToAZList(allList..assignAll(_memberList));
  //   allList.insertAll(0, _adminList);
  //   allList.insertAll(0, _ownerList);
  // }

  void viewUserInfo(en.GroupMembersInfo info) async {
    await AppNavigator.startFriendInfo(
      userInfo: UserInfo(
        userID: info.userID!,
        nickname: info.nickname,
        faceURL: info.faceURL,
      ),
      groupID: groupInfo.groupID,
      showMuteFunction: havePermissionMute,
    );
  }

  void addAdminRole(GroupMembersInfo info) {
    var updateElement = allList.firstWhere((e) => e.userID == info.userID);
    updateElement.roleLevel = info.roleLevel;
    allList.refresh();
    // _memberList.removeWhere((e) => e.userID == info.userID);
    // _adminList.add(en.GroupMembersInfo.fromJson(info.toJson())..tagIndex = '↑');
    // _sortList();
  }

  void removeAdminRole(GroupMembersInfo info) {
    var updateElement = allList.firstWhere((e) => e.userID == info.userID);
    updateElement.roleLevel = info.roleLevel;
    allList.refresh();
    // _adminList.removeWhere((e) => e.userID == info.userID);
    // _memberList.add(en.GroupMembersInfo.fromJson(info.toJson()));
    // _sortList();
  }

  void addMember() async {
    var memberList = await LoadingView.singleton.wrap(asyncFunction: () async {
      var friendList = await OpenIM.iMManager.friendshipManager.getFriendList();
      return OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupId: groupInfo.groupID,
        uidList: friendList.map((e) => e.userID!).toList(),
      );
    });

    var list = await AppNavigator.startSelectContacts(
      action: SelAction.ADD_MEMBER,
      defaultCheckedUidList: memberList.map((e) => e.userID!).toList(),
      groupID: groupInfo.groupID,
    );

    if (list is List<ContactsInfo>) {
      await OpenIM.iMManager.groupManager.inviteUserToGroup(
        groupId: groupInfo.groupID,
        uidList: list.map((e) => e.userID!).toList(),
        reason: 'Come on baby',
      );

      // 非群主或管理员，在设置了进群需要验证时，邀请的人不能直接进群
      if (!hasGroupPermission() &&
          groupInfo.needVerification == GroupVerification.allNeedVerification) {
        return;
      }

      list.forEach((e) {
        allList.add(en.GroupMembersInfo.fromJson({
          'groupID': groupInfo.groupID,
          'userID': e.userID,
          'faceURL': e.faceURL,
          'nickname': e.getShowName(),
          'roleLevel': GroupRoleLevel.member,
        }));
        // _memberList.add(en.GroupMembersInfo.fromJson({
        //   'groupID': _groupInfo.groupID,
        //   'userID': e.userID,
        //   'faceURL': e.faceURL,
        //   'nickname': e.getShowName(),
        // }));
        // _uidList.insert(0, e.userID!);
      });
      // _sortList();
      // _queryOnlineStatus();
      // _groupSetupLogic.memberListChanged(allList);
    }
  }

  void deleteMember() async {
    // var all = DeepCopy.copy(
    //   allList.value,
    //   (v) => en.GroupMembersInfo.fromJson(v.cast()),
    // );
    //
    // if (_isMyGroup()) {
    //   all.removeWhere((e) => e.roleLevel == GroupRoleLevel.owner);
    // } else if (isAdmin.value) {
    //   all.removeWhere((e) =>
    //       e.roleLevel == GroupRoleLevel.owner ||
    //       e.roleLevel == GroupRoleLevel.admin);
    // }

    var list = await AppNavigator.startGroupMemberList(
      gid: groupInfo.groupID,
      // list: all,
      action: OpAction.DELETE,
    );

    if (list is List<GroupMembersInfo>) {
      var removeUidList = list.map((e) => e.userID!).toList();
      await OpenIM.iMManager.groupManager.kickGroupMember(
        groupId: groupInfo.groupID,
        uidList: removeUidList,
        reason: 'Get out baby',
      );
      allList.removeWhere((element) => removeUidList.contains(element.userID));
      // _memberList.removeWhere((e) => removeUidList.contains(e.userID));
      // _adminList.removeWhere((e) => removeUidList.contains(e.userID));
      // _uidList.removeWhere((id) => removeUidList.contains(id));
      // _sortList();
      // _groupSetupLogic.memberListChanged(allList);
      // memberList.removeWhere((e) => list.contains(e.userId!));
      // memberList.refresh();
    }
  }

  /// 有移除群成员/禁言等权限
  bool hasGroupPermission() {
    return isAdmin.value || _isMyGroup();
  }

  /// 我是管理员
  bool _isMyGroup() {
    return groupInfo.ownerUserID == OpenIM.iMManager.uid;
  }

  void search() async {
    var info = await AppNavigator.startSearchMember(groupID: groupInfo.groupID);
    if (info != null) {
      viewUserInfo(info);
    }
  }

  @override
  void onInit() {
    groupInfo = Get.arguments;
    super.onInit();
  }

  @override
  void onReady() {
    getGroupMembers();
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  // void _queryOnlineStatus() {
  //   Apis.queryOnlineStatus(
  //     uidList: _uidList,
  //     onlineStatusDescCallback: (map) => onlineStatus.addAll(map),
  //   );
  // }

  /// 禁言权限
  /// 1普通成员, 2群主，3管理员
  bool get havePermissionMute => hasGroupPermission();
}
