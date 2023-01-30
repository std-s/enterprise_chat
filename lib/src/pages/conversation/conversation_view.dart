import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/pages/home/home_logic.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../widgets/avatar_view.dart';
import '../../widgets/search_box.dart';
import 'conversation_logic.dart';

class ConversationPage extends StatelessWidget {
  final logic = Get.find<ConversationLogic>();
  final imLogic = Get.find<IMController>();
  final homeLogic = Get.find<HomeLogic>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TouchCloseSoftKeyboard(
        child: Scaffold(
          backgroundColor: PageStyle.c_FFFFFF,
          // resizeToAvoidBottomInset: false,
          // appBar: AppBar(),
          appBar: EnterpriseTitleBar.conversationTitle(
            title: homeLogic.organizationName,
            // subTitle: imLogic.userInfo.value.getShowName(),
            avatarUrl: imLogic.userInfo.value.faceURL,
            actions: _buildActions(),
            subTitleView: _buildSubTitleView(),
            avatarView: AvatarView(
              size: 49.h,
              url: imLogic.userInfo.value.faceURL,
              text: imLogic.userInfo.value.nickname,
              textStyle: PageStyle.ts_FFFFFF_16sp,
            ),
          ),
          body: SlidableAutoCloseBehavior(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: IMWidget.buildHeader(),
              footer: IMWidget.buildFooter(),
              controller: logic.refreshController,
              onRefresh: logic.onRefresh,
              onLoading: logic.onLoading,
              child: _buildListView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() => CustomScrollView(
        primary: false,
        controller: logic.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildConnectivityView(),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: logic.globalSearch,
                  child: SearchBox(
                    enabled: false,
                    margin: EdgeInsets.fromLTRB(22.w, 11.h, 22.w, 5.h),
                    padding: EdgeInsets.symmetric(horizontal: 13.w),
                  ),
                )
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => AutoScrollTag(
                key: ValueKey(index),
                controller: logic.scrollController,
                index: index,
                child: _buildConversationItemView(index),
                // child: FocusDetector(
                //   onVisibilityGained: () {
                //     logic.onVisibilityGained(index);
                //   },
                //   onVisibilityLost: () {
                //     logic.onVisibilityLost(index);
                //   },
                //   child: _buildConversationItemView(index),
                // ),
              ),
              childCount: logic.list.length,
            ),
          ),
        ],
      );

  Widget _buildConversationItemView(index) => ConversationItemView(
        onTap: () => logic.toChat(index),
        avatarUrl: logic.getAvatar(index),
        avatarBuilder: () => _buildCustomAvatar(index),
        title: logic.getShowName(index),
        content: logic.getMsgContent(index),
        allAtMap: logic.getAtUserMap(index),
        contentPrefix: logic.getPrefixText(index),
        timeStr: logic.getTime(index),
        unreadCount: logic.getUnreadCount(index),
        notDisturb: logic.isNotDisturb(index),
        backgroundColor:
            logic.isPinned(index) ? PageStyle.c_F3F3F3 : Colors.transparent,
        height: 70.h,
        contentWidth: 180.w,
        avatarSize: 48.h,
        underline: false,
        titleStyle: PageStyle.ts_333333_15sp,
        contentStyle: PageStyle.ts_666666_13sp,
        contentPrefixStyle: PageStyle.ts_F44038_13sp,
        timeStyle: PageStyle.ts_999999_12sp,
        extentRatio: logic.existUnreadMsg(index) ? 0.6 : 0.4,
        isUserGroup: logic.isUserGroup(index),
        slideActions: [
          if (logic.isValidConversation(index))
            SlideItemInfo(
              flex: logic.isPinned(index) ? 3 : 2,
              text: logic.isPinned(index) ? StrRes.cancelTop : StrRes.top,
              colors: pinColors,
              textStyle: PageStyle.ts_FFFFFF_16sp,
              width: 77.w,
              onTap: () => logic.pinConversation(index),
            ),
          if (logic.existUnreadMsg(index))
            SlideItemInfo(
              flex: 3,
              text: StrRes.markRead,
              colors: haveReadColors,
              textStyle: PageStyle.ts_FFFFFF_16sp,
              width: 77.w,
              onTap: () => logic.markMessageHasRead(index),
            ),
          SlideItemInfo(
            flex: 2,
            text: StrRes.remove,
            colors: deleteColors,
            textStyle: PageStyle.ts_FFFFFF_16sp,
            width: 77.w,
            onTap: () => logic.deleteConversation(index),
          ),
        ],
        patterns: <MatchPattern>[
          MatchPattern(
            type: PatternType.AT,
            style: PageStyle.ts_666666_13sp,
          ),
        ],
        // isCircleAvatar: false,
      );

  Widget _buildConnectivityView() {
    // 提示view
    Widget _buildTipsView(Widget icon, Widget tips, [Color? backgroundColor]) {
      return Container(
        height: 32.h,
        color: backgroundColor ?? Colors.red.shade50,
        margin: EdgeInsets.symmetric(horizontal: 21.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          children: [
            icon,
            SizedBox(
              width: 8.h,
            ),
            tips
          ],
        ),
      );
    }

    Widget _buildSyncView() {
      if (logic.imConnectivityStatus.value == 2) {
        return _buildTipsView(
            CupertinoActivityIndicator(
              color: PageStyle.c_2576FC,
            ),
            Text(
              StrRes.synchronizing,
              style: PageStyle.ts_2691ED_10sp,
            ),
            Colors.blue.shade50);
      } else if (logic.imConnectivityStatus.value == 4) {
        return _buildTipsView(
            Icon(
              Icons.error,
              color: Colors.red,
            ),
            Text(
              StrRes.syncFailed,
              style: PageStyle.ts_F44038_13sp,
            ));
      }

      return Container();
    }

    Widget _buildConStatusView() {
      return logic.imConnectivityStatus.value >= 1 // 有网络，已经链接成功，同步开始
          ? _buildSyncView()
          :
          //只展示连接中和链接失败
          logic.imConnectivityStatus.value == 0 // 链接中
              ? _buildTipsView(
                  CupertinoActivityIndicator(
                    color: PageStyle.c_2576FC,
                  ),
                  Text(
                    StrRes.connecting,
                    style: PageStyle.ts_2691ED_10sp,
                  ),
                  Colors.blue.shade50)
              : _buildTipsView(
                  Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  Text(
                    StrRes.connectingFailed,
                    style: PageStyle.ts_F44038_13sp,
                  ));
    }

    return Obx(() => _buildConStatusView());
  }

  List<Widget> _buildActions() => [
        TitleImageButton(
          imageStr: ImageRes.ic_callBlack,
          imageHeight: 23.h,
          imageWidth: 23.w,
          // height: 50.h,
          onTap: () => logic.toViewCallRecords(),
        ),
        PopButton(
          popCtrl: logic.popCtrl,
          menuBgColor: Color(0xFFFFFFFF),
          // barrierColor: Color(0xFF000000).withOpacity(.6),
          showArrow: false,
          menuBgShadowColor: Color(0xFF000000).withOpacity(0.16),
          menuBgShadowBlurRadius: 6.r,
          menuBgShadowSpreadRadius: 2.r,
          menuItemTextStyle: PageStyle.ts_333333_14sp,
          menuItemHeight: 44.h,
          // menuItemWidth: 130.w,
          menuItemPadding: EdgeInsets.only(left: 20.w, right: 20.w),
          menuBgRadius: 6.r,
          // menuItemIconSize: 24.h,
          menus: [
            PopMenuInfo(
              text: StrRes.scan,
              icon: ImageRes.ic_popScan,
              onTap: () => logic.toScanQrcode(),
            ),
            PopMenuInfo(
              text: StrRes.addFriend,
              icon: ImageRes.ic_popAddFriends,
              onTap: () => logic.toAddFriend(),
            ),
            PopMenuInfo(
              text: StrRes.addGroup,
              icon: ImageRes.ic_popAddGroup,
              onTap: () => logic.toAddGroup(),
            ),
            PopMenuInfo(
              text: StrRes.createGroup,
              icon: ImageRes.ic_popLaunchGroup,
              onTap: () => logic.createGroup(GroupType.general),
            ),
            PopMenuInfo(
              text: StrRes.createWorkGroup,
              icon: ImageRes.ic_workGroup,
              onTap: () => logic.createGroup(GroupType.work),
            ),
            PopMenuInfo(
              text: StrRes.launchMeeting,
              icon: ImageRes.ic_launchMeeting,
              onTap: logic.launchMeeting,
            ),
            PopMenuInfo(
              text: StrRes.joinMeeting,
              icon: ImageRes.ic_joinMeeting,
              onTap: logic.joinMeeting,
            ),
          ],
          child: TitleImageButton(
            imageStr: ImageRes.ic_addBlack,
            imageHeight: 24.h,
            imageWidth: 23.w,
            // onTap: (){},
            // onTap: onClickAddBtn,
            // height: 50.h,
          ),
        ),
      ];

  Widget _buildSubTitleView() => Row(
        children: [
          Text(
            imLogic.userInfo.value.getShowName(),
            style: PageStyle.ts_333333_18sp,
          ),
          _onlineView(),
        ],
      );

  Widget _onlineView() => Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 8.w, right: 4.w, top: 2.h),
            width: 6.h,
            height: 6.h,
            decoration: BoxDecoration(
              color: PageStyle.c_10CC64,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            StrRes.online,
            style: PageStyle.ts_333333_12sp,
          ),
        ],
      );

  /// 系统通知自定义头像
  Widget? _buildCustomAvatar(index) {
    var info = logic.list.elementAt(index);
    if (info.conversationType == ConversationType.notification) {
      return Container(
        color: PageStyle.c_5496EB,
        height: 48.h,
        width: 48.h,
        alignment: Alignment.center,
        child: FaIcon(
          FontAwesomeIcons.solidBell,
          color: PageStyle.c_FFFFFF,
        ),
      );
    } else {
      return AvatarView(
        size: 48.h,
        url: info.faceURL,
        isUserGroup: logic.isUserGroup(index),
        text: info.showName,
        textStyle: PageStyle.ts_FFFFFF_16sp,
      );
    }
    // return null;
  }
}
