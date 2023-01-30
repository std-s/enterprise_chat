import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';

import 'set_member_mute_logic.dart';

class SetMemberMutePage extends StatelessWidget {
  final logic = Get.find<SetMemberMuteLogic>();

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: EnterpriseTitleBar.back(
          title: StrRes.setMute,
          actions: [_buildConfirmBtn()],
        ),
        backgroundColor: PageStyle.c_F6F6F6,
        body: Obx(
          () => Column(
            children: [
              ..._childrenWidget(),
              _buildCustomInputView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInputView() => Container(
        height: 55.h,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        color: PageStyle.c_FFFFFF,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              StrRes.custom,
              style: PageStyle.ts_333333_18sp,
            ),
            Expanded(
              child: TextField(
                controller: logic.controller,
                focusNode: logic.focusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                style: PageStyle.ts_333333_18sp,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            Text(
              StrRes.day,
              style: PageStyle.ts_333333_18sp,
            )
          ],
        ),
      );

  List<Widget> _childrenWidget() => List.generate(
        logic.list.length,
        (index) => _buildItemView(
          label: logic.list.elementAt(index),
          isChecked: logic.index.value == index,
          onTap: () => logic.checkedIndex(index),
        ),
      );

  Widget _buildItemView({
    required String label,
    Function()? onTap,
    bool isChecked = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55.h,
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          decoration: BoxDecoration(
            color: PageStyle.c_FFFFFF,
            border: BorderDirectional(
              bottom: BorderSide(
                color: PageStyle.c_999999_opacity40p,
                width: .5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: PageStyle.ts_333333_18sp,
              ),
              Spacer(),
              if (isChecked)
                Image.asset(
                  ImageRes.ic_checkedTime,
                  width: 25.h,
                  height: 25.h,
                ),
            ],
          ),
        ),
      );

  Widget _buildConfirmBtn() => GestureDetector(
        onTap: logic.completed,
        behavior: HitTestBehavior.translucent,
        child: Container(
          height: 40.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            StrRes.completed,
            style: PageStyle.ts_333333_14sp,
          ),
        ),
      );
}
