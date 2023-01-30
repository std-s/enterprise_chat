import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/pages/contacts/friend_info/friend_info_logic.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import '../../../../res/images.dart';
import '../../../../res/strings.dart';
import '../../../../widgets/switch_button.dart';

class SetFriendInfoPage extends StatelessWidget {
  final logic = Get.find<FriendInfoLogic>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: EnterpriseTitleBar.back(),
        backgroundColor: PageStyle.c_F6F6F6,
        body: Column(
          children: [
            SizedBox(
              height: 12.h,
            ),
            _buildItemView(
              label: StrRes.remark,
              onTap: () => logic.toSetupRemark(),
              showArrowBtn: true,
            ),
            // _buildItemView(
            //   label: StrRes.moreInfo,
            //   onTap: () => logic.viewPersonalInfo(),
            //   showArrowBtn: true,
            // ),
            SizedBox(
              height: 12.h,
            ),
            _buildItemView(
              label: StrRes.recommendToFriends,
              onTap: () => logic.recommendFriend(),
              showArrowBtn: true,
            ),
            SizedBox(
              height: 12.h,
            ),
            // if (logic.showMuteFunction.value)
            //   _buildItemView(
            //     label: StrRes.setMute,
            //     value: logic.mutedTime.isEmpty ? null : logic.mutedTime.value,
            //     onTap: () => logic.setMute(),
            //     showArrowBtn: true,
            //     showLine: true,
            //   ),
            _buildItemView(
              label: StrRes.addBlacklist,
              showSwitchBtn: true,
              switchOn: logic.userInfo.value.isBlacklist == true,
              onTap: () => logic.toggleBlacklist(),
            ),
            SizedBox(
              height: 12.h,
            ),
            _buildItemView(
              label: StrRes.relieveRelationship,
              alignment: Alignment.center,
              style: PageStyle.ts_D9350D_18sp,
              onTap: () => logic.deleteFromFriendList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemView({
    required String label,
    String? value,
    TextStyle? style,
    AlignmentGeometry alignment = Alignment.centerLeft,
    Function()? onTap,
    bool showArrowBtn = false,
    bool showSwitchBtn = false,
    bool switchOn = false,
    bool showLine = false,
    EdgeInsetsGeometry? margin,
    Widget? child,
  }) =>
      Container(
        margin: margin,
        child: Ink(
          color: PageStyle.c_FFFFFF,
          height: 55.h,
          child: InkWell(
            onTap: showSwitchBtn ? null : onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              decoration: showLine
                  ? BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(
                          width: .5,
                          color: PageStyle.c_999999_opacity40p,
                        ),
                      ),
                    )
                  : null,
              alignment: alignment,
              child: child ??
                  (showArrowBtn || showSwitchBtn
                      ? Row(
                          children: [
                            Text(
                              label,
                              style: style ?? PageStyle.ts_333333_18sp,
                            ),
                            Spacer(),
                            if (null != value)
                              Text(
                                value,
                                style: style ?? PageStyle.ts_1B61D6_16sp,
                              ),
                            SizedBox(
                              width: 5.w,
                            ),
                            if (showArrowBtn)
                              Image.asset(
                                ImageRes.ic_next,
                                width: 7.w,
                                height: 13.h,
                              ),
                            if (showSwitchBtn)
                              SwitchButton(
                                width: 51.w,
                                height: 31.h,
                                on: switchOn,
                                onTap: onTap,
                              ),
                          ],
                        )
                      : Text(
                          label,
                          style: style ?? PageStyle.ts_333333_18sp,
                        )),
            ),
          ),
        ),
      );

  Widget _buildLine() => Container(
        height: 0.5,
        color: PageStyle.c_999999_opacity40p,
      );
}
