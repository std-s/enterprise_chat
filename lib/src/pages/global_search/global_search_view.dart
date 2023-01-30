import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';
import 'package:sprintf/sprintf.dart';

import '../../res/images.dart';
import '../../res/strings.dart';
import '../../widgets/search_box.dart';
import '../../widgets/titlebar.dart';
import 'global_search_logic.dart';

class GlobalSearchPage extends StatelessWidget {
  GlobalSearchPage({Key? key}) : super(key: key);
  final logic = Get.find<GlobalSearchLogic>();

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
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
        backgroundColor: PageStyle.c_F8F8F8,
        body: Obx(
          () => Column(
            children: [
              _buildTabBar(),
              // if (logic.isSearchEmpty()) _buildNoSearch(),
              // if (!logic.isSearchEmpty())
              Expanded(
                child: SmartRefresher(
                  controller: logic.refreshController,
                  enablePullDown: false,
                  enablePullUp: logic.index.value == 1,
                  footer: IMWidget.buildFooter(),
                  onLoading: () {
                    if (logic.index.value == 1) {
                      logic.loadDeptMemberList();
                    }
                  },
                  child: _childView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _childView() {
    Widget child = SizedBox();
    if (logic.isSearchEmpty()) return _buildNoSearch();
    if (logic.index.value == 0) child = _buildAllSearchResultBody();
    if (logic.index.value == 1) child = _buildContactsSearchResultBody();
    if (logic.index.value == 2) child = _buildGroupSearchResultBody();
    if (logic.index.value == 3) child = _buildChatHistorySearchResultBody();
    if (logic.index.value == 4) child = _buildFileSearchResultBody();
    return child;
  }

  Widget _buildAllSearchResultBody() => ListView(
        children: [
          if (logic.friendList.isNotEmpty)
            _buildGroupChildren(
              label: StrRes.searchFriendLabel,
              onSeeMore: () => logic.switchTab(1),
              seeMore: logic.showMoreFriends,
              margin: EdgeInsets.zero,
              children: logic.subList(logic.friendList).map((e) {
                return _buildFriendItemView(e);
              }).toList(),
            ),
          if (logic.deptMemberList.isNotEmpty)
            _buildGroupChildren(
              label: StrRes.searchDeptMemberLabel,
              seeMore: logic.showMoreDeptMember,
              onSeeMore: () => logic.switchTab(1),
              children: logic.subList(logic.deptMemberList).map((e) {
                return _buildDeptMemberItemView(e);
              }).toList(),
            ),
          if (logic.groupList.isNotEmpty)
            _buildGroupChildren(
              label: StrRes.searchGroup,
              onSeeMore: () => logic.switchTab(2),
              seeMore: logic.showMoreGroup,
              children: logic.subList(logic.groupList).map((e) {
                return _buildGroupItemView(
                  info: e,
                  showName: e.groupName!,
                );
              }).toList(),
            ),
          if (logic.textSearchResultItems.isNotEmpty)
            _buildGroupChildren(
              label: StrRes.searchChatHistory,
              onSeeMore: () => logic.switchTab(3),
              seeMore: logic.showMoreMessage,
              children: logic.subList(logic.textSearchResultItems).map((e) {
                return _buildChatHistoryItemView(
                  item: e,
                  showName: e.showName!,
                  faceURL: e.faceURL,
                  conversationType: e.conversationType!,
                  messageList: e.messageList!,
                  messageCount: e.messageCount!,
                );
              }).toList(),
            ),
          if (logic.fileMessageList.isNotEmpty)
            _buildGroupChildren(
              label: StrRes.searchFile,
              onSeeMore: () => logic.switchTab(4),
              seeMore: logic.showMoreFile,
              children: logic.subList(logic.fileMessageList).map((e) {
                return _buildFileItemView(
                  message: e,
                  fileName: e.fileElem!.fileName!,
                  showName: e.senderNickname!,
                );
              }).toList(),
            ),
        ],
      );

  Widget _buildContactsSearchResultBody() => CustomScrollView(
        // shrinkWrap: true,
        slivers: [
          if (logic.friendList.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(left: 22.w, right: 22.w, top: 12.h),
                color: PageStyle.c_FFFFFF,
                child: Text(
                  StrRes.searchFriendLabel,
                  style: PageStyle.ts_333333_12sp,
                ),
              ),
            ),
          if (logic.friendList.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildFriendItemView(logic.friendList.elementAt(index)),
                childCount: logic.friendList.length,
              ),
            ),
          if (logic.deptMemberList.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(left: 22.w, right: 22.w, top: 12.h),
                color: PageStyle.c_FFFFFF,
                child: Text(
                  StrRes.searchDeptMemberLabel,
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
      );

  // Widget _buildContactsSearchResultBody() => ListView.builder(
  //       itemCount: logic.deptMemberList.length,
  //       itemBuilder: (_, index) {
  //         final info = logic.deptMemberList.elementAt(index);
  //         return _buildDeptMemberItemView(info);
  //       },
  //     );

  Widget _buildChatHistorySearchResultBody() => ListView(
        children: logic.textSearchResultItems.map((e) {
          return _buildChatHistoryItemView(
            item: e,
            showName: e.showName!,
            faceURL: e.faceURL,
            conversationType: e.conversationType!,
            messageList: e.messageList!,
            messageCount: e.messageCount!,
          );
        }).toList(),
      );

  Widget _buildGroupSearchResultBody() => ListView(
        children: logic.groupList.map((e) {
          return _buildGroupItemView(
            info: e,
            showName: e.groupName!,
          );
        }).toList(),
      );

  Widget _buildFileSearchResultBody() => ListView(
        children: logic.fileMessageList.map((e) {
          return _buildFileItemView(
            message: e,
            fileName: e.fileElem!.fileName!,
            showName: e.senderNickname!,
          );
        }).toList(),
      );

  Widget _buildGroupChildren({
    required String label,
    required List<Widget> children,
    Function()? onSeeMore,
    EdgeInsetsGeometry? margin,
    bool seeMore = true,
  }) =>
      Container(
        color: PageStyle.c_FFFFFF,
        margin: margin ?? EdgeInsets.only(bottom: 12.h),
        child: Column(
          children: [
            GestureDetector(
              onTap: seeMore ? onSeeMore : null,
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.only(
                  left: 22.w,
                  right: 22.w,
                  top: 12.h,
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: PageStyle.ts_333333_12sp,
                    ),
                    Spacer(),
                    if (seeMore)
                      Text(
                        StrRes.seeMore,
                        style: PageStyle.ts_1B72EC_12sp,
                      ),
                  ],
                ),
              ),
            ),
            ...children,
          ],
        ),
      );

  Widget _buildChatHistoryItemView({
    required SearchResultItems item,
    required String showName,
    String? faceURL,
    required int conversationType,
    required int messageCount,
    required List<Message> messageList,
  }) =>
      _buildInkButton(
        onTap: () => logic.expandMessageGroup(item),
        child: Row(
          children: [
            AvatarView(
              size: 42.h,
              text: showName,
              url: faceURL,
              isUserGroup: conversationType == 2,
            ),
            SizedBox(width: 10.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 140.w),
                        child: Text(
                          showName,
                          style: PageStyle.ts_333333_14sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Spacer(),
                      if (messageCount > 0)
                        Text(
                          IMUtil.getCallTimeline(messageList.first.sendTime!),
                          style: PageStyle.ts_ADADAD_10sp,
                        ),
                    ],
                  ),
                  if (messageCount == 1)
                    SearchKeywordText(
                      text: logic.calContent(messageList.first),
                      keyText: logic.searchKey,
                      style: PageStyle.ts_ADADAD_12sp,
                      keyStyle: PageStyle.ts_1B72EC_12sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (messageCount > 1)
                    SearchKeywordText(
                      text: sprintf(StrRes.relatedChatHistory, [messageCount]),
                      // keyText: '三',
                      style: PageStyle.ts_ADADAD_12sp,
                      keyStyle: PageStyle.ts_1B72EC_12sp,
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildGroupItemView({
    required GroupInfo info,
    required String showName,
  }) =>
      _buildInkButton(
        onTap: () => logic.previewGroupInfo(info),
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
                text: showName,
                keyText: logic.searchKey,
                style: PageStyle.ts_333333_14sp,
                keyStyle: PageStyle.ts_1B72EC_14sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildFriendItemView(FriendInfo info) => _buildInkButton(
        onTap: () => logic.previewFriendInfo(info),
        child: Row(
          children: [
            AvatarView(
              url: info.faceURL,
              text: info.nickname,
              size: 42.h,
            ),
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 42.h),
                margin: EdgeInsets.only(left: 14.w),
                padding: EdgeInsets.only(
                  right: 22.w,
                  top: 7.h,
                  bottom: 7.h,
                ),
                // decoration: BoxDecoration(
                //   border: BorderDirectional(
                //     bottom: BorderSide(
                //       color: Color(0xFFF0F0F0),
                //       width: 1,
                //     ),
                //   ),
                // ),
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

  Widget _buildDeptMemberItemView(DeptMemberInfo info) => _buildInkButton(
        onTap: () => logic.previewMemberInfo(info),
        child: Row(
          children: [
            AvatarView(
              url: info.faceURL,
              text: info.nickname,
              size: 42.h,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 14.w),
                padding: EdgeInsets.only(
                  right: 22.w,
                  top: 7.h,
                  bottom: 7.h,
                ),
                // decoration: BoxDecoration(
                //   border: BorderDirectional(
                //     bottom: BorderSide(
                //       color: Color(0xFFF0F0F0),
                //       width: 1,
                //     ),
                //   ),
                // ),
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

  Widget _buildFileItemView({
    required Message message,
    required String fileName,
    required String showName,
  }) =>
      _buildInkButton(
        onTap: () => logic.previewFile(message),
        child: Row(
          children: [
            FaIcon(
              CommonUtil.fileIcon(fileName),
              color: Color(0xFFfec852),
              size: 40.h,
            ),
            // FaIcon(
            //   FontAwesomeIcons.solidFolderClosed,
            //   size: 42.h,
            //   color: Color(0xFFfec852),
            // ),
            SizedBox(width: 10.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SearchKeywordText(
                  text: fileName,
                  keyText: logic.searchKey,
                  style: PageStyle.ts_333333_14sp,
                  keyStyle: PageStyle.ts_1B72EC_14sp,
                ),
                Text(
                  showName,
                  style: PageStyle.ts_ADADAD_10sp,
                ),
              ],
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

  Widget _buildTabBar() => Container(
        decoration: BoxDecoration(
          color: PageStyle.c_FFFFFF,
          border: BorderDirectional(
            bottom: BorderSide(
              color: PageStyle.c_EAEAEA,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            logic.tabs.length,
            (index) => _buildTabItem(
              index: index,
              label: logic.tabs.elementAt(index),
              isChecked: logic.index.value == index,
            ),
          ),
        ),
      );

  Widget _buildTabItem({
    required String label,
    required int index,
    bool isChecked = false,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => logic.switchTab(index),
        child: Container(
          height: 39.h,
          alignment: Alignment.center,
          child: Text(
            label,
            style:
                isChecked ? PageStyle.ts_1B72EC_14sp : PageStyle.ts_B0B0B0_14sp,
          ),
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(
                color: isChecked ? PageStyle.c_1B72EC : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        ),
      );

  Widget _buildNoSearch() => SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 162.h,
            ),
            Image.asset(
              ImageRes.ic_searchEmpty,
              width: 163.h,
              height: 163.h,
            ),
            Text(
              StrRes.noSearchResult,
              style: PageStyle.ts_BABABA_16sp,
            )
          ],
        ),
      );
}
