import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../core/controller/im_controller.dart';

class OANotificationLogic extends GetxController {
  late ConversationInfo info;
  var messageList = <Message>[].obs;
  final pageSize = 40;
  final refreshController = RefreshController(initialRefresh: false);
  final imLogic = Get.find<IMController>();

  @override
  void onInit() {
    info = Get.arguments;
    // 新增消息监听
    imLogic.onRecvNewMessage = (Message message) {
      if (message.contentType == MessageType.oaNotification) {
        if (!messageList.contains(message)) messageList.add(message);
      }
    };
    super.onInit();
  }

  @override
  void onReady() {
    loadNotification();
    super.onReady();
  }

  /// 3
  /// 2
  /// 1
  /// 0
  void loadNotification() async {
    final list = await OpenIM.iMManager.messageManager.getHistoryMessageList(
      conversationID: info.conversationID,
      count: pageSize,
      startMsg: messageList.firstOrNull,
    );
    messageList.insertAll(0, list);
    // if (list.isNotEmpty) {
    //   messageList.addAll(list);
    // }
    if (list.length < pageSize) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
  }

  OANotification parse(Message message) =>
      OANotification.fromJson(json.decode(message.notificationElem!.detail!));

  Size calSize(OANotification oa, double w, double h) {
    final width = 50.w;
    // final width = message.videoElem?.snapshotWidth?.toDouble();
    // final height = message.videoElem?.snapshotHeight?.toDouble();
    final height = width * h / w;
    print('----${oa.videoElem?.snapshotWidth}---width:$width');
    print('----${oa.videoElem?.snapshotHeight}---height:$height');
    return Size(width, height);
  }

  void jump(OANotification oa) {}
}
