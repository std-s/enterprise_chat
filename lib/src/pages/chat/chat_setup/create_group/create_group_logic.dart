import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/models/contacts_info.dart';
import 'package:openim_enterprise_chat/src/pages/conversation/conversation_logic.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/custom_dialog.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../common/config.dart';
import '../../../select_contacts/select_contacts_logic.dart';

class CreateGroupInChatSetupLogic extends GetxController {
  var nameCtrl = TextEditingController(text: StrRes.searchGroup);
  var memberList = <ContactsInfo>[].obs;
  var avatarUrl = ''.obs;
  var conversationLogic = Get.find<ConversationLogic>();
  late int groupType;

  @override
  void onInit() {
    var list = Get.arguments['members'];
    groupType = Get.arguments['groupType'];
    final info = memberList.value
        .firstWhereOrNull((element) => element.userID == OpenIM.iMManager.uInfo.userID);
    memberList.value.addIf(info != null, ContactsInfo.fromJson(OpenIM.iMManager.uInfo.toJson()));
    memberList.addAll(list);
    super.onInit();
  }

  completeCreation() async {
    if (nameCtrl.text.trim().isEmpty) {
      IMWidget.showToast(StrRes.createGroupNameHint);
      return;
    }

    // 普通群限制
    if (groupType == GroupType.general && memberList.length > Config.normalGroupMaxItems) {
      var confirm = await Get.dialog(CustomDialog(
        title: sprintf(StrRes.tooManyPeopleTipsWhenCreateGroup, [Config.normalGroupMaxItems]),
        rightText: StrRes.justNow,
      ));
      if (confirm == true) {
        groupType = GroupType.work;
      } else {
        return;
      }
    }

    if (groupType == GroupType.work && memberList.length > Config.workGroupMaxItems) {
      // 工作群限制
      Get.dialog(CustomDialog(
        title: sprintf(StrRes.maxPersonWhenCreateGroup, [Config.workGroupMaxItems]),
        rightText: StrRes.sure,
      ));
      return;
    }

    var info = await OpenIM.iMManager.groupManager.createGroup(
      groupName: nameCtrl.text,
      faceUrl: avatarUrl.value,
      list: memberList.map((e) => GroupMemberRole(userID: e.userID)).toList(),
      groupType: groupType,
    );
    print('create group :  ${jsonEncode(info)}  groupType : $groupType');
    conversationLogic.startChat(
      type: 1,
      groupID: info.groupID,
      nickname: nameCtrl.text,
      faceURL: avatarUrl.value,
      sessionType: info.sessionType,
    );
  }

  void setAvatar() {
    IMWidget.openPhotoSheet(onData: (path, url) {
      if (url != null) avatarUrl.value = url;
    });
  }

  int length() {
    return (memberList.length + 2) > 6 ? 6 : (memberList.length + 2);
  }

  Widget itemBuilder({
    required int index,
    required Widget Function(ContactsInfo info) builder,
    required Widget Function() addButton,
    required Widget Function() delButton,
  }) {
    if (memberList.length > 4) {
      if (index < 4) {
        var info = memberList.elementAt(index);
        return builder(info);
      } else if (index == 4) {
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

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    super.onClose();
  }

  void opMember() async {
    var myself = memberList.firstWhereOrNull((e) => e.userID == OpenIM.iMManager.uid);
    var list = await AppNavigator.startSelectContacts(
      action: SelAction.ADD_MEMBER,
      // defaultCheckedUidList: [OpenIM.iMManager.uid],
      // excludeUidList: [OpenIM.iMManager.uid],
      checkedList: memberList..remove(myself),
    );
    if (null != list) {
      memberList
        ..assignAll(list)
        ..insert(0, myself!);
    } else {
      memberList.insert(0, myself!);
    }
  }
}
