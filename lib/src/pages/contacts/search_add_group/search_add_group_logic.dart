import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/pages/conversation/conversation_logic.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/custom_dialog.dart';

enum JoinGroupMethod { search, qrcode, invite }

class SearchAddGroupLogic extends GetxController {
  late Rx<GroupInfo> info;
  var isJoined = false.obs;
  var members = <GroupMembersInfo>[].obs;
  final conversationLogic = Get.find<ConversationLogic>();
  final imLogic = Get.find<IMController>();
  late StreamSubscription sub;
  late JoinGroupMethod method;

  @override
  void onInit() {
    info = Rx(Get.arguments['info']);
    method = Get.arguments['method'];
    sub = imLogic.groupApplicationChangedSubject.listen((value) {
      if (value.groupID == info.value.groupID && value.handleResult == 1) {
        isJoined.value = true;
        // _getMembers();
      }
      // _checkGroup();
    });
    _getGroupInfo();
    _checkGroup();
    _getMembers();
    super.onInit();
  }

  _getGroupInfo() async {
    var list = await OpenIM.iMManager.groupManager
        .getGroupsInfo(gidList: [info.value.groupID]);
    if (list.isNotEmpty) {
      var nInfo = list.first;
      info.update((val) {
        val?.groupName = nInfo.groupName;
        val?.faceURL = nInfo.faceURL;
        val?.memberCount = nInfo.memberCount;
      });
    }
  }

  _checkGroup() async {
    isJoined.value = await OpenIM.iMManager.groupManager
        .isJoinedGroup(gid: info.value.groupID);
  }

  _getMembers() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberList(
      groupId: info.value.groupID,
      count: 10,
    );
    members.assignAll(list);
  }

  enterGroup() async {
    if (isJoined.value) {
      conversationLogic.startChat(
        groupID: info.value.groupID,
        nickname: info.value.groupName,
        faceURL: info.value.faceURL,
        type: 1,
        sessionType: info.value.sessionType,
      );
    } else {
      final result = await OpenIM.iMManager.groupManager.getSendGroupApplicationList();
      final elem = result.firstWhereOrNull((element) => element.groupID == info.value.groupID);
      // if (elem == null) {
      AppNavigator.applyEnterGroup(info.value, method);
      // } else {
      //   Get.dialog(CustomDialog(
      //     title: '已经提交过加群申请了～',
      //   ));
      // }
    }
  }

  @override
  void onClose() {
    sub.cancel();
    super.onClose();
  }
}
