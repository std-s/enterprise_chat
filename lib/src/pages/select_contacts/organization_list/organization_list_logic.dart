import 'package:collection/collection.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/models/contacts_info.dart';
import 'package:openim_enterprise_chat/src/pages/select_contacts/select_contacts_logic.dart';

import '../../../widgets/loading_view.dart';
import '../../home/home_logic.dart';

class SelectByOrganizationListLogic extends GetxController {
  final homeLogic = Get.find<HomeLogic>();
  final deptTreeList = <DeptInfo>[].obs;
  final subDeptList = <DeptInfo>[].obs;
  final deptMemberList = <DeptMemberInfo>[].obs;
  late bool isMultiModel;
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  @override
  void onInit() {
    // 当前节点以及其所有父节点
    this.deptTreeList.add(DeptInfo(
          departmentID: homeLogic.organizationID,
          name: homeLogic.organizationName,
        ));
    this.isMultiModel = selectContactsLogic.isMultiModel();
    super.onInit();
  }

  @override
  void onReady() {
    loadSubDeptAndMemberList();
    super.onReady();
  }

  void loadSubDeptAndMemberList() async {
    var currentDept = deptTreeList.lastOrNull;
    if (currentDept == null) return;
    var list = await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.organizationManager
            .getDeptMemberAndSubDept(departmentID: currentDept.departmentID!));
    selectContactsLogic.updateDefaultCheckedList(
        (list.departmentMemberList ?? []).map((e) => e.userID!).toList());
    subDeptList.assignAll(list.departmentList ?? []);
    deptMemberList.assignAll(list.departmentMemberList ?? []);
  }

  /// 打开子节点
  void openChildNode(DeptInfo curDept) {
    deptTreeList.add(curDept);
    loadSubDeptAndMemberList();
  }

  /// 打开指定节点
  void openTreeNode(int index) {
    deptTreeList..assignAll(deptTreeList.sublist(0, index + 1));
    loadSubDeptAndMemberList();
  }

  /// 回退上一级节点
  void backParentTreeNode() {
    if (deptTreeList.length - 1 == 0) {
      Get.back();
      return;
    }
    deptTreeList..assignAll(deptTreeList.sublist(0, deptTreeList.length - 1));
    loadSubDeptAndMemberList();
  }

  void toggleDeptMember(DeptMemberInfo info) {
    selectContactsLogic.selectedContacts(_convertContactsInfo(info));
    // if (isMultiModel) {
    //   if (isChecked(info)) {
    //     selectContactsLogic.checkedList.remove(_convertContactsInfo(info));
    //   } else {
    //     selectContactsLogic.checkedList.add(_convertContactsInfo(info));
    //   }
    // } else {
    //
    // }
  }

  bool isChecked(DeptMemberInfo info) {
    return selectContactsLogic.checkedList.contains(_convertContactsInfo(info));
  }

  bool isDefaultChecked(DeptMemberInfo info) {
    return selectContactsLogic.defaultCheckedUidList.contains(info.userID);
  }

  ContactsInfo _convertContactsInfo(DeptMemberInfo info) =>
      ContactsInfo.fromJson({
        'userID': info.userID,
        'nickname': info.nickname,
        'faceURL': info.faceURL,
      });
}
