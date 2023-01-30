import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import '../../../res/images.dart';
import '../../../res/strings.dart';
import '../../../res/styles.dart';
import '../../../widgets/avatar_view.dart';
import '../../../widgets/im_widget.dart';
import '../../../widgets/radio_button.dart';
import '../../../widgets/search_box.dart';
import '../../../widgets/titlebar.dart';
import '../../../widgets/touch_close_keyboard.dart';
import 'search_logic.dart';

class SearchSelectContactsPage extends StatelessWidget {
  final logic = Get.find<SearchSelectContactsLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.searchTitle(
        searchBox: SearchBox(
          controller: logic.searchCtrl,
          focusNode: logic.focusNode,
          enabled: true,
          autofocus: true,
          // margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 22.w),
          // margin: EdgeInsets.fromLTRB(12.w, 0, 0, 0),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          hintText: StrRes.search,
          height: 41.h,
          clearBtn: Container(
            child: Image.asset(
              ImageRes.ic_clearInput,
              color: Color(0xFF999999),
              width: 20.w,
              height: 20.w,
            ),
          ),
          onSubmitted: (v) => logic.search(),
          onCleared: logic.clear,
        ),
      ),
      body: TouchCloseSoftKeyboard(
        child: Obx(() => SmartRefresher(
              controller: logic.refreshCtrl,
              footer: IMWidget.buildFooter(),
              enablePullDown: false,
              enablePullUp: true,
              onLoading: logic.loadDeptMember,
              child: CustomScrollView(
                // shrinkWrap: true,
                slivers: [
                  if (logic.friendList.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(left: 22.w, right: 22.w),
                        color: PageStyle.c_FFFFFF,
                        child: Text(
                          StrRes.friends,
                          style: PageStyle.ts_333333_12sp,
                        ),
                      ),
                    ),
                  if (logic.friendList.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildFriendItemView(
                            logic.friendList.elementAt(index)),
                        childCount: logic.friendList.length,
                      ),
                    ),
                  if (logic.groupList.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(left: 22.w, right: 22.w),
                        color: PageStyle.c_FFFFFF,
                        child: Text(
                          StrRes.group,
                          style: PageStyle.ts_333333_12sp,
                        ),
                      ),
                    ),
                  if (logic.groupList.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildGroupItemView(
                            logic.groupList.elementAt(index)),
                        childCount: logic.groupList.length,
                      ),
                    ),
                  if (logic.deptMemberList.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(left: 22.w, right: 22.w),
                        color: PageStyle.c_FFFFFF,
                        child: Text(
                          StrRes.colleague,
                          style: PageStyle.ts_333333_12sp,
                        ),
                      ),
                    ),
                  if (logic.deptMemberList.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildDeptMemberItemView(
                            logic.deptMemberList.elementAt(index)),
                        childCount: logic.deptMemberList.length,
                      ),
                    ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildFriendItemView(FriendInfo info) => _buildInkButton(
        onTap: logic.isDefaultChecked(info)
            ? null
            : () => logic.toggleCheckedStatus(info),
        child: Row(
          children: [
            Visibility(
              visible: logic.selectContactsLogic.isMultiModel(),
              child: Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: Obx(() => RadioButton1(
                      isChecked:
                          logic.isChecked(info) || logic.isDefaultChecked(info),
                      enabled: !logic.isDefaultChecked(info),
                    )),
              ),
            ),
            AvatarView(
              url: info.faceURL,
              text: info.nickname,
              size: 42.h,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 14.w),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SearchKeywordText(
                      text: info.nickname ?? '',
                      keyText: logic.searchCtrl.text.trim(),
                      style: PageStyle.ts_333333_14sp,
                      keyStyle: PageStyle.ts_1B72EC_14sp,
                    ),
                    if (null != info.remark && info.remark!.isNotEmpty)
                      SearchKeywordText(
                        text: '${StrRes.remark}：${info.remark}',
                        keyText: logic.searchCtrl.text.trim(),
                        style: PageStyle.ts_ADADAD_10sp,
                        keyStyle: PageStyle.ts_1B72EC_10sp,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildGroupItemView(GroupInfo info) => _buildInkButton(
        onTap: () => logic.toggleGroupCheckedStatus(info),
        child: Row(
          children: [
            AvatarView(
              size: 42.h,
              isUserGroup: true,
            ),
            SizedBox(width: 10.h),
            Container(
              constraints: BoxConstraints(maxWidth: 200.w),
              child: SearchKeywordText(
                text: info.groupName ?? '',
                keyText: logic.searchCtrl.text.trim(),
                style: PageStyle.ts_333333_14sp,
                keyStyle: PageStyle.ts_1B72EC_14sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildDeptMemberItemView(DeptMemberInfo info) => _buildInkButton(
        onTap: logic.isDefaultChecked(info)
            ? null
            : () => logic.toggleCheckedStatus(info),
        child: Row(
          children: [
            Visibility(
              visible: logic.selectContactsLogic.isMultiModel(),
              child: Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: Obx(() => RadioButton1(
                      isChecked:
                          logic.isChecked(info) || logic.isDefaultChecked(info),
                      enabled: !logic.isDefaultChecked(info),
                    )),
              ),
            ),
            AvatarView(
              url: info.faceURL,
              text: info.nickname,
              size: 42.h,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 14.w),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SearchKeywordText(
                          text: info.nickname ?? '',
                          keyText: logic.searchCtrl.text.trim(),
                          style: PageStyle.ts_333333_14sp,
                          keyStyle: PageStyle.ts_1B72EC_14sp,
                        ),
                        SizedBox(
                          width: 6.w,
                        ),
                        SearchKeywordText(
                          text: info.position ?? '',
                          keyText: logic.searchCtrl.text.trim(),
                          style: PageStyle.ts_666666_12sp,
                          keyStyle: PageStyle.ts_1B72EC_12sp,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    SearchKeywordText(
                      text: info.parentDepartmentList
                              ?.map((e) => e.name ?? '')
                              .join('-') ??
                          '',
                      keyText: logic.searchCtrl.text.trim(),
                      style: PageStyle.ts_ADADAD_10sp,
                      keyStyle: PageStyle.ts_1B72EC_10sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildInkButton({
    required Widget child,
    Function()? onTap,
  }) =>
      Ink(
        color: PageStyle.c_FFFFFF,
        child: InkWell(
          onTap: onTap,
          child: Container(
            // margin: EdgeInsets.only(bottom: 40),
            // height: 62.h,
            constraints: BoxConstraints(minHeight: 62.h),
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: child,
          ),
        ),
      );
}
