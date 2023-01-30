import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/common/apis.dart';
import 'package:openim_enterprise_chat/src/pages/select_contacts/select_contacts_logic.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

import '../../../../models/contacts_info.dart';

class NewTagGroupLogic extends GetxController {
  final tagList = <UserInfo>[].obs;
  final controller = TextEditingController();

  void add() async {
    var list = await AppNavigator.startSelectContacts(
      action: SelAction.CREATE_TAG,
      defaultCheckedUidList: tagList.map((e) => e.userID!).toList(),
      // checkedList:
      //     tagList.map((e) => ContactsInfo.fromJson(e.toJson())).toList(),
    );
    if (list is List) {
      list.forEach((element) {
        if (!tagList.contains(element)) {
          tagList.add(element);
        }
      });
      // tagList.addAll(list.cast());
    }
  }

  void delete(String userID) {
    tagList.removeWhere((element) => element.userID == userID);
  }

  void completed() async {
    if (controller.text.trim().isEmpty) {
      IMWidget.showToast(StrRes.plsInputTagName);
      return;
    }
    if (tagList.isEmpty) {
      IMWidget.showToast(StrRes.plsSelectTagMember);
      return;
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      await Apis.createTag(
        tagName: controller.text,
        userIDList: tagList.map((e) => e.userID!).toList(),
      );
    });
    Get.back(result: true);
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
