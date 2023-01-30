import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/widgets/custom_dialog.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

class GroupAnnouncementSetupLogic extends GetxController {
  var enabled = false.obs;
  var focus = false.obs;
  var onlyRead = false.obs;
  var showFcBtn = false.obs;
  var inputCtrl = TextEditingController();
  var focusNode = FocusNode();
  late Rx<GroupInfo> groupInfo;
  var nickname = ''.obs;
  var faceUrl = "".obs;

  void setAnnouncement() async {
    var publish = await Get.dialog(CustomDialog(
      title: StrRes.announcementHint,
      rightText: StrRes.publish,
    ));
    if (publish == true) {
      await OpenIM.iMManager.groupManager.setGroupInfo(
        groupID: groupInfo.value.groupID,
        notification: inputCtrl.text,
      );
      groupInfo.update((val) {
        val?.notification = inputCtrl.text;
      });

      Get.back();
    }
  }

  @override
  void onInit() {
    groupInfo = Rx(GroupInfo.fromJson({"groupID": Get.arguments}));
    super.onInit();
  }

  @override
  void onReady() {
    queryGroupInfo();
    super.onReady();
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  editing() {
    onlyRead.value = false;
    enabled.value = true;
    focus.value = true;
    focusNode.requestFocus();
  }

  void queryGroupInfo() async {
    var list = await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.getGroupsInfo(
              gidList: [groupInfo.value.groupID],
            ));

    groupInfo.update((val) {
      var info = list.firstOrNull;
      val?.groupName = info?.groupName;
      val?.notification = info?.notification;
      val?.introduction = info?.introduction;
      val?.faceURL = info?.faceURL;
      val?.ownerUserID = info?.ownerUserID;
      val?.createTime = info?.createTime;
      val?.memberCount = info?.memberCount;
      val?.status = info?.status;
      val?.creatorUserID = info?.creatorUserID;
      val?.groupType = info?.groupType;
      val?.ex = info?.ex;
      val?.needVerification = info?.needVerification;
      val?.lookMemberInfo = info?.lookMemberInfo;
      val?.applyMemberFriend = info?.applyMemberFriend;
      val?.notificationUpdateTime = info?.notificationUpdateTime;
      val?.notificationUserID = info?.notificationUserID;
    });
    inputCtrl.text = groupInfo.value.notification ?? '';
    focus.value = inputCtrl.text.isEmpty;
    onlyRead.value = inputCtrl.text.isNotEmpty;
    showFcBtn.value = groupInfo.value.ownerUserID == OpenIM.iMManager.uid;
    inputCtrl.addListener(() {
      if (!onlyRead.value) enabled.value = inputCtrl.text.trim().isNotEmpty;
    });
    queryGroupMemberInfo();
  }

  void queryGroupMemberInfo() async {
    if (null != groupInfo.value.notificationUserID) {
      bool isSelf = groupInfo.value.notificationUserID! == OpenIM.iMManager.uid;
      var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupId: groupInfo.value.groupID,
        uidList: [
          groupInfo.value.notificationUserID!,
          if (!isSelf) OpenIM.iMManager.uid
        ],
      );

      var member = list.firstWhereOrNull(
          (e) => e.userID == groupInfo.value.notificationUserID!);
      nickname.value = member?.nickname ?? '';
      faceUrl.value = member?.faceURL ?? '';

      var me = list.firstWhereOrNull((e) => e.userID == OpenIM.iMManager.uid);
      showFcBtn.value = me?.roleLevel == GroupRoleLevel.admin ||
          me?.roleLevel == GroupRoleLevel.owner;
    }
  }
}
