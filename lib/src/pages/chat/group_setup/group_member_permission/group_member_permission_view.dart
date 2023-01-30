import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/switch_button.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import 'group_member_permission_logic.dart';

class GroupMemberPermissionPage extends StatelessWidget {
  final logic = Get.find<GroupMemberPermissionLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: StrRes.groupMemberPermissions,
      ),
      backgroundColor: PageStyle.c_F6F6F6,
      body: Obx(() => Column(
            children: [
              SizedBox(height: 12.h),
              _buildItemView(
                label: StrRes.notViewMemberProfiles,
                showUnderline: true,
                onTap: logic.toggleMemberProfiles,
                isOpen: logic.notAllowLookProfiles.value == 1,
              ),
              _buildItemView(
                label: StrRes.notAddMemberToFriend,
                onTap: logic.toggleAddMemberToFriend,
                isOpen: logic.notAllowAddFriend.value == 1,
              ),
            ],
          )),
    );
  }

  Widget _buildItemView({
    required String label,
    bool isOpen = false,
    bool showUnderline = false,
    Function()? onTap,
  }) =>
      Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        decoration: BoxDecoration(
          color: PageStyle.c_FFFFFF,
          border: showUnderline
              ? BorderDirectional(
                  bottom: BorderSide(
                    color: PageStyle.c_999999_opacity40p,
                    width: .5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: PageStyle.ts_333333_16sp,
            ),
            Spacer(),
            SwitchButton(
              on: isOpen,
              width: 38.w,
              height: 24.h,
              onTap: onTap,
            ),
          ],
        ),
      );
}
