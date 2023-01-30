import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

class SetMemberMuteLogic extends GetxController {
  var list = [
    StrRes.tenMinutes,
    StrRes.oneHour,
    StrRes.twelveHours,
    StrRes.oneDay,
    /* StrRes.custom,*/
  ];

  final controller = TextEditingController(text: '0');
  final focusNode = FocusNode();
  var index = 10.obs;

  late String groupID;
  late String userID;

  void checkedIndex(index) {
    /*if (index < list.length) */ this.index.value = index;
    controller.clear();
    focusNode.unfocus();
  }

  @override
  void onInit() {
    groupID = Get.arguments['groupID'];
    userID = Get.arguments['userID'];
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        index.value = 10;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    controller.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void completed() async {
    var seconds = 0;
    if (index < list.length) {
      switch (index.value) {
        case 0:
          seconds = 10 * 60;
          break;
        case 1:
          seconds = 1 * 60 * 60;
          break;
        case 2:
          seconds = 12 * 60 * 60;
          break;
        case 3:
          seconds = 24 * 60 * 60;
          break;
      }
    }
    if (controller.text.isNotEmpty) {
      var day = double.parse(controller.text);
      seconds = (day * 24 * 60 * 60).toInt();
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      await OpenIM.iMManager.groupManager.changeGroupMemberMute(
        groupID: groupID,
        userID: userID,
        seconds: seconds,
      );
    });

    Get.back();
  }
}
