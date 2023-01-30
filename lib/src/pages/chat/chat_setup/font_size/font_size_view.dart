import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import '../../../../widgets/fontsize_slider.dart';
import 'font_size_logic.dart';

class FontSizePage extends StatelessWidget {
  final logic = Get.find<FontSizeLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: StrRes.fontSize,
        actions: [
          _buildResetButton(),
          _buildConfirmButton(),
        ],
      ),
      backgroundColor: PageStyle.c_F6F6F6,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 42.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarView(
                  size: 42.h,
                ),
                ChatBubble(
                  constraints: BoxConstraints(minHeight: 42.h),
                  backgroundColor: PageStyle.c_F0F0F0,
                  bubbleType: BubbleType.send,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 214.w),
                    child: Obx(() => Text(
                          StrRes.previewFontSize,
                          style: PageStyle.ts_333333_14sp,
                          textScaleFactor: logic.factor.value,
                        )),
                  ),
                )
              ],
            ),
          ),
          Spacer(),
          Obx(() => FontSizeSlider(
                value: logic.factor.value,
                onChanged: logic.changed,
              )),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: logic.saveFactor,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Text(
            StrRes.sure,
            style: PageStyle.ts_333333_14sp,
          ),
        ),
      );

  Widget _buildResetButton() => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: logic.reset,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Text(
            StrRes.reset,
            style: PageStyle.ts_333333_14sp,
          ),
        ),
      );
}
