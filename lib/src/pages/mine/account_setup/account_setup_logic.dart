import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/common/apis.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/utils/data_persistence.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

import '../../../widgets/custom_dialog.dart';

class AccountSetupLogic extends GetxController {
  final imLogic = Get.find<IMController>();

  // var notDisturbModel = false.obs;
  var curLanguage = "".obs;

  void toggleNotDisturbModel() async {
    // var value = !notDisturbModel.value;
    var status = isGlobalNotDisturb ? 0 : 2;
    await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.conversationManager
            .setGlobalRecvMessageOpt(status: status));
    // notDisturbModel.value = value;
    imLogic.userInfo.update((val) {
      val?.globalRecvMsgOpt = status;
    });
  }

  void setAddMyMethod() {
    AppNavigator.startAddMyMethod();
    // Get.toNamed(AppRoutes.ADD_MY_METHOD);
  }

  void blacklist() {
    AppNavigator.startBlacklist();
    // Get.toNamed(AppRoutes.BLACKLIST);
  }

  void clearChatHistory() async {
    var confirm = await Get.dialog(CustomDialog(
      title: StrRes.confirmClearChatHistory,
      rightText: StrRes.sure,
    ));
    if (confirm == true) {
      LoadingView.singleton.wrap(asyncFunction: () async {
        await OpenIM.iMManager.messageManager.deleteAllMsgFromLocalAndSvr();
      });
    }
  }

  void languageSetting() async {
    await AppNavigator.startLanguageSetup();
    updateLanguage();
  }

  void updateLanguage() {
    var index = DataPersistence.getLanguage() ?? 0;
    switch (index) {
      case 1:
        curLanguage.value = StrRes.chinese;
        break;
      case 2:
        curLanguage.value = StrRes.english;
        break;
      default:
        curLanguage.value = StrRes.followSystem;
        break;
    }
  }

  @override
  void onReady() {
    updateLanguage();
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  @override
  void onInit() {
    // notDisturbModel.value = imLogic.userInfo.value.globalRecvMsgOpt == 2;
    queryMyFullInfo();
    super.onInit();
  }

  /// 全局免打扰 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  bool get isGlobalNotDisturb => imLogic.userInfo.value.globalRecvMsgOpt == 2;

  bool get isAllowAddFriend => imLogic.userInfo.value.allowAddFriend == 1;

  bool get isAllowBeep => imLogic.userInfo.value.allowBeep == 1;

  bool get isAllowVibration => imLogic.userInfo.value.allowVibration == 1;

  void unlockVerification() {
    AppNavigator.startUnlockVerification();
  }

  void queryMyFullInfo() async {
    final data = await LoadingView.singleton.wrap(
      asyncFunction: () => Apis.queryMyFullInfo(),
    );
    if (data is Map) {
      final userInfo = UserInfo.fromJson(data.cast());
      imLogic.userInfo.update((val) {
        val?.allowAddFriend = userInfo.allowAddFriend;
        val?.allowBeep = userInfo.allowBeep;
        val?.allowVibration = userInfo.allowVibration;
      });
    }
  }

  void toggleForbidAddMeToFriend() {
    final allowAddFriend = !isAllowAddFriend ? 1 : 2;
    // 1关闭 2开启
    LoadingView.singleton.wrap(
      asyncFunction: () => Apis.updateUserInfo(
        allowAddFriend: allowAddFriend,
        userID: OpenIM.iMManager.uid,
      ).then((value) => imLogic.userInfo.update((val) {
            val?.allowAddFriend = allowAddFriend;
          })),
    );
  }

  void toggleBeep() {
    final allowBeep = !isAllowBeep ? 1 : 2;
    // 1关闭 2开启
    LoadingView.singleton.wrap(
      asyncFunction: () => Apis.updateUserInfo(
        allowBeep: allowBeep,
        userID: OpenIM.iMManager.uid,
      ).then((value) => imLogic.userInfo.update((val) {
            val?.allowBeep = allowBeep;
          })),
    );
  }

  void toggleVibration() {
    final allowVibration = !isAllowVibration ? 1 : 2;
    // 1关闭 2开启
    LoadingView.singleton.wrap(
      asyncFunction: () => Apis.updateUserInfo(
        allowVibration: allowVibration,
        userID: OpenIM.iMManager.uid,
      ).then((value) => imLogic.userInfo.update((val) {
            val?.allowVibration = allowVibration;
          })),
    );
  }
}
