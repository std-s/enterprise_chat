import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/common/apis.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/pages/chat/chat_logic.dart';
import 'package:openim_enterprise_chat/src/pages/contacts/friend_info/personal_info/personal_info.dart';
import 'package:openim_enterprise_chat/src/pages/contacts/friend_info/set_info/set_info_binding.dart';
import 'package:openim_enterprise_chat/src/pages/contacts/friend_info/set_info/set_info_view.dart';
import 'package:openim_enterprise_chat/src/pages/conversation/conversation_logic.dart';
import 'package:openim_enterprise_chat/src/pages/select_contacts/select_contacts_logic.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:openim_enterprise_chat/src/widgets/custom_dialog.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';
import 'package:sprintf/sprintf.dart';

import '../../../core/controller/app_controller.dart';
import '../../chat/group_setup/group_member_manager/group_member_manager_logic.dart';

class FriendInfoLogic extends GetxController {
  var appLogic = Get.find<AppController>();
  late Rx<UserInfo> userInfo;
  String? groupID;
  bool? offAllWhenDelFriend = false;
  var showMuteFunction = false.obs;
  var showSetAdminFunction = false.obs;
  var imLogic = Get.find<IMController>();
  var conversationLogic = Get.find<ConversationLogic>();
  var mutedTime = "".obs;
  GroupMembersInfo? groupMembersInfo;
  GroupInfo? groupInfo;
  var onlineStatus = false.obs;
  var onlineStatusDesc = ''.obs;
  var userDeptList = <UserInDept>[].obs;
  var groupUserNickname = "".obs;
  var joinGroupTime = 0.obs;
  var joinGroupMethod = ''.obs;
  var hasAdminPermission = false.obs;
  var notAllowLookGroupMemberProfiles = false.obs;
  var notAllowAddGroupMemberFriend = false.obs;
  var iHaveAdminOrOwnerPermission = false.obs;
  late StreamSubscription friendAddSub;
  late StreamSubscription friendInfoChangedSub;
  late StreamSubscription memberInfoChangedSub;

  void toggleBlacklist() {
    if (userInfo.value.isBlacklist == true) {
      removeBlacklist();
    } else {
      addBlacklist();
    }
  }

  /// 加入黑名单
  void addBlacklist() async {
    var confirm = await Get.dialog(CustomDialog(
      title: StrRes.areYouSureAddBlacklist,
      rightText: StrRes.sure,
    ));
    if (confirm == true) {
      var result = await OpenIM.iMManager.friendshipManager.addBlacklist(
        uid: userInfo.value.userID!,
      );
      userInfo.update((val) {
        val?.isBlacklist = true;
      });
      try {
        bool have = Get.isRegistered<ChatLogic>();
        if (have) Get.find<ChatLogic>().isInBlacklist.value = true;
      } catch (e) {}
      print('result:$result');
    }
  }

  /// 从黑名单移除
  void removeBlacklist() async {
    var result = await OpenIM.iMManager.friendshipManager.removeBlacklist(
      uid: userInfo.value.userID!,
    );
    userInfo.update((val) {
      val?.isBlacklist = false;
    });
    try {
      bool have = Get.isRegistered<ChatLogic>();
      if (have) Get.find<ChatLogic>().isInBlacklist.value = false;
    } catch (e) {}
    print('result:$result');
  }

  /// 解除好友关系
  void deleteFromFriendList() async {
    var confirm = await Get.dialog(CustomDialog(
      title: StrRes.areYouSureDelFriend,
      rightText: StrRes.delete,
    ));
    if (confirm) {
      await LoadingView.singleton.wrap(asyncFunction: () async {
        var result = await OpenIM.iMManager.friendshipManager.deleteFriend(
          uid: userInfo.value.userID!,
        );
        userInfo.update((val) {
          val?.isFriendship = false;
        });
        final id = 'single_${userInfo.value.userID}';
        await OpenIM.iMManager.conversationManager
            .deleteConversationFromLocalAndSvr(conversationID: id);
        conversationLogic.list.removeWhere((e) => e.conversationID == id);
        print('offAllWhenDelFriend:$offAllWhenDelFriend');
        if (offAllWhenDelFriend == true) {
          AppNavigator.startBackMain();
        } else {
          Get.back();
        }
      });
    }
  }

  /// 检查是否是好友
  void checkFriendship() async {
    // var list = await OpenIM.iMManager.friendshipManager
    //     .checkFriend(uidList: [info.value.userID!]);
    // if (list.isNotEmpty) {
    //   info.update((val) {
    //     val?.flag = list.first.flag;
    //   });
    // }
  }

  void toChat() {
    conversationLogic.startChat(
      userID: userInfo.value.userID,
      nickname: userInfo.value.getShowName(),
      faceURL: userInfo.value.faceURL,
      type: 1,
    );
  }

  void addFriend() {
    if (userInfo.value.userID == OpenIM.iMManager.uid) {
      IMWidget.showToast(StrRes.notAddSelf);
      return;
    }
    AppNavigator.startSendFriendRequest(info: userInfo.value);
  }

