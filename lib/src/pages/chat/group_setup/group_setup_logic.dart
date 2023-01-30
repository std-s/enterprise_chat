import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/core/controller/app_controller.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/models/group_member_info.dart' as en;
import 'package:openim_enterprise_chat/src/pages/chat/group_setup/group_member_manager/member_list/member_list_logic.dart';
import 'package:openim_enterprise_chat/src/pages/conversation/conversation_logic.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/custom_dialog.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

import '../../../models/contacts_info.dart';
import '../../select_contacts/select_contacts_logic.dart';
import '../chat_logic.dart';

class GroupSetupLogic extends GetxController {
  var imLogic = Get.find<IMController>();
  var chatLogic = Get.find<ChatLogic>();
  var appLogic = Get.find<AppController>();
  var conversationLogic = Get.find<ConversationLogic>();
  late Rx<GroupInfo> groupInfo;
  var memberList = <en.GroupMembersInfo>[].obs;
  var myGroupNickname = "".obs;
  var topContacts = false.obs;
  var noDisturb = false.obs;
  var noDisturbIndex = 0.obs;
  var isGroupAdmin = false.obs;
  ConversationInfo? conversationInfo;
  GroupMembersInfo? myGroupMembersInfo;
  late StreamSubscription groupInfoUpdatedSub;
  late StreamSubscription memberAddedSub;
  late StreamSubscription memberDeletedSub;

  getGroupMembers() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberListMap(
      groupId: groupInfo.value.groupID,
      count: 10,
    );

