import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';

import '../../../res/styles.dart';
import '../../../widgets/titlebar.dart';
import 'all_user_logic.dart';

class AllUsersPage extends StatelessWidget {
  final logic = Get.put<AllUsersLogic>(AllUsersLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: '注册用户',
      ),
      backgroundColor: PageStyle.c_FFFFFF,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: logic.userList.length,
                  itemBuilder: (_, i) =>
                      Obx(() => _buildItem(logic.userList.elementAt(i))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(UserInfo info) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => logic.viewUserInfo(info),
        child: Container(
          height: 55,
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Row(
            children: [
              AvatarView(
                url: info.faceURL,
              ),
              SizedBox(
                width: 10.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    info.getShowName(),
                    style: PageStyle.ts_333333_18sp,
                  ),
                  if (null != logic.onlineStatus[info.userID])
                    Text(
                      logic.onlineStatus[info.userID]!,
                      style: logic.isOnline(info)
                          ? PageStyle.ts_1D6BED_12sp
                          : PageStyle.ts_999999_12sp,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
}
