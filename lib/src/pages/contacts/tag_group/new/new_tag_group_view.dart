import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/widgets/tag_view.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';

import '../../../../res/styles.dart';
import 'new_tag_group_logic.dart';

class NewTagGroupPage extends StatelessWidget {
  final logic = Get.find<NewTagGroupLogic>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => TouchCloseSoftKeyboard(
          child: Scaffold(
            appBar: EnterpriseTitleBar.back(
              title: StrRes.newTag,
              actions: [_buildFinishButton()],
            ),
            backgroundColor: PageStyle.c_F8F8F8,
            body: Column(
              children: [
                _buildTagNameTextField(),
                _buildTagMemberView(),
              ],
            ),
          ),
        ));
  }

  Widget _buildTagMemberView() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        margin: EdgeInsets.only(left: 10.w, right: 10.w, top: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: PageStyle.c_FFFFFF,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              height: 56.h,
              child: Row(
                children: [
                  Text(
                    StrRes.tagMember,
                    style: PageStyle.ts_333333_14sp,
                  ),
                  Spacer(),
                  if (logic.tagList.isEmpty) _buildAddBtn(),
                ],
              ),
            ),
            Wrap(
              spacing: 19.w,
              runSpacing: 9.h,
              children: logic.tagList
                  .map((e) => TagView(
                        tag: e.nickname!,
                        onTap: () => logic.delete(e.userID!),
                      ))
                  .toList(),
            ),
            if (logic.tagList.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildAddBtn(type: 1),
                ],
              )
          ],
        ),
      );

  Widget _buildTagNameTextField() => Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        margin: EdgeInsets.only(left: 10.w, right: 10.w, top: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: PageStyle.c_FFFFFF,
        ),
        child: Row(
          children: [
            Text(
              StrRes.tagName,
              style: PageStyle.ts_333333_14sp,
            ),
            SizedBox(
              width: 44.w,
            ),
            Expanded(
              child: TextField(
                controller: logic.controller,
                style: PageStyle.ts_333333_14sp,
                decoration: InputDecoration(
                  hintText: StrRes.plsInputTagName,
                  hintStyle: PageStyle.ts_ADADAD_14sp,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFinishButton() => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: logic.completed,
        child: Container(
          child: Text(
            StrRes.finished,
            style: PageStyle.ts_333333_14sp,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 5.h,
          ),
        ),
      );

  Widget _buildAddBtn({int type = 0}) => GestureDetector(
        onTap: logic.add,
        child: Container(
          margin: type == 0
              ? null
              : EdgeInsets.only(top: 12.h, bottom: 19.h, right: 13.w),
          width: 51.w,
          height: 26.h,
          decoration: BoxDecoration(
            color: PageStyle.c_1D6BED,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.add,
            color: PageStyle.c_FFFFFF,
            size: 20,
          ),
        ),
      );
}
