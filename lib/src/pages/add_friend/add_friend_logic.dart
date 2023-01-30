import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';

enum AddType {
  friend,
  group,
}

class AddFriendLogic extends GetxController {
  late AddType type;

  @override
  void onInit() {
    type = Get.arguments;
    super.onInit();
  }

  void toSearchPage() {
    if (isAddFriend) {
      AppNavigator.startAddFriendBySearch();
    } else {
      AppNavigator.startAddGroupBySearch();
    }

    // Get.toNamed(AppRoutes.ADD_FRIEND_BY_SEARCH);
  }

  void toMyQrcode() {
    AppNavigator.startMyQrcode();
    // Get.toNamed(AppRoutes.MY_QRCODE);
  }

  void toScanQrcode() {
    AppNavigator.startScanQrcode();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  bool get isAddFriend => type == AddType.friend;

  String getTitle() => isAddFriend ? StrRes.addFriend : StrRes.addGroup;
}