  void toCopyId() {
    AppNavigator.startFriendIDCode(info: userInfo.value);
  }

  void copyID() {
    IMUtil.copy(text: userInfo.value.userID ?? '');
  }

  void toSetupRemark() async {
    var remarkName = await AppNavigator.startSetFriendRemarksName(
      info: userInfo.value,
    );
    if (remarkName != null) {
      userInfo.update((val) {
        val?.remark = remarkName;
      });
    }
  }

  void getFriendInfo() async {
    var list = await OpenIM.iMManager.userManager.getUsersInfo(
      uidList: [userInfo.value.userID!],
    );
    // var list = await OpenIM.iMManager.friendshipManager.getFriendsInfo(
    //   uidList: [info.value.userID!],
    // );
    if (list.isNotEmpty) {
      var user = list.first;
      userInfo.update((val) {
        val?.nickname = user.nickname;
        val?.faceURL = user.faceURL;
        val?.remark = user.remark;
        val?.gender = user.gender;
        val?.phoneNumber = user.phoneNumber;
        val?.birth = user.birth;
        val?.email = user.email;
        val?.isBlacklist = user.isBlacklist;
        val?.isFriendship = user.isFriendship;
      });
    }
  }

  void recommendFriend() async {
    var result = await AppNavigator.startSelectContacts(
      action: SelAction.RECOMMEND,
      excludeUidList: [userInfo.value.userID!],
    );
    if (null == result) return;
    var uid = result['userID'];
    var gid = result['groupID'];
    // var name = result['nickname'];
    // var icon = result['faceURL'];
    // AppNavigator.startChat();
    var message = await OpenIM.iMManager.messageManager.createCardMessage(
      data: {
        "userID": userInfo.value.userID,
        'nickname': userInfo.value.nickname,
        'faceURL': userInfo.value.faceURL
      },
    );
    OpenIM.iMManager.messageManager.sendMessage(
      message: message,
      userID: uid,
      groupID: gid,
      offlinePushInfo: OfflinePushInfo(
        title: "你收到了一条消息",
        desc: "你收到了一条消息",
        iOSBadgeCount: true,
        iOSPushSound: '+1',
      ),
    );
  }

  @override
  void onInit() {
    userInfo = Rx(Get.arguments['userInfo']);
    groupID = Get.arguments['groupID'];
    offAllWhenDelFriend = Get.arguments['offAllWhenDelFriend'];
    // showMuteFunction.value = Get.arguments['showMuteFunction'];
    print(' user:   ${json.encode(userInfo.value)}');
    friendAddSub = imLogic.friendAddSubject.listen((user) {
      print('add user:   ${json.encode(user)}');
      if (user.userID == userInfo.value.userID) {
        userInfo.update((val) {
          val?.isFriendship = true;
        });
      }
    });
    friendInfoChangedSub = imLogic.friendInfoChangedSubject.listen((user) {
      print('update user info:   ${json.encode(user)}');
      if (user.userID == userInfo.value.userID) {
        userInfo.update((val) {
          val?.nickname = user.nickname;
          val?.gender = user.gender;
          val?.phoneNumber = user.phoneNumber;
          val?.birth = user.birth;
          val?.email = user.email;
          val?.remark = user.remark;
        });
      }
    });
    memberInfoChangedSub = imLogic.memberInfoChangedSubject.listen((value) {
      if (value.userID == userInfo.value.userID && null != value.muteEndTime) {
        _calMuteTime(value.muteEndTime!);
      }
    });
    super.onInit();
  }

  void viewPersonalInfo() {
    Get.to(
      () => PersonalInfoPage(),
      popGesture: true,
      transition: Transition.cupertino,
    );
  }

  @override
  void onReady() {
    queryGroupInfo();
    queryGroupMemberInfo();
    getFriendInfo();
    checkFriendship();
    queryUserOnlineStatus();
    queryUserDept();
    super.onReady();
  }

  @override
  void onClose() {
    friendAddSub.cancel();
    friendInfoChangedSub.cancel();
    memberInfoChangedSub.cancel();
    super.onClose();
  }

  /// 群主禁言（取消禁言）管理员和普通成员，管理员只能禁言（取消禁言）普通成员
  void setMute() {
    AppNavigator.startSetGroupMemberMute(
      userID: userInfo.value.userID!,
      groupID: groupID!,
    );
  }

