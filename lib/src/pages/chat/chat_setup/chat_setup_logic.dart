import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/core/controller/app_controller.dart';
import 'package:openim_enterprise_chat/src/pages/chat/chat_logic.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';

import '../../../core/controller/im_controller.dart';
import '../../../res/styles.dart';
import '../../../widgets/bottom_sheet_view.dart';
import '../../../widgets/custom_dialog.dart';

class ChatSetupLogic extends GetxController {
  var topContacts = false.obs;
  var noDisturb = false.obs;
  var blockFriends = false.obs;
  var burnAfterReading = false.obs;
  final chatLogic = Get.find<ChatLogic>();
  final appLogic = Get.find<AppController>();
  final imLogic = Get.find<IMController>();
  late String uid;
  var name = ''.obs;
  String? icon;
  ConversationInfo? info;
  var noDisturbIndex = 0.obs;
  late StreamSubscription conversationChangedSub;
  late StreamSubscription friendInfoChangedSub;
  var burnDuration = 30.obs;

  void toggleTopContacts() async {
    topContacts.value = !topContacts.value;
    if (info == null) return;
    await OpenIM.iMManager.conversationManager.pinConversation(
      conversationID: info!.conversationID,
      isPinned: topContacts.value,
    );
  }

  void toggleNoDisturb() {
    noDisturb.value = !noDisturb.value;
    if (!noDisturb.value) noDisturbIndex.value = 0;
    setConversationRecvMessageOpt(status: noDisturb.value ? 2 : 0);
  }

  void toggleBlockFriends() {
    blockFriends.value = !blockFriends.value;
    chatLogic.isInBlacklist.value = blockFriends.value;
  }

  void clearChatHistory() async {
    var confirm = await Get.dialog(CustomDialog(
      title: StrRes.confirmClearChatHistory,
      rightText: StrRes.clearAll,
    ));
    if (confirm == true) {
      await OpenIM.iMManager.messageManager
          .clearC2CHistoryMessageFromLocalAndSvr(uid: uid);
      chatLogic.clearAllMessage();
      IMWidget.showToast(StrRes.clearSuccess);
    }
  }

  void toSelectGroupMember() {
    Get.bottomSheet(
      BottomSheetView(
        itemBgColor: PageStyle.c_FFFFFF,
        items: [
          SheetItem(
            label: StrRes.generalGroup,
            onTap: () => AppNavigator.createGroup(
              defaultCheckedUidList: [uid],
            ),
          ),
          SheetItem(
            label: StrRes.workGroup,
            onTap: () => AppNavigator.createGroup(
              defaultCheckedUidList: [uid],
              groupType: GroupType.work,
            ),
          ),
        ],
      ),
    );
    // AppNavigator.startSelectContacts(
    //   action: SelAction.CRATE_GROUP,
    //   defaultCheckedUidList: [uid],
    // );
  }

  @override
  void onInit() {
    uid = Get.arguments['uid'];
    name.value = Get.arguments['name'] ?? '';
    icon = Get.arguments['icon'];
    conversationChangedSub =
        imLogic.conversationChangedSubject.listen((newList) {
      for (var newValue in newList) {
        if (newValue.conversationID == info?.conversationID) {
          burnAfterReading.value = newValue.isPrivateChat!;
          burnDuration.value = newValue.burnDuration ?? 30;
          break;
        }
      }
    });
    // 好友信息变化
    friendInfoChangedSub = imLogic.friendInfoChangedSubject.listen((value) {
      if (uid == value.userID) {
        name.value = value.getShowName();
      }
    });
    super.onInit();
  }

  void getConversationInfo() async {
    info = await OpenIM.iMManager.conversationManager.getOneConversation(
      sourceID: uid,
      sessionType: ConversationType.single,
    );
    topContacts.value = info!.isPinned!;
    burnAfterReading.value = info!.isPrivateChat!;
    var status = info!.recvMsgOpt;
    noDisturb.value = status != 0;
    burnDuration.value = info!.burnDuration ?? 30;
    if (noDisturb.value) {
      noDisturbIndex.value = status == 1 ? 1 : 0;
    }
  }

