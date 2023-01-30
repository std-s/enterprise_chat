import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import '../../../../res/images.dart';
import '../../../../res/strings.dart';
import '../../../../widgets/search_box.dart';
import '../../../../widgets/titlebar.dart';
import 'search_history_message_logic.dart';

class SearchHistoryMessagePage extends StatelessWidget {
  final logic = Get.find<SearchHistoryMessageLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageStyle.c_FFFFFF,
      appBar: EnterpriseTitleBar.searchTitle(
        cancelTextStyle: PageStyle.ts_1B61D6_18sp,
        searchBox: SearchBox(
          backgroundColor: PageStyle.c_E8F2FF,
          controller: logic.searchCtrl,
          focusNode: logic.focusNode,
          enabled: true,
          autofocus: true,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          hintText: StrRes.search,
          height: 41.h,
          onSubmitted: logic.search,
          onCleared: logic.clear,
          onChanged: logic.onChanged,
          clearBtn: Container(
            child: Image.asset(
              ImageRes.ic_clearInput,
              color: PageStyle.c_999999,
              width: 20.w,
              height: 20.w,
            ),
          ),
        ),
      ),
      body: Obx(
        () => TouchCloseSoftKeyboard(
          child: logic.isNotKey()
              ? _buildDefaultView()
              : (logic.messageList.isEmpty
                  ? _buildNoFoundView()
                  : SmartRefresher(
                      controller: logic.refreshController,
                      footer: IMWidget.buildFooter(),
                      enablePullDown: false,
                      enablePullUp: true,
                      onLoading: logic.load,
                      child: ListView.builder(
                        itemCount: logic.messageList.length,
                        itemBuilder: (_, index) {
                          var msg = logic.messageList.elementAt(index);
                          return _buildItemView(
                            message: msg,
                            url: msg.senderFaceUrl,
                            name: msg.senderNickname!,
                            matchText: msg.content!,
                            keyText: logic.searchCtrl.text.trim(),
                            time: msg.sendTime!,
                          );
                        },
                      ),
                    )),
        ),
      ),
    );
  }

  Widget _buildDefaultView() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 57.h,
          ),
          Text(
            StrRes.assignSearchContent,
            style: PageStyle.ts_666666_14sp,
          ),
          SizedBox(
            height: 21.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: logic.searchPicture,
                child: Text(
                  StrRes.picture,
                  style: PageStyle.ts_1B61D6_16sp,
                ),
              ),
              GestureDetector(
                onTap: logic.searchVideo,
                behavior: HitTestBehavior.translucent,
                child: Text(
                  StrRes.video,
                  style: PageStyle.ts_1B61D6_16sp,
                ),
              ),
              GestureDetector(
                onTap: logic.searchFile,
                behavior: HitTestBehavior.translucent,
                child: Text(
                  StrRes.file,
                  style: PageStyle.ts_1B61D6_16sp,
                ),
              ),
            ],
          )
        ],
      );

  Widget _buildNoFoundView() => Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 98.h),
        child: logic.noFoundText(),
      );

  Widget _buildItemView({
    required Message message,
    String? url,
    required String name,
    required String matchText,
    required String keyText,
    required int time,
  }) =>
      GestureDetector(
        onTap: () => logic.previewMessageHistory(message),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Row(
            children: [
              AvatarView(
                url: url,
                size: 42.h,
                text: name,
              ),
              Expanded(
                child: Container(
                  height: 64.h,
                  margin: EdgeInsets.only(left: 12.w),
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      bottom: BorderSide(
                        color: PageStyle.c_999999_opacity40p,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: PageStyle.ts_333333_14sp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Text(
                            IMUtil.getChatTimeline(time),
                            style: PageStyle.ts_999999_12sp,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      SearchKeywordText(
                        text: logic.calContent(message),
                        keyText: keyText,
                        style: PageStyle.ts_666666_14sp,
                        keyStyle: PageStyle.ts_1B61D6_14sp,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
