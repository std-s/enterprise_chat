import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/contacts_info.dart';
import '../select_contacts_logic.dart';

class SearchSelectContactsLogic extends GetxController {
  final selectContactsLogic = Get.find<SelectContactsLogic>();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final refreshCtrl = RefreshController();
  final friendList = <FriendInfo>[].obs;
  final groupList = <GroupInfo>[].obs;
  final deptMemberList = <DeptMemberInfo>[].obs;
  var offset = 0;
  var count = 40;

  void search() async {
    if (searchCtrl.text.trim().isEmpty) {
      return;
    }
    searchFriends();
    if (!selectContactsLogic.isMultiModel()) searchGroup();
    searchDeptMember();
  }

  void searchFriends() async {
    var list = await OpenIM.iMManager.friendshipManager.searchFriends(
      keywordList: [searchCtrl.text.trim()],
      isSearchRemark: true,
      isSearchNickname: true,
    );
    friendList.assignAll(list);
  }

  void searchGroup() async {
    var list = await OpenIM.iMManager.groupManager.searchGroups(
      keywordList: [searchCtrl.text.trim()],
      isSearchGroupName: true,
    );
    groupList.assignAll(list);
  }

  void searchDeptMember() async {
    var result = await _searchDeptMember(offset = 0);
    deptMemberList.assignAll(result.departmentMemberList ?? []);
  }

  void loadDeptMember() async {
    var result = await _searchDeptMember(++offset);
    deptMemberList.addAll(result.departmentMemberList ?? []);
  }

  Future<OrganizationSearchResult> _searchDeptMember(int offset) async {
    var result = await OpenIM.iMManager.organizationManager.searchOrganization(
      keyWord: searchCtrl.text.trim(),
      isSearchUserName: true,
      isSearchEnglishName: true,
      isSearchPosition: true,
      offset: offset,
      count: count,
    );
    if ((result.departmentMemberList?.length ?? 0) < count) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }
    return result;
  }

  void clear() {
    searchCtrl.clear();
    focusNode.requestFocus();
    friendList.clear();
    groupList.clear();
    deptMemberList.clear();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  bool isChecked(dynamic info) {
    return selectContactsLogic.checkedList.contains(_convertContactsInfo(
      userID: info.userID!,
      nickname: info.nickname,
      faceURL: info.faceURL,
    ));
  }

  bool isDefaultChecked(dynamic info) {
    return selectContactsLogic.defaultCheckedUidList.contains(info.userID!);
  }

  ContactsInfo _convertContactsInfo({
    required String userID,
    String? nickname,
    String? faceURL,
  }) =>
      ContactsInfo.fromJson({
        'userID': userID,
        'nickname': nickname,
        'faceURL': faceURL,
      });

  void toggleCheckedStatus(dynamic info) {
    /*if (!selectContactsLogic.isMultiModel())*/ Get.back();
    selectContactsLogic.selectedContacts(_convertContactsInfo(
      userID: info.userID!,
      nickname: info.nickname,
      faceURL: info.faceURL,
    ));
  }

  void toggleGroupCheckedStatus(GroupInfo info) {
    Get.back();
    selectContactsLogic.selectedGroup(info);
  }
}
