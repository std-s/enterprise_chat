import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';
import 'package:sprintf/sprintf.dart';

import '../../../res/images.dart';
import '../../../res/strings.dart';
import '../../../res/styles.dart';
import '../../../utils/im_util.dart';
import '../../../widgets/avatar_view.dart';
import '../../../widgets/search_box.dart';
import '../../../widgets/titlebar.dart';
import '../../../widgets/touch_close_keyboard.dart';
import 'chat_history_logic.dart';

class ChatHistoryPage extends StatelessWidget {
  final logic = Get.find<ChatHistoryLogic>();

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: EnterpriseTitleBar.searchTitle(
          searchBox: SearchBox(
            controller: logic.searchCtrl,
            focusNode: logic.focusNode,
            enabled: true,
            autofocus: false,
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
            onChanged: logic.changed,
            onCleared: logic.clear,
          ),
        ),
        backgroundColor: PageStyle.c_F8F8F8,
        body: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              color: PageStyle.c_FFFFFF,
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
              margin: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  AvatarView(
                    size: 42.h,
                    text: logic.searchResultItems.showName,
                    url: logic.searchResultItems.faceURL,
                  ),
                  SizedBox(width: 10.h),
                  Container(
                    constraints: BoxConstraints(maxWidth: 140.w),
                    child: Text(
                      logic.searchResultItems.showName!,
                      style: PageStyle.ts_333333_14sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() => Obx(
        () => logic.needRefresh.value == 0
            ? SizedBox()
            : Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: PageStyle.c_FFFFFF,
                      border: BorderDirectional(
                        bottom: BorderSide(
                          color: PageStyle.c_EAEAEA,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 8.h,
                    ),
                    child: Text(
                      sprintf(
                        StrRes.relatedChatHistory,
                        [logic.searchResultItems.messageCount!],
                      ),
                      style: PageStyle.ts_ADADAD_12sp,
                    ),
                  ),
                  Expanded(
                    child: SmartRefresher(
                      controller: logic.refreshCtrl,
                      enablePullDown: false,
                      enablePullUp: true,
                      footer: IMWidget.buildFooter(),
                      onLoading: () => logic.load(),
                      child: ListView.builder(
                        itemCount: logic.searchResultItems.messageCount!,
                        itemBuilder: (_, index) {
                          var message = logic.searchResultItems.messageList!
                              .elementAt(index);
                          return _buildChatHistoryItemView(
                            message: message,
                            showName: message.senderNickname ?? '',
                            content: message.content!,
                            faceURL: message.senderFaceUrl,
                            sendTime: message.sendTime!,
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
      );

  Widget _buildChatHistoryItemView({
    required Message message,
    required String showName,
    String? faceURL,
    required String content,
    required int sendTime,
  }) =>
      _buildInkButton(
        onTap: () => logic.previewMessageHistory(message),
        child: Row(
          children: [
            AvatarView(
              size: 42.h,
              text: showName,
              url: faceURL,
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
                      Text(
                        IMUtil.getCallTimeline(sendTime),
                        style: PageStyle.ts_ADADAD_10sp,
                      ),
                    ],
                  ),
                  SearchKeywordText(
                    text: logic.calContent(message),
                    keyText: logic.searchKey,
                    style: PageStyle.ts_ADADAD_12sp,
                    keyStyle: PageStyle.ts_1B72EC_14sp,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
            height: 62.h,
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: child,
          ),
        ),
      );
}
