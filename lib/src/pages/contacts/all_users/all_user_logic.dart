import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/common/apis.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';

import '../../../routes/app_navigator.dart';

class AllUsersLogic extends GetxController {
  var onlineStatus = <String, String>{}.obs;
  var userList = <UserInfo>[].obs;

  @override
  void onInit() {
    Apis.queryAllUsers().then((list) {
      if (list != null && list.isNotEmpty) {
        OpenIM.iMManager.userManager.getUsersInfo(uidList: list).then((list) {
          userList.addAll(list);
          if (onlineStatus.isNotEmpty) {
            _sort();
          }
        });
        Apis.queryOnlineStatus(
          uidList: list,
          onlineStatusDescCallback: (map) {
            onlineStatus.addAll(map);
            if (userList.isNotEmpty) {
              _sort();
            }
          },
        );
      }
    });
    super.onInit();
  }

  void _sort() {
    userList.sort((a, b) {
      var aOnline = isOnline(a);
      var bOnline = isOnline(b);
      if (aOnline && !bOnline)
        return -1;
      else if (!aOnline && bOnline)
        return 1;
      else
        return 0;
    });
  }

  void viewUserInfo(UserInfo info) {
    AppNavigator.startFriendInfo(userInfo: info);
  }

  bool isOnline(UserInfo info) {
    return onlineStatus[info.userID] != StrRes.offline;
  }
}
