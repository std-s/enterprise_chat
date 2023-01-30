import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatDemoLogic extends GetxController {
  final topList = <String>[].obs;
  final bottomList = <String>[].obs;
  final controller = ScrollController();
  final focusNode = FocusNode();
  final textCtrl = TextEditingController();

  /// 加载历史消息
  Future<bool> onScrollDownLoad() async {
    await Future.delayed(Duration(seconds: 1));
    for (var i = 0; i < 20; i++) {
      bottomList.add("bottom: ${bottomList.length}");
    }
    return true;
  }

  /// 加载新消息
  Future<bool> onScrollUpLoad() async {
    await Future.delayed(Duration(seconds: 1));
    for (var i = 0; i < 20; i++) {
      topList.add("top: ${topList.length}");
    }
    return true;
  }

  void sendMsg() {
    topList.add(textCtrl.text);
    textCtrl.clear();

    jumpToBottom();
  }

  void jumpToBottom() {
    Future.delayed(Duration(seconds: 0), () async {
      print('-------minScrollExtent--${controller.position.minScrollExtent}');
      print('-------pixels--${controller.position.pixels}');
      // controller.jumpTo(controller.position.maxScrollExtent);
      print('=============hasClients===1=${controller.hasClients}');
      // while (controller.position.pixels != controller.position.minScrollExtent) {
      //   print('================滚动===');
      //   controller.jumpTo(controller.position.minScrollExtent);
      //   await SchedulerBinding.instance!.endOfFrame;
      // }
      print('=============hasClients=2===${controller.hasClients}');
    });
  }

  @override
  void onInit() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        jumpToBottom();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    controller.dispose();
    focusNode.dispose();
    textCtrl.dispose();
    super.onClose();
  }
}
