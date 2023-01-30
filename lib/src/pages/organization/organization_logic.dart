import 'package:collection/collection.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/pages/home/home_logic.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

class OrganizationLogic extends GetxController {
  final homeLogic = Get.find<HomeLogic>();
  final deptTreeList = <DeptInfo>[].obs;
  final subDeptList = <DeptInfo>[].obs;
  final deptMemberList = <DeptMemberInfo>[].obs;
  final checkedList = <DeptMemberInfo>[].obs;
  late bool isMultiModel;
  DeptInfo? startNode;
  late DeptInfo topNode;

  @override
  void onInit() {
    topNode = DeptInfo(
      departmentID: homeLogic.organizationID,
      name: homeLogic.organizationName,
    );
    isMultiModel = Get.arguments['isMultiModel'];
    startNode = Get.arguments['deptInfo'];
    checkedList.addAll(Get.arguments['checkedList']);
    // 顶节点
    deptTreeList.add(topNode);
    if (null != startNode) {
      deptTreeList.add(startNode!);
    }
    super.onInit();
  }

  @override
  void onReady() {
    loadSubDeptAndMemberList(isExpandFromChildNode: startNode != null);
    super.onReady();
  }

  void loadSubDeptAndMemberList({bool isExpandFromChildNode = false}) async {
    var currentDept = deptTreeList.lastOrNull;
    if (currentDept == null) return;
    var list = await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.organizationManager
            .getDeptMemberAndSubDept(departmentID: currentDept.departmentID!));
    subDeptList.assignAll(list.departmentList ?? []);
    deptMemberList.assignAll(list.departmentMemberList ?? []);
    if (isExpandFromChildNode) {
      deptTreeList.assignAll(list.parentDepartmentList ?? []);
    }
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
    if (isMultiModel) {
      if (checkedList.contains(info)) {
        checkedList.remove(info);
      } else {
        checkedList.add(info);
      }
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

  void confirmSelected() {
    Get.back(result: checkedList.value);
  }

  void toSearch() {
    AppNavigator.startSearchOrganization(isMultiModel: isMultiModel);
  }
}
