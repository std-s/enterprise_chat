import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../organization_logic.dart';

class SearchOrganizationLogic extends GetxController {
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final refreshCtrl = RefreshController();
  final deptList = <DeptInfo>[].obs;
  final memberList = <DeptMemberInfo>[].obs;
  var count = 40;
  late bool isMultiModel;
  final organizationLogic = Get.find<OrganizationLogic>();

  @override
  onInit() {
    isMultiModel = Get.arguments['isMultiModel'];
    super.onInit();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void search() async {
    if (searchCtrl.text.trim().isEmpty) {
      return;
    }
    var result = await LoadingView.singleton.wrap(
      asyncFunction: () => _search(0),
    );
    // deptList.assignAll(result.departmentList ?? []);
    memberList.assignAll(result.departmentMemberList ?? []);
  }

  void load() async {
    var result = await _search(memberList.length);
    memberList.addAll(result.departmentMemberList ?? []);
  }

  _search(int offset) async {
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
    memberList.clear();
    focusNode.requestFocus();
  }

  bool get isNotResult =>
      searchCtrl.text.trim().isNotEmpty && memberList.isEmpty;

  void viewMemberInfo(DeptMemberInfo info) {
    if (isMultiModel) {
      organizationLogic.toggleDeptMember(info);
      Get.back();
      return;
    } else {
      AppNavigator.startFriendInfo(
        userInfo: UserInfo(
          userID: info.userID,
          nickname: info.nickname,
          faceURL: info.faceURL,
        ),
      );
    }
  }

  bool isChecked(DeptMemberInfo info) =>
      organizationLogic.checkedList.contains(info);
}