  /// 消息免打扰
  /// 1: Do not receive messages, 2: Do not notify when messages are received; 0: Normal
  void setConversationRecvMessageOpt({int status = 2}) {
    LoadingView.singleton.wrap(
      asyncFunction: () =>
          OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(
        conversationIDList: ['single_$uid'],
        status: status,
      ),
    );
  }

  @override
  void onReady() {
    getConversationInfo();
    super.onReady();
  }

  @override
  void onClose() {
    conversationChangedSub.cancel();
    friendInfoChangedSub.cancel();
    super.onClose();
  }

  void noDisturbSetting() {
    IMWidget.openNoDisturbSettingSheet(
      isGroup: false,
      onTap: (index) {
        setConversationRecvMessageOpt(status: index == 0 ? 2 : 1);
        noDisturbIndex.value = index;
      },
    );
  }

  void fontSize() {
    AppNavigator.startFontSizeSetup();
  }

  void background() {
    AppNavigator.startSetChatBackground();
    /*IMWidget.openPhotoSheet(
      toUrl: false,
      crop: false,
      onData: (String path, String? url) async {
        String? value = await CommonUtil.createThumbnail(
          path: path,
          minWidth: 1.sw,
          minHeight: 1.sh,
        );
        if (null != value) chatLogic.changeBackground(value);
      },
    );*/
  }

  void searchMessage() {
    AppNavigator.startMessageSearch(info: info!);
  }

  void searchPicture() {
    AppNavigator.startSearchPicture(info: info!, type: 0);
  }

  void searchVideo() {
    AppNavigator.startSearchPicture(info: info!, type: 1);
  }

  void searchFile() {
    AppNavigator.startSearchFile(info: info!);
  }

  /// 阅后即焚
  void togglePrivateChat() {
    LoadingView.singleton.wrap(asyncFunction: () async {
      await OpenIM.iMManager.conversationManager.setOneConversationPrivateChat(
        conversationID: info!.conversationID,
        isPrivate: !burnAfterReading.value,
      );
      // burnAfterReading.value = !burnAfterReading.value;
    });
  }

  void viewUserInfo() {
    AppNavigator.startFriendInfo(
      userInfo: UserInfo(
        userID: uid,
        nickname: name.value,
        faceURL: icon,
      ),
      showMuteFunction: false,
      groupID: null,
      offAllWhenDelFriend: true,
    );
  }

  void setBurnAfterReadingDuration() async {
    if (info == null) return;
    final result = await Get.bottomSheet(
      BottomSheetView(
        items: [
          SheetItem(
            label: StrRes.thirtySeconds,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            result: 30,
          ),
          SheetItem(
            label: StrRes.fiveMinutes,
            result: 5 * 60,
          ),
          SheetItem(
            label: StrRes.oneHour,
            result: 60 * 60,
          ),
          SheetItem(
            label: StrRes.oneDay,
            result: 24 * 60 * 60,
          ),
        ],
      ),
    );
    if (result is int) {
      LoadingView.singleton.wrap(
          asyncFunction: () => OpenIM.iMManager.conversationManager
                  .setOneConversationBurnDuration(
                conversationID: info!.conversationID,
                burnDuration: result,
              ));
    }
  }

  String getBurnAfterReadingDuration() {
    int day = 1 * 24 * 60 * 60;
    int hour = 1 * 60 * 60;
    int fiveMinutes = 5 * 60;
    if (burnDuration.value == day) {
      return StrRes.oneDay;
    } else if (burnDuration.value == hour) {
      return StrRes.oneHour;
    } else if (burnDuration.value == fiveMinutes) {
      return StrRes.fiveMinutes;
    } else {
      return StrRes.thirtySeconds;
    }
  }
}
