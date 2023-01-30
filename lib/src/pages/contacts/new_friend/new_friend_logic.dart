import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';

import '../../../utils/data_persistence.dart';
import '../../../utils/im_util.dart';
import '../../home/home_logic.dart';

class NewFriendLogic extends GetxController {
  var imLogic = Get.find<IMController>();
  var homeLogic = Get.find<HomeLogic>();
  var applicationList = <FriendApplicationInfo>[].obs;
  var canSeeMore = false.obs;
  var isExpanded = false.obs;
  late StreamSubscription friendApplicationChangedSub;

  /// 获取好友申请列表
  void getFriendApplicationList() async {
    var list =
        await OpenIM.iMManager.friendshipManager.getRecvFriendApplicationList();
    // list.sort((a, b) {
    //   if (a.createTime! > b.createTime!) {
    //     return -1;
    //   } else if (a.createTime! < b.createTime!) {
    //     return 1;
    //   }
    //   return 0;
    // });
    var haveReadList = DataPersistence.getHaveReadUnHandleFriendApplication();
    haveReadList ??= <String>[];
    list.forEach((e) {
      var id = IMUtil.buildFriendApplicationID(e);
      if (!haveReadList!.contains(id)) {
        haveReadList.add(id);
      }
    });
    DataPersistence.putHaveReadUnHandleFriendApplication(haveReadList);
    applicationList.assignAll(list);
    canSeeMore.value = list.length > 4;
  }

  /// 接受好友申请
  void acceptFriendApplication(int index) async {
    var apply = applicationList.elementAt(index);
    var result = await AppNavigator.startAcceptFriendRequest(apply: apply);
    // var result = await Get.toNamed(
    //   AppRoutes.ACCEPT_FRIEND_REQUEST,
    //   arguments: apply,
    // );
    if (result is int) {
      apply.handleResult = result;
      applicationList.refresh();
    }

    /* var apply = applicationList.elementAt(index);
    OpenIM.iMManager.friendshipManager
        .acceptFriendApplication(uid: apply.uid)
        .then((_) => Fluttertoast.showToast(msg: StrRes.addSuccessfully))
        .catchError((_) => Fluttertoast.showToast(msg: StrRes.addFailed));

    await OpenIM.iMManager.friendshipManager.acceptFriendApplication(
      uid: apply.uid,
    );
    apply.flag = 1;
    applicationList.refresh();*/
  }

  /// 拒绝好友申请
  void refuseFriendApplication(int index) async {
    var apply = applicationList.elementAt(index);
    await OpenIM.iMManager.friendshipManager.refuseFriendApplication(
      uid: apply.fromUserID!,
    );
    apply.handleResult = -1;
    applicationList.refresh();
  }

  void onClickItem(int index) {
    var info = applicationList.elementAt(index);
    if (info.isWaitingHandle) {
      acceptFriendApplication(index);
    } else if (info.isAgreed) {
      //
      AppNavigator.startFriendInfo(
        userInfo: UserInfo.fromJson({
          "userID": info.fromUserID,
          "nickname": info.fromNickname,
          "faceURL": info.fromFaceURL,
        }),
      );
    }
  }

  void expandedAll() {
    isExpanded.value = true;
  }

  void toSearchPage() {
    AppNavigator.startAddFriendBySearch();
    // Get.toNamed(AppRoutes.ADD_FRIEND_BY_SEARCH);
  }

  @override
  void onInit() {
    friendApplicationChangedSub =
        imLogic.friendApplicationChangedSubject.listen((value) {
      getFriendApplicationList();
    });
    super.onInit();
  }

  @override
  void onReady() {
    getFriendApplicationList();
    super.onReady();
  }

  @override
  void onClose() {
    friendApplicationChangedSub.cancel();
    homeLogic.getUnhandledFriendApplicationCount();
    super.onClose();
  }
}