    var l = list.map((e) => en.GroupMembersInfo.fromJson(e));
    memberList.assignAll(l);
  }

  getGroupInfo() async {
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      gidList: [groupInfo.value.groupID],
    );
    if (list.isEmpty) return;
    var value = list.first;
    updateGroupInfo(value);
    getConversationInfo();
  }

  getMyGroupMemberInfo() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
      groupId: groupInfo.value.groupID,
      uidList: [OpenIM.iMManager.uid],
    );
    myGroupMembersInfo = list.firstOrNull;
    myGroupNickname.value = myGroupMembersInfo?.nickname ?? '';
    isGroupAdmin.value = myGroupMembersInfo?.roleLevel == GroupRoleLevel.admin;
  }

  void modifyAvatar() {
    IMWidget.openPhotoSheet(
      onData: (path, url) async {
        if (url != null) {
          await _updateGroupInfo(faceUrl: url);
          groupInfo.update((val) {
            val?.faceURL = url;
          });
        }
      },
    );
  }

  void modifyMyGroupNickname() {
    if (null != myGroupMembersInfo) {
      AppNavigator.startModifyMyNicknameInGroup(
        groupInfo: groupInfo.value,
        membersInfo: myGroupMembersInfo!,
      );
    }
  }

  void modifyGroupName() {
    if (!hasGroupPermission()) {
      IMWidget.showToast(StrRes.onlyTheOwnerCanModify);
      return;
    }
    AppNavigator.startGroupNameSet(info: groupInfo.value);
  }

  void editGroupAnnouncement() {
    AppNavigator.startEditAnnouncement(groupID: groupInfo.value.groupID);
  }

  void viewGroupQrcode() {
    AppNavigator.startViewGroupQrcode(info: groupInfo.value);
  }

  void viewGroupMembers() async {
    print('群组id:${groupInfo.value.ownerUserID}');
    AppNavigator.startGroupMemberManager(info: groupInfo.value);
  }

  void transferGroup() async {
    // var list = memberList;
    // list.removeWhere((e) => e.userID == groupInfo.value.ownerUserID);
    var result = await AppNavigator.startGroupMemberList(
      gid: groupInfo.value.groupID,
      // list: list,
      action: OpAction.ADMIN_TRANSFER,
    );
    if (null != result) {
      GroupMembersInfo member = result;
      await OpenIM.iMManager.groupManager.transferGroupOwner(
        gid: groupInfo.value.groupID,
        uid: member.userID!,
      );

      groupInfo.update((val) {
        val?.ownerUserID = member.userID;
      });
    }
  }

  void quitGroup() async {
    if (isMyGroup()) {
      var confirm = await Get.dialog(CustomDialog(
        title: StrRes.dismissGroupHint,
        rightText: StrRes.sure,
      ));
      if (confirm == true) {
        // transferGroup();
        await OpenIM.iMManager.groupManager.dismissGroup(
          groupID: groupInfo.value.groupID,
        );

        // 删除群会话
        await OpenIM.iMManager.conversationManager
            .deleteConversationFromLocalAndSvr(
          conversationID: conversationInfo!.conversationID,
        );

        conversationLogic.removeConversation(conversationInfo!.conversationID);
      } else {
        return;
      }
    } else {
      var confirm = await Get.dialog(CustomDialog(
        title: StrRes.quitGroupHint,
        rightText: StrRes.sure,
      ));
      if (confirm == true) {
        // 退群
        await OpenIM.iMManager.groupManager.quitGroup(
          gid: groupInfo.value.groupID,
        );
        // 删除群会话
        await OpenIM.iMManager.conversationManager
            .deleteConversationFromLocalAndSvr(
          conversationID: conversationInfo!.conversationID,
        );

        conversationLogic.removeConversation(conversationInfo!.conversationID);
      } else {
        return;
      }
    }
    AppNavigator.startBackMain();
  }

  void memberListChanged(list) {
    // memberList.assignAll(list);
    // groupInfo.update((val) {
    //   val?.memberCount = list.length;
    // });
  }

  void copyGroupID() {
    AppNavigator.startViewGroupId(info: groupInfo.value);
    // Get.toNamed(AppRoutes.GROUP_ID, arguments: info.value);
  }

  bool hasGroupPermission() {
    return isMyGroup() || isGroupAdmin.value;
  }

  bool isMyGroup() {
    return groupInfo.value.ownerUserID == OpenIM.iMManager.uid;
  }

  _updateGroupInfo({
    String? groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
  }) {
    return OpenIM.iMManager.groupManager.setGroupInfo(
      groupID: groupInfo.value.groupID,
      groupName: groupName,
      notification: notification,
      introduction: introduction,
      faceUrl: faceUrl,
    );
  }

  @override
  void onInit() {
    groupInfo = GroupInfo(
      groupID: Get.arguments['gid'],
      groupName: Get.arguments['name'],
      faceURL: Get.arguments['icon'],
      memberCount: 0,
    ).obs;
    groupInfoUpdatedSub = imLogic.groupInfoUpdatedSubject.listen((value) {
      if (value.groupID == groupInfo.value.groupID) {
        updateGroupInfo(value);
      }
    });
    memberAddedSub = imLogic.memberAddedSubject.listen((e) {
      var i = en.GroupMembersInfo.fromJson(e.toJson());
      memberList.add(i);
      groupInfo.update((val) {
        val?.memberCount = groupInfo.value.memberCount! + 1;
      });
    });
    memberDeletedSub = imLogic.memberDeletedSubject.listen((e) {
      memberList.removeWhere((element) => element.userID == e.userID);
      groupInfo.update((val) {
        val?.memberCount = groupInfo.value.memberCount! - 1;
      });
    });
    super.onInit();
  }

  @override
  void onReady() {
    getGroupInfo();
    getGroupMembers();
    getMyGroupMemberInfo();
    super.onReady();
  }

  @override
  void onClose() {
    groupInfoUpdatedSub.cancel();
    memberAddedSub.cancel();
    memberDeletedSub.cancel();
    super.onClose();
  }

  int length() {
    int buttons = hasGroupPermission() ? 2 : 1;
    return (memberList.length + buttons) > 7
        ? 7
        : (memberList.length + buttons);
  }

  Widget itemBuilder({
    required int index,
    required Widget Function(GroupMembersInfo info) builder,
    required Widget Function() addButton,
    required Widget Function() delButton,
  }) {
    var length = hasGroupPermission() ? 5 : 6;
    if (memberList.length > length) {
      if (index < length) {
        var info = memberList.elementAt(index);
        return builder(info);
      } else if (index == length) {
        return addButton();
      } else {
        return delButton();
      }
    } else {
      if (index < memberList.length) {
        var info = memberList.elementAt(index);
        return builder(info);
      } else if (index == memberList.length) {
        return addButton();
      } else {
        return delButton();
      }
    }
  }

  void getConversationInfo() async {
    conversationInfo =
        await OpenIM.iMManager.conversationManager.getOneConversation(
      sourceID: groupInfo.value.groupID,
      sessionType: groupInfo.value.sessionType,
    );
    topContacts.value = conversationInfo!.isPinned!;

    var status = conversationInfo!.recvMsgOpt;
    noDisturb.value = status != 0;
    if (noDisturb.value) {
      noDisturbIndex.value = status == 1 ? 1 : 0;
    }
  }

  void toggleTopContacts() async {
    topContacts.value = !topContacts.value;
    if (conversationInfo == null) return;
    await OpenIM.iMManager.conversationManager.pinConversation(
      conversationID: conversationInfo!.conversationID,
      isPinned: topContacts.value,
    );
  }

  void clearChatHistory() async {
    var confirm = await Get.dialog(CustomDialog(
      title: StrRes.confirmClearChatHistory,
      rightText: StrRes.clearAll,
    ));
    if (confirm == true) {
      await OpenIM.iMManager.messageManager
          .clearGroupHistoryMessageFromLocalAndSvr(
        gid: groupInfo.value.groupID,
      );
      chatLogic.clearAllMessage();
      IMWidget.showToast(StrRes.clearSuccess);
    }
  }

  void toggleNotDisturb() {
    noDisturb.value = !noDisturb.value;
    if (!noDisturb.value) noDisturbIndex.value = 0;
    setConversationRecvMessageOpt(status: noDisturb.value ? 2 : 0);
  }

  void noDisturbSetting() {
    IMWidget.openNoDisturbSettingSheet(
      isGroup: true,
      showBlock: groupInfo.value.groupType != GroupType.work,
      onTap: (index) {
        setConversationRecvMessageOpt(status: index == 0 ? 2 : 1);
        noDisturbIndex.value = index;
      },
    );
  }

  /// 消息免打扰
  /// 1: Do not receive messages, 2: Do not notify when messages are received; 0: Normal
  void setConversationRecvMessageOpt({int status = 2}) {
    LoadingView.singleton.wrap(
      asyncFunction: () =>
          OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(
        conversationIDList: [
          groupInfo.value.groupType == GroupType.work
              ? 'super_group_${groupInfo.value.groupID}'
              : 'group_${groupInfo.value.groupID}'
        ],
        status: status,
      ),
    );
  }

  void searchHistoryMessage() {
    AppNavigator.startMessageSearch(info: conversationInfo!);
  }

  void toggleGroupMute() {
    // info.update((val) {
    //   val?.status = (info.value.status == 3) ? 0 : 3;
    // });
    LoadingView.singleton.wrap(asyncFunction: () async {
      await OpenIM.iMManager.groupManager.changeGroupMute(
        groupID: groupInfo.value.groupID,
        mute: !(groupInfo.value.status == 3),
      );
    });
  }

  void modifyJoinGroupSet() {
    IMWidget.openJoinGroupSettingSheet(onTap: (index) async {
      final value = index == 0
          ? GroupVerification.directly
          : (index == 1
              ? GroupVerification.applyNeedVerificationInviteDirectly
              : GroupVerification.allNeedVerification);
      await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.setGroupVerification(
          groupID: groupInfo.value.groupID,
          needVerification: value,
        ),
      );
      groupInfo.update((val) {
        val?.needVerification = value;
      });
    });
  }

  String getJoinGroupOption() {
    final value = groupInfo.value.needVerification;
    if (value == GroupVerification.allNeedVerification) {
      return StrRes.needVerification;
    } else if (value == GroupVerification.directly) {
      return StrRes.allowAnyoneJoinGroup;
    }
    return StrRes.inviteNotVerification;
  }

  String getGroupType() {
    if (groupInfo.value.groupType == GroupType.work) {
      return StrRes.workGroup;
    }
    return StrRes.generalGroup;
  }

  void groupMemberPermissionSet() {
    AppNavigator.startGroupMemberPermissionSet(info: groupInfo.value);
  }

  void updateGroupInfo(GroupInfo value) {
    groupInfo.update((val) {
      val?.groupName = value.groupName;
      val?.faceURL = value.faceURL;
      val?.notification = value.notification;
      val?.introduction = value.introduction;
      val?.memberCount = value.memberCount;
      val?.ownerUserID = value.ownerUserID;
      val?.status = value.status;
      val?.needVerification = value.needVerification;
      val?.groupType = value.groupType;
      val?.lookMemberInfo = value.lookMemberInfo;
      val?.applyMemberFriend = value.applyMemberFriend;
      val?.notificationUserID = value.notificationUserID;
      val?.notificationUpdateTime = value.notificationUpdateTime;
    });
  }

  void addMember() async {
    var memberList = await LoadingView.singleton.wrap(asyncFunction: () async {
      var friendList = await OpenIM.iMManager.friendshipManager.getFriendList();
      return OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupId: groupInfo.value.groupID,
        uidList: friendList.map((e) => e.userID!).toList(),
      );
    });

    var list = await AppNavigator.startSelectContacts(
      action: SelAction.ADD_MEMBER,
      defaultCheckedUidList: memberList.map((e) => e.userID!).toList(),
      groupID: groupInfo.value.groupID,
    );

    if (list is List<ContactsInfo>) {
      await OpenIM.iMManager.groupManager.inviteUserToGroup(
        groupId: groupInfo.value.groupID,
        uidList: list.map((e) => e.userID!).toList(),
        reason: 'Come on baby',
      );

      // 非群主或管理员，在设置了进群需要验证时，邀请的人不能直接进群
      if (!hasGroupPermission() &&
          groupInfo.value.needVerification ==
              GroupVerification.allNeedVerification) {
        return;
      }
    }
  }

  void removeMember() async {
    // var all = DeepCopy.copy(
    //   memberList.value,
    //   (v) => en.GroupMembersInfo.fromJson(v.cast()),
    // );

    // if (isMyGroup()) {
    //   all.removeWhere((e) => e.roleLevel == GroupRoleLevel.owner);
    // } else if (isGroupAdmin.value) {
    //   all.removeWhere((e) =>
    //       e.roleLevel == GroupRoleLevel.owner ||
    //       e.roleLevel == GroupRoleLevel.admin);
    // }

    var list = await AppNavigator.startGroupMemberList(
      gid: groupInfo.value.groupID,
      // list: all,
      action: OpAction.DELETE,
    );

    if (list is List<GroupMembersInfo>) {
      var removeUidList = list.map((e) => e.userID!).toList();
      await OpenIM.iMManager.groupManager.kickGroupMember(
        groupId: groupInfo.value.groupID,
        uidList: removeUidList,
        reason: 'Get out baby',
      );
    }
  }
}
