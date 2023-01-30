import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

import '../search_add_group/search_add_group_logic.dart';

class ApplyEnterGroupLogic extends GetxController {
  late GroupInfo info;
  late JoinGroupMethod method;
  final controller = TextEditingController();

  @override
  void onInit() {
    info = Get.arguments['info'];
    method = Get.arguments['method'];
    super.onInit();
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  /// ByInvitation = 2
  /// By Search     = 3
  /// By QRCode     = 4
  void sendApply() {
    LoadingView.singleton
        .wrap(
            asyncFunction: () => OpenIM.iMManager.groupManager.joinGroup(
                  gid: info.groupID,
                  reason: controller.text,
                  joinSource: method == JoinGroupMethod.qrcode ? 4 : 3,
                ))
        .then((value) => IMWidget.showToast(StrRes.sendSuccessfully))
        .then((value) => Get.back())
        .catchError((e) => IMWidget.showToast(StrRes.sendFailed));
  }
}
