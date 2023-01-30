import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/image_button.dart';
import 'package:openim_enterprise_chat/src/widgets/switch_button.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:sprintf/sprintf.dart';

import 'group_setup_logic.dart';

class GroupSetupPage extends StatelessWidget {
  final logic = Get.find<GroupSetupLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageStyle.c_F6F6F6,
      appBar: EnterpriseTitleBar.back(),
      body: SafeArea(
        child: Obx(() => SingleChildScrollView(
              child: Column(
                children: [
                  _buildGroupInfoView(),
                  _buildGroupMemberView(),
                  _buildItemView(
                    label: StrRes.groupName,
                    value: logic.groupInfo.value.groupName,
                    showArrow: true,
                    onTap: () => logic.modifyGroupName(),
                    margin: EdgeInsets.only(top: 12.h),
                  ),
                  _buildItemView(
                    label: StrRes.groupAnnouncement,
                    showArrow: true,
                    onTap: () => logic.editGroupAnnouncement(),
                  ),
                  if (logic.isMyGroup())
                    _buildItemView(
                      label: StrRes.groupPermissionTransfer,
                      showArrow: true,
                      onTap: () => logic.transferGroup(),
                    ),
                  _buildItemView(
                    label: StrRes.myNicknameInGroup,
                    showArrow: true,
                    value: logic.myGroupNickname.value,
                    onTap: () => logic.modifyMyGroupNickname(),
                  ),
                  _buildItemView(
                    label: StrRes.groupQrcode,
                    showArrow: true,
                    showQrcodeIcon: true,
                    onTap: () => logic.viewGroupQrcode(),
                    margin: EdgeInsets.only(top: 12.h),
                  ),
                  _buildItemView(
                    label: StrRes.groupIDCode,
                    showArrow: true,
                    onTap: () => logic.copyGroupID(),
                    margin: EdgeInsets.only(top: 12.h, bottom: 12.h),
                  ),
                  if (logic.hasGroupPermission())
                    _buildItemView(
                      label: StrRes.mutedGroup,
                      showSwitchBtn: true,
                      on: logic.groupInfo.value.status == 3,
                      onClickSwitchBtn: logic.toggleGroupMute,
                      margin: EdgeInsets.only(bottom: 12.h),
                    ),
                  if (logic.hasGroupPermission())
                    _buildItemView(
                      label: StrRes.joinGroupSet,
                      showArrow: true,
                      onTap: logic.modifyJoinGroupSet,
                      value: logic.getJoinGroupOption(),
                    ),
                  if (logic.hasGroupPermission())
                    _buildItemView(
                      label: StrRes.groupMemberPermissions,
                      showArrow: true,
                      onTap: logic.groupMemberPermissionSet,
                      margin: EdgeInsets.only(bottom: 12.h),
                    ),

                  _buildItemView(
                    label: StrRes.seeChatHistory,
                    showArrow: true,
                    onTap: logic.searchHistoryMessage,
                  ),
                  _buildItemView(
                    label: StrRes.notDisturb,
                    showSwitchBtn: true,
                    on: logic.noDisturb.value,
                    onClickSwitchBtn: logic.toggleNotDisturb,
                  ),
                  if (logic.noDisturb.value)
                    _buildItemView(
                      label: StrRes.groupMessageSettings,
                      showArrow: true,
                      value: logic.noDisturbIndex.value == 0
                          ? StrRes.receiveMessageButNotPrompt
                          : StrRes.blockGroupMessages,
                      onTap: logic.noDisturbSetting,
                    ),
                  _buildItemView(
                    label: StrRes.chatTop,
                    showSwitchBtn: true,
                    on: logic.topContacts.value,
                    onClickSwitchBtn: () => logic.toggleTopContacts(),
                  ),
                  _buildItemView(
                    label: StrRes.clearHistory,
                    showArrow: true,
                    onTap: () => logic.clearChatHistory(),
                    margin: EdgeInsets.only(bottom: 12.h),
                  ),
                  _buildItemView(
                    label: StrRes.groupType,
                    showArrow: false,
                    value: logic.getGroupType(),
                  ),
                  // _buildItemView(
                  //   label: StrRes.complaint,
                  //   showArrow: true,
                  //   onTap: () {},
                  //   margin: EdgeInsets.only(top: 12.h),
                  // ),
                  _buildButton(
                    margin: EdgeInsets.only(top: 52.h, bottom: 20.h),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildGroupInfoView() => Container(
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
        color: PageStyle.c_FFFFFF,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: logic.hasGroupPermission()
                  ? () => logic.modifyAvatar()
                  : null,
              child: Container(
                width: 48.h,
                height: 48.h,
                child: Stack(
                  children: [
                    if (logic.groupInfo.value.faceURL != null &&
                        logic.groupInfo.value.faceURL!.isNotEmpty)
                      AvatarView(
                        size: 48.h,
                        url: logic.groupInfo.value.faceURL,
                      ),
                    if (logic.groupInfo.value.faceURL == null ||
                        logic.groupInfo.value.faceURL!.isEmpty)
                      ImageButton(
                        imgStrRes: ImageRes.ic_uploadPhoto,
                        imgWidth: 48.h,
                        imgHeight: 48.h,
                      ),
                    Visibility(
                      visible: logic.hasGroupPermission(),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: PageStyle.c_1D6BED,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: PageStyle.c_FFFFFF,
                            size: 10.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 20.w,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 140.w),
              child: Text(
                logic.groupInfo.value.groupName!,
                style: PageStyle.ts_333333_18sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '（${logic.groupInfo.value.memberCount}）',
              style: PageStyle.ts_333333_18sp,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      );

  Widget _buildGroupMemberView() => Ink(
        height: 94.h,
        color: PageStyle.c_FFFFFF,
        // decoration: BoxDecoration(
        //   color: PageStyle.c_FFFFFF,
        //   boxShadow: [
        //     BoxShadow(
        //       color: PageStyle.c_000000_opacity10p,
        //       blurRadius: 4,
        //       offset: Offset(0, 2.h),
        //     ),
        //   ],
        // ),
        child: InkWell(
          onTap: () => logic.viewGroupMembers(),
          child: Container(
            padding: EdgeInsets.only(
              left: 22.w,
              right: 22.w,
              top: 14.h,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      StrRes.groupMember,
                      style: PageStyle.ts_999999_14sp,
                    ),
                    Spacer(),
                    Text(
                      sprintf(
                        StrRes.xPerson,
                        [logic.groupInfo.value.memberCount],
                      ),
                      style: PageStyle.ts_999999_14sp,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Image.asset(
                      ImageRes.ic_next,
                      width: 8.w,
                      height: 14.h,
                    ),
                  ],
                ),
                Expanded(
                  child: Obx(
                    () => GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: logic.length(),
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 13.w,
                        mainAxisSpacing: 14.h,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (_, index) {
                        return logic.itemBuilder(
                          index: index,
                          builder: (info) => Center(
                            child: AvatarView(
                              size: 36.h,
                              url: info.faceURL,
                              text: info.nickname,
                              textStyle: PageStyle.ts_FFFFFF_12sp,
                            ),
                          ),
                          addButton: () => Center(
                            child: GestureDetector(
                              onTap: logic.addMember,
                              child: Image.asset(
                                ImageRes.ic_memberAdd,
                                width: 36.h,
                                height: 36.h,
                              ),
                            ),
                          ),
                          delButton: () => GestureDetector(
                            onTap: logic.removeMember,
                            child: Center(
                              child: Image.asset(
                                ImageRes.ic_memberDel,
                                width: 36.h,
                                height: 36.h,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildItemView({
    required String label,
    String? value,
    Function()? onTap,
    Function()? onClickSwitchBtn,
    bool on = true,
    bool showQrcodeIcon = false,
    bool showArrow = false,
    bool showSwitchBtn = false,
    EdgeInsetsGeometry? margin,
  }) =>
      Container(
        margin: margin,
        child: Ink(
          height: 50.h,
          decoration: BoxDecoration(
            color: PageStyle.c_FFFFFF,
            border: BorderDirectional(
              bottom: BorderSide(
                color: PageStyle.c_999999_opacity40p,
                width: 0.5,
              ),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: Row(
                children: [
                  Text(
                    label,
                    style: PageStyle.ts_333333_16sp,
                  ),
                  Spacer(),
                  if (null != value)
                    Container(
                      constraints: BoxConstraints(maxWidth: 180.w),
                      child: Text(
                        value,
                        style: PageStyle.ts_999999_14sp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (showQrcodeIcon)
                    Image.asset(
                      ImageRes.ic_mineQrCode,
                      width: 18.w,
                      height: 18.h,
                      color: PageStyle.c_999999,
                    ),
                  if (showArrow)
                    Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: Image.asset(
                        ImageRes.ic_next,
                        width: 10.w,
                        height: 17.h,
                        color: PageStyle.c_999999,
                      ),
                    ),
                  if (showSwitchBtn)
                    SwitchButton(
                      onTap: onClickSwitchBtn,
                      on: on,
                    )
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildButton({EdgeInsetsGeometry? margin}) => Container(
        margin: margin,
        child: Ink(
          color: PageStyle.c_FFFFFF,
          height: 45.h,
          child: InkWell(
            onTap: () => logic.quitGroup(),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                logic.isMyGroup() ? StrRes.dismissGroup : StrRes.quitGroup,
                style: PageStyle.ts_F85050_18sp,
              ),
            ),
          ),
        ),
      );
}
