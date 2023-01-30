import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

class GroupMemberPermissionLogic extends GetxController {
  var notAllowLookProfiles = 0.obs;
  var notAllowAddFriend = 0.obs;
  late GroupInfo groupInfo;

  /// 不允许通过群获取成员资料 0：关闭，1：打开
  void toggleMemberProfiles() async {
    final status = notAllowLookProfiles.value == 0 ? 1 : 0;
    await LoadingView.singleton.wrap(
      asyncFunction: () => OpenIM.iMManager.groupManager.setGroupLookMemberInfo(
        groupID: groupInfo.groupID,
        status: status,
      ),
    );
    notAllowLookProfiles.value = status;
  }

  /// 0：关闭，1：打开
  void toggleAddMemberToFriend() async {
    final status = notAllowAddFriend.value == 0 ? 1 : 0;
    await LoadingView.singleton.wrap(
      asyncFunction: () =>
          OpenIM.iMManager.groupManager.setGroupApplyMemberFriend(
        groupID: groupInfo.groupID,
        status: status,
      ),
    );
    notAllowAddFriend.value = status;
  }

  @override
  void onInit() {
    groupInfo = Get.arguments['info'];
    notAllowLookProfiles.value = groupInfo.lookMemberInfo ?? 0;
    notAllowAddFriend.value = groupInfo.applyMemberFriend ?? 0;
    super.onInit();
  }
}
