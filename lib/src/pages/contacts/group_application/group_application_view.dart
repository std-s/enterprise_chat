import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import 'group_application_logic.dart';

class GroupApplicationPage extends StatelessWidget {
  final logic = Get.find<GroupApplicationLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: StrRes.groupApplicationNotification,
        showShadow: false,
      ),
      backgroundColor: PageStyle.c_F8F8F8,
      body: SafeArea(
        child: Obx(() => ListView.builder(
              itemCount: logic.list.length,
              itemBuilder: (_, index) {
                final info = logic.list.elementAt(index);
                if (info.joinSource == 2) {
                  return Obx(() => _buildInviteItemView(
                        logic.getMemberInfo(info.inviterUserID!),
                        logic.getUserInfo(info.inviterUserID!),
                        info,
                      ));
                }
                return _buildItemView(info);
              },
            )),
      ),
    );
  }

  Widget _buildItemView(GroupApplicationInfo info) => Column(
        children: [
          Container(
            color: PageStyle.c_FFFFFF,
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarView(
                  url: info.userFaceURL,
                  text: info.nickname,
                ),
                SizedBox(
                  width: 18.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.nickname!,
                        style: PageStyle.ts_333333_16sp,
                      ),
                      RichText(
                        text: TextSpan(
                          text: StrRes.applyJoin,
                          style: PageStyle.ts_666666_12sp,
                          children: [
                            WidgetSpan(
                              child: SizedBox(width: 2.w),
                            ),
                            TextSpan(
                              text: logic.getGroupName(info.groupID),
                              style: PageStyle.ts_418AE5_12sp,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 14.h,
                      ),
                      Text(
                        StrRes.applyReason,
                        style: PageStyle.ts_666666_12sp,
                      ),
                      Text(
                        info.reqMsg!,
                        style: PageStyle.ts_666666_12sp,
                      ),
                    ],
                  ),
                ),
                if (info.handleResult == 0)
                  GestureDetector(
                    onTap: () => logic.handle(info),
                    child: Container(
                      height: 22.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: PageStyle.c_418AE5,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        StrRes.toBeProcessed,
                        style: PageStyle.ts_418AE5_12sp,
                      ),
                    ),
                  ),
                if (info.handleResult == 1)
                  Text(
                    StrRes.approved,
                    style: PageStyle.ts_898989_12sp,
                  ),
                if (info.handleResult == -1)
                  Text(
                    StrRes.rejected,
                    style: PageStyle.ts_898989_12sp,
                  )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 82.w, right: 22.w),
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(
                  color: PageStyle.c_F1F1F1,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildInviteItemView(
    GroupMembersInfo? membersInfo,
    UserInfo? userInfo,
    GroupApplicationInfo applyInfo,
  ) =>
      Column(
        children: [
          Container(
            color: PageStyle.c_FFFFFF,
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarView(
                  url: membersInfo?.faceURL ?? userInfo?.faceURL,
                  text: membersInfo?.nickname ?? userInfo?.nickname,
                ),
                SizedBox(
                  width: 18.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        membersInfo?.nickname ?? userInfo?.nickname ?? '',
                        style: PageStyle.ts_333333_16sp,
                      ),
                      RichText(
                        text: TextSpan(
                          text: StrRes.invite,
                          style: PageStyle.ts_666666_12sp,
                          children: [
                            WidgetSpan(
                              child: SizedBox(width: 2.w),
                            ),
                            TextSpan(
                              text: applyInfo.nickname,
                              style: PageStyle.ts_418AE5_12sp,
                            ),
                            WidgetSpan(
                              child: SizedBox(width: 2.w),
                            ),
                            TextSpan(
                              text: StrRes.joinIn,
                              style: PageStyle.ts_666666_12sp,
                            ),
                            WidgetSpan(
                              child: SizedBox(width: 2.w),
                            ),
                            TextSpan(
                              text: logic.getGroupName(applyInfo.groupID),
                              style: PageStyle.ts_418AE5_12sp,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 14.h,
                      ),
                      Text(
                        StrRes.applyReason,
                        style: PageStyle.ts_666666_12sp,
                      ),
                      Text(
                        applyInfo.reqMsg!,
                        style: PageStyle.ts_666666_12sp,
                      ),
                    ],
                  ),
                ),
                if (applyInfo.handleResult == 0)
                  GestureDetector(
                    onTap: () => logic.handle(applyInfo),
                    child: Container(
                      height: 22.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: PageStyle.c_418AE5,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        StrRes.toBeProcessed,
                        style: PageStyle.ts_418AE5_12sp,
                      ),
                    ),
                  ),
                if (applyInfo.handleResult == 1)
                  Text(
                    StrRes.approved,
                    style: PageStyle.ts_898989_12sp,
                  ),
                if (applyInfo.handleResult == -1)
                  Text(
                    StrRes.rejected,
                    style: PageStyle.ts_898989_12sp,
                  )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 82.w, right: 22.w),
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(
                  color: PageStyle.c_F1F1F1,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      );
}
