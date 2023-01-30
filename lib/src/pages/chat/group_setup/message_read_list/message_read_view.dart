import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'message_read_logic.dart';

class GroupMessageReadListPage extends StatelessWidget {
  final logic = Get.find<GroupMessageReadListLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: StrRes.messageReadStatus,
      ),
      backgroundColor: PageStyle.c_F8F8F8,
      body: Obx(() => Column(
            children: [
              _TabLayoutView(
                logic.index.value,
                readCount: logic.hasReadCount,
                unreadCount: logic.unreadCount,
                onChanged: logic.switchTab,
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: IndexedStack(
                  index: logic.index.value,
                  children: [
                    SmartRefresher(
                      controller: logic.hasReadRefreshController,
                      enablePullDown: false,
                      enablePullUp: true,
                      footer: IMWidget.buildFooter(),
                      onLoading: logic.loadHasReadMemberList,
                      child: ListView.builder(
                        itemCount: logic.hasReadMemberList.length,
                        itemBuilder: (_, index) => _buildItemView(
                          logic.hasReadMemberList.elementAt(index),
                        ),
                      ),
                    ),
                    SmartRefresher(
                      controller: logic.unreadRefreshController,
                      enablePullDown: false,
                      enablePullUp: true,
                      footer: IMWidget.buildFooter(),
                      onLoading: logic.loadUnreadMemberList,
                      child: ListView.builder(
                        itemCount: logic.unreadMemberList.length,
                        itemBuilder: (_, index) => _buildItemView(
                          logic.unreadMemberList.elementAt(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildItemView(GroupMembersInfo info, {String? status}) => Container(
        height: 72.h,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        color: PageStyle.c_FFFFFF,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvatarView(
              size: 42.h,
              url: info.faceURL,
              text: info.nickname,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(
                      color: PageStyle.c_F1F1F1,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      info.nickname!,
                      style: PageStyle.ts_333333_16sp,
                    ),
                    if (status != null)
                      Text(
                        status,
                        style: PageStyle.ts_999999_12sp,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _TabLayoutView extends StatelessWidget {
  const _TabLayoutView(
    this.index, {
    Key? key,
    this.readCount = 0,
    this.unreadCount = 0,
    this.onChanged,
  }) : super(key: key);
  final int index;
  final int readCount;
  final int unreadCount;
  final Function(int index)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.h),
      color: PageStyle.c_FFFFFF,
      // height: 65.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabView(
            0,
            index == 0,
            count: readCount,
            onTap: () => onChanged?.call(0),
          ),
          _buildTabView(
            1,
            index == 1,
            count: unreadCount,
            onTap: () => onChanged?.call(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView(
    int index,
    bool selected, {
    required int count,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                text: index == 0 ? StrRes.haveRead : StrRes.unread,
                style: PageStyle.ts_333333_16sp,
                children: [
                  WidgetSpan(
                    child: SizedBox(
                      width: 10.w,
                    ),
                  ),
                  TextSpan(
                    text: '$count',
                    style: PageStyle.ts_1D6BED_16sp,
                  )
                ],
              ),
            ),
            Container(
              width: 34.w,
              height: 3.h,
              margin: EdgeInsets.only(top: 13.h),
              color: selected ? PageStyle.c_1D6BED : PageStyle.c_FFFFFF,
            )
          ],
        ),
      );
}
