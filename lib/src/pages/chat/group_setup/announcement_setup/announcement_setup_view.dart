import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import 'announcement_setup_logic.dart';

class GroupAnnouncementSetupPage extends StatelessWidget {
  final logic = Get.find<GroupAnnouncementSetupLogic>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: EnterpriseTitleBar.back(
            title: StrRes.groupAnnouncement,
            showShadow: false,
            actions: logic.showFcBtn.value
                ? [
                    if (logic.onlyRead.value) _buildEditButton(),
                    if (!logic.onlyRead.value) _buildFinishedButton(),
                  ]
                : [],
          ),
          backgroundColor: PageStyle.c_FFFFFF,
          body: logic.showFcBtn.value ? _buildBody1() : _buildBody2(),
        ));
  }

  Widget _buildEditButton() => InkWell(
        onTap: logic.editing,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            StrRes.edit,
            style: PageStyle.ts_333333_14sp,
          ),
        ),
      );

  Widget _buildFinishedButton() => Material(
        child: Ink(
          height: 30.h,
          // width: 46.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color:
                logic.enabled.value ? PageStyle.c_1B72EC : PageStyle.c_D8D8D8,
          ),
          child: InkWell(
            onTap: logic.enabled.value ? () => logic.setAnnouncement() : null,
            child: Container(
              constraints: BoxConstraints(minWidth: 46.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Center(
                child: Text(
                  StrRes.finished,
                  style: logic.enabled.value
                      ? PageStyle.ts_FFFFFF_14sp
                      : PageStyle.ts_333333_14sp,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildBody1() => Container(
        padding: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: 22.w,
        ),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                autofocus: logic.focus.value,
                readOnly: logic.onlyRead.value,
                controller: logic.inputCtrl,
                focusNode: logic.focusNode,
                style: PageStyle.ts_333333_18sp,
                expands: true,
                maxLines: null,
                minLines: null,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: StrRes.plsEditGroupAnnouncement,
                  hintStyle: PageStyle.ts_999999_18sp,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            )
          ],
        ),
      );

  Widget _buildBody2() => Column(
        children: [
          if (logic.inputCtrl.text.isNotEmpty)
            Obx(
              () => Container(
                height: 62.h,
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(
                      color: PageStyle.c_F0F0F0,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    AvatarView(
                      url: logic.faceUrl.value,
                      text: logic.nickname.value,
                    ),
                    SizedBox(
                      width: 18.w,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          logic.nickname.value,
                          style: PageStyle.ts_333333_16sp,
                        ),
                        Text(
                          DateUtil.formatDateMs(
                            (logic.groupInfo.value.notificationUpdateTime ??
                                    0) *
                                1000,
                            format: 'yyyy/MM/dd HH:mm',
                          ),
                          style: PageStyle.ts_999999_12sp,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
              child: TextField(
                autofocus: false,
                readOnly: true,
                controller: logic.inputCtrl,
                focusNode: logic.focusNode,
                style: PageStyle.ts_333333_18sp,
                expands: true,
                maxLines: null,
                minLines: null,
                decoration: InputDecoration(
                  hintText: StrRes.plsEditGroupAnnouncement,
                  hintStyle: PageStyle.ts_999999_18sp,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30.w,
                height: 1.h,
                margin: EdgeInsets.only(right: 8.w),
                color: PageStyle.c_F0F0F0,
              ),
              Text(
                StrRes.groupNoticePermissionTips,
                style: PageStyle.ts_999999_12sp,
              ),
              Container(
                width: 30.w,
                height: 1.h,
                margin: EdgeInsets.only(left: 8.w),
                color: PageStyle.c_F0F0F0,
              ),
            ],
          ),
          SizedBox(
            height: 50.h,
          ),
        ],
      );
}
