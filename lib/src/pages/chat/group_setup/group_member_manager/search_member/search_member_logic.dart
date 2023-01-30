import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart' as im;
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/models/group_member_info.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

import '../member_list/member_list_logic.dart';

class SearchMemberLogic extends GetxController {
  var focusNode = FocusNode();
  var searchCtrl = TextEditingController();

  // var memberList = <GroupMembersInfo>[];
  var resultList = <GroupMembersInfo>[].obs;
  late String groupID;
  var pageSize = 40;
  im.GroupMembersInfo? myMemberInfo;
  OpAction? action;

  @override
  void onInit() {
    // var list = Get.arguments;
    // if (list is List<GroupMembersInfo>) {
    //   memberList.addAll(list);
    // }
    groupID = Get.arguments['groupID'];
    myMemberInfo = Get.arguments['info'];
    action = Get.arguments['action'];
    searchCtrl.addListener(() {
      var key = searchCtrl.text.trim();
      if (key.isEmpty) {
        resultList.clear();
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    focusNode.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  search() async {
    var key = searchCtrl.text.trim();
    // resultList.clear();
    if (key.isNotEmpty) {
      var result = await LoadingView.singleton.wrap(
          asyncFunction: () =>
              im.OpenIM.iMManager.groupManager.searchGroupMembersListMap(
                groupID: groupID,
                isSearchMemberNickname: true,
                isSearchUserID: true,
                keywordList: [key],
              ));

      final list = result.map((e) => GroupMembersInfo.fromJson(e)).toList();
      list.removeWhere(excludeMembers);
      resultList.assignAll(list);
      // memberList.forEach((element) {
      //   if (element.nickname!.toUpperCase().contains(key.toUpperCase())) {
      //     resultList.add(element);
      //   }
      // });
    }
  }

  bool excludeMembers(GroupMembersInfo info) {
    if (action == OpAction.DELETE) {
      if (myMemberInfo?.roleLevel == im.GroupRoleLevel.owner) {
        return info.userID == im.OpenIM.iMManager.uid;
      } else if (myMemberInfo?.roleLevel == im.GroupRoleLevel.admin) {
        return info.roleLevel == im.GroupRoleLevel.admin ||
            info.roleLevel == im.GroupRoleLevel.owner;
      }
    } else if (action == OpAction.ADMIN_TRANSFER || action == OpAction.AT) {
      return info.userID == im.OpenIM.iMManager.uid;
    }
    return false;
  }

  selected(GroupMembersInfo info) {
    Get.back(result: info);
  }
}