  /// 查询我与当前页面用户的群成员信息
  void queryGroupMemberInfo() async {
    if (null != groupID) {
      var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupId: groupID!,
        uidList: [userInfo.value.userID!, if (!isMyself()) OpenIM.iMManager.uid],
      );
      var other = list.firstWhereOrNull((e) => e.userID == userInfo.value.userID);
      groupMembersInfo = other;
      groupUserNickname.value = other?.nickname ?? '';
      joinGroupTime.value = other?.joinTime ?? 0;
      // 入群方式 2：邀请加入 3：搜索加入 4：通过二维码加入
      if (other?.joinSource == 2) {
        if (other?.inviterUserID != null) {
          OpenIM.iMManager.groupManager.getGroupMembersInfo(
            groupId: groupID!,
            uidList: [other!.inviterUserID!],
          ).then((list) {
            var inviterUserInfo = list.firstOrNull;
            joinGroupMethod.value = sprintf(
              StrRes.byInviteJoinGroup,
              [inviterUserInfo?.nickname ?? ''],
            );
          });
        }
      } else if (other?.joinSource == 3) {
        joinGroupMethod.value = StrRes.byIDJoinGroup;
      } else if (other?.joinSource == 4) {
        joinGroupMethod.value = StrRes.byQrcodeJoinGroup;
      }

      hasAdminPermission.value = other?.roleLevel == GroupRoleLevel.admin;
      if (!isMyself()) {
        var me = list.firstWhereOrNull((e) => e.userID == OpenIM.iMManager.uid);
        // 只有群主可以设置管理员
        showSetAdminFunction.value = me?.roleLevel == GroupRoleLevel.owner;
        // 群主禁言（取消禁言）管理员和普通成员，管理员只能禁言（取消禁言）普通成员
        showMuteFunction.value = me?.roleLevel == GroupRoleLevel.owner ||
            (me?.roleLevel == GroupRoleLevel.admin && other?.roleLevel == GroupRoleLevel.member);
        //
        iHaveAdminOrOwnerPermission.value =
            me?.roleLevel == GroupRoleLevel.owner || me?.roleLevel == GroupRoleLevel.admin;
      }

      if (null != other && null != other.muteEndTime && other.muteEndTime! > 0) {
        _calMuteTime(other.muteEndTime!);
      }
    }
  }

  _calMuteTime(int time) {
    var date = DateUtil.formatDateMs(time * 1000, format: 'yyyy/MM/dd HH:mm');
    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var diff = time - now;
    if (diff > 0) {
      mutedTime.value = date;
    } else {
      mutedTime.value = "";
    }
  }

  queryGroupInfo() async {
    if (null != groupID) {
      var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
        gidList: [groupID!],
      );
      groupInfo = list.firstOrNull;
      // 不允许查看群成员资料
      notAllowLookGroupMemberProfiles.value = groupInfo?.lookMemberInfo == 1;
      // 不允许添加组成员为好友
      notAllowAddGroupMemberFriend.value = groupInfo?.applyMemberFriend == 1;
    }
  }

  /// 在线状态
  queryUserOnlineStatus() {
    Apis.queryUserOnlineStatus(
      uidList: [userInfo.value.userID!],
      onlineStatusCallback: (map) {
        onlineStatus.value = map[userInfo.value.userID!]!;
      },
      onlineStatusDescCallback: (map) {
        onlineStatusDesc.value = map[userInfo.value.userID!]!;
      },
    );
  }

  toFriendSettings() {
    Get.to(
      () => SetFriendInfoPage(),
      binding: SetFriendInfoBinding(),
      popGesture: true,
      transition: Transition.cupertino,
    );
  }

  /// 部门信息
  queryUserDept() async {
    var list =
        await OpenIM.iMManager.organizationManager.getUserInDept(userID: userInfo.value.userID!);
    userDeptList.addAll(list);
  }

  /// 设置为管理员
  void toggleAdmin() async {
    final hasPermission = !hasAdminPermission.value;
    final roleLevel = hasPermission ? GroupRoleLevel.admin : GroupRoleLevel.member;
    await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.setGroupMemberRoleLevel(
              groupID: groupID!,
              userID: userInfo.value.userID!,
              roleLevel: roleLevel,
            ));

    groupMembersInfo?.roleLevel = roleLevel;
    hasAdminPermission.value = hasPermission;

    if (null != groupMembersInfo) {
      final logic = Get.find<GroupMemberManagerLogic>();
      if (hasAdminPermission.value) {
        logic.addAdminRole(groupMembersInfo!);
      } else {
        logic.removeAdminRole(groupMembersInfo!);
      }
    }
    IMWidget.showToast(StrRes.setSuccessfully);
  }

  /// 是当前登录用户的资料页
  bool isMyself() => userInfo.value.userID == OpenIM.iMManager.uid;

  /// 当前是群成员资料页面
  bool isGroupMemberPage() => null != groupID && groupID!.isNotEmpty;

  String getShowName() {
    if (userInfo.value.remark != null && userInfo.value.remark!.isNotEmpty) {
      return '${userInfo.value.nickname}(${userInfo.value.remark})';
    }
    return userInfo.value.nickname ?? '';
  }

  bool get isAllowSendMsgNotFriend => appLogic.clientConfigMap['allowSendMsgNotFriend'] == 1;

  bool get showMsgSendButton => isMyFriend || isAllowSendMsgNotFriend;

  bool get showAddFriendButton =>
      !isMyFriend &&
      (!isGroupMemberPage() || isGroupMemberPage() && !notAllowAddGroupMemberFriend.value);

  bool get isMyFriend => userInfo.value.isFriendship == true;

  bool get canViewProfile {
    return isMyFriend || isGroupMemberPage() && notAllowLookGroupMemberProfiles.value == false;
  }
}
