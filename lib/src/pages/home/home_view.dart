import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/main.dart';
import 'package:openim_enterprise_chat/src/pages/contacts/contacts_view.dart';
import 'package:openim_enterprise_chat/src/pages/conversation/conversation_view.dart';
import 'package:openim_enterprise_chat/src/pages/mine/mine_view.dart';
import 'package:openim_enterprise_chat/src/pages/workbench/workbench_view.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/bottombar.dart';

import 'home_logic.dart';

class HomePage extends StatelessWidget {
  final logic = Get.find<HomeLogic>();

  @override
  Widget build(BuildContext context) {
    AliveHelp.setMethodCallHandler((call) async {
      if (call.method == "isHomeRoute") {
        var modalRoute = ModalRoute.of(context);
        if (null != modalRoute) {
          if (modalRoute.isFirst && modalRoute.isCurrent) {
            return true;
          }
        }
      }
    });
    return Obx(() => Scaffold(
          backgroundColor: PageStyle.c_FFFFFF,
          body: IndexedStack(
            index: logic.index.value,
            children: [
              ConversationPage(),
              ContactsPage(),
              WorkbenchPage(),
              MinePage(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: BottomBar(
              index: logic.index.value,
              items: [
                BottomBarItem(
                  selectedImgRes: ImageRes.ic_tabHomeSel,
                  unselectedImgRes: ImageRes.ic_tabHomeNor,
                  label: StrRes.home,
                  imgWidth: 24.w,
                  imgHeight: 25.h,
                  onClick: (i) => logic.switchTab(i),
                  // steam: logic.imLogic.unreadMsgCountCtrl.stream,
                  count: logic.unreadMsgCount.value,
                ),
                BottomBarItem(
                  selectedImgRes: ImageRes.ic_tabContactsSel,
                  unselectedImgRes: ImageRes.ic_tabContactsNor,
                  label: StrRes.contacts,
                  imgWidth: 22.w,
                  imgHeight: 23.h,
                  onClick: (i) => logic.switchTab(i),
                  count: logic.unhandledCount.value,
                ),
                BottomBarItem(
                  selectedImgRes: ImageRes.ic_tabWorkSel,
                  unselectedImgRes: ImageRes.ic_tabWorkNor,
                  label: StrRes.workbench,
                  imgWidth: 22.w,
                  imgHeight: 23.h,
                  onClick: (i) => logic.switchTab(i),
                  // count: logic.unhandledCount.value,
                ),
                BottomBarItem(
                  selectedImgRes: ImageRes.ic_tabMineSel,
                  unselectedImgRes: ImageRes.ic_tabMineNor,
                  label: StrRes.mine,
                  imgWidth: 22.w,
                  imgHeight: 23.h,
                  onClick: (i) => logic.switchTab(i),
                ),
              ],
            ),
          ),
        ));
  }
}
