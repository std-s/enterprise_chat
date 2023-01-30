import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';

import '../../../res/styles.dart';
import '../../../widgets/bottom_sheet_view.dart';

class AddContactsLogic extends GetxController {
  void joinGroup() {
    AppNavigator.startJoinGroup();
    // Get.toNamed(AppRoutes.JOIN_GROUP);
  }

  void toSearchPage() {
    AppNavigator.startAddFriendBySearch();
    // Get.toNamed(AppRoutes.ADD_FRIEND_BY_SEARCH);
  }

  void toScanQrcode() {
    AppNavigator.startScanQrcode();
  }

  void crateGroup() {
    Get.bottomSheet(
      BottomSheetView(
        itemBgColor: PageStyle.c_FFFFFF,
        items: [
          SheetItem(
            label: StrRes.generalGroup,
            onTap: () => AppNavigator.createGroup(),
          ),
          SheetItem(
            label: StrRes.workGroup,
            onTap: () => AppNavigator.createGroup(groupType: GroupType.work),
          ),
        ],
      ),
    );
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
}
