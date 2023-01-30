import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';

import 'demo_logic.dart';

class ChatDemoPage extends StatelessWidget {
  final logic = Get.find<ChatDemoLogic>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: EnterpriseTitleBar.back(),
          body: TouchCloseSoftKeyboard(
            child: Column(
              children: [
                Expanded(
                  child: CustomChatListView(
                    controller: logic.controller,
                    onScrollDownLoad: () => logic.onScrollDownLoad(),
                    onScrollUpLoad: () => logic.onScrollUpLoad(),
                    topList: logic.topList.value..toList(),
                    bottomList: logic.bottomList.value.toList(),
                    enabledScrollUpLoad: false,
                    itemBuilder: (context, index, data) {
                      return Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text('$data'),
                      );
                    },
                  ),
                ),
                Container(
                  color: Colors.grey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: logic.focusNode,
                          controller: logic.textCtrl,
                        ),
                      ),
                      TextButton(onPressed: logic.sendMsg, child: Text('发送')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
