import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../res/images.dart';
import '../../../../../res/styles.dart';
import '../../../../../sdk_extension/message_manager.dart';
import '../../../../../utils/im_util.dart';
import '../../../../../widgets/avatar_view.dart';
import '../../../../../widgets/titlebar.dart';
import 'preview_message_logic.dart';

class PreviewMessagePage extends StatelessWidget {
  final logic = Get.find<PreviewMessageLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageStyle.c_FFFFFF,
      appBar: EnterpriseTitleBar.chatTitle(
        title: logic.showName,
        showOnlineStatus: false,
        showCallButton: false,
        showMoreButton: false,
        onClose: () => Get.back(),
      ),
      body: Obx(() => SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SmartRefresher(
                    controller: logic.refreshController,
                    footer: IMWidget.buildFooter(),
                    header: IMWidget.buildHeader(),
                    enablePullUp: true,
                    enablePullDown: true,
                    onLoading: logic.onLoad,
                    onRefresh: logic.onRefresh,
                    child: ListView.builder(
                      controller: logic.scrollController,
                      itemCount: logic.messageList.length,
                      itemBuilder: (_, index) => Obx(
                        () => _itemView(
                          index,
                          logic.indexOfMessage(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _itemView(int index, Message message) => ChatItemView(
        index: index,
        message: message,
        timeStr: logic.getShowTime(message),
        messageTimeStr: IMUtil.getChatTimeline(message.sendTime!, 'HH:mm:ss'),
        isSingleChat: logic.isSingleChat,
        clickSubject: logic.clickSubject,
        msgSendStatusSubject: logic.msgSendStatusSubject,
        msgSendProgressSubject: logic.msgSendProgressSubject,
        allAtMap: logic.getAtMapping(message),
        delaySendingStatus: false,
        enabledAddEmojiMenu: false,
        enabledCopyMenu: false,
        enabledDelMenu: false,
        enabledForwardMenu: false,
        enabledMultiMenu: false,
        enabledReplyMenu: false,
        enabledReadStatus: false,
        enabledTranslationMenu: false,
        enabledRevokeMenu: false,
        isPrivateChat: false,
        readingDuration: 0,
        highlightColor: logic.getHighlightColor(message),
        onTapLeftAvatar: () {
          logic.onTapLeftAvatar(message);
        },
        onClickAtText: (uid) {
          logic.clickAtText(uid);
        },
        onTapQuoteMsg: () {
          logic.onTapQuoteMsg(message);
        },
        onTapCopyMenu: () {
          logic.copy(message);
        },
        patterns: <MatchPattern>[
          MatchPattern(
            type: PatternType.AT,
            style: PageStyle.ts_1B72EC_14sp,
            onTap: logic.clickLinkText,
          ),
          MatchPattern(
            type: PatternType.EMAIL,
            style: PageStyle.ts_1B72EC_14sp,
            onTap: logic.clickLinkText,
          ),
          MatchPattern(
            type: PatternType.URL,
            style: PageStyle.ts_1B72EC_14sp_underline,
            onTap: logic.clickLinkText,
          ),
          MatchPattern(
            type: PatternType.MOBILE,
            style: PageStyle.ts_1B72EC_14sp,
            onTap: logic.clickLinkText,
          ),
          MatchPattern(
            type: PatternType.TEL,
            style: PageStyle.ts_1B72EC_14sp,
            onTap: logic.clickLinkText,
          ),
        ],
        customItemBuilder: _buildCustomItemView,
        customMessageBuilder: _buildCustomMessageView,
        isBubbleMsg: !logic.isNotificationType(message),
        customLeftAvatarBuilder: () => _buildCustomLeftAvatar(message),
        customRightAvatarBuilder: () => _buildCustomRightAvatar(message),
      );

  /// 自定义消息
  Widget? _buildCustomMessageView(
    BuildContext context,
    bool isReceivedMsg,
    int index,
    Message message,
    Map<String, String> allAtMap,
    double textScaleFactor,
    List<MatchPattern> patterns,
    Subject<MsgStreamEv<int>> msgSendProgressSubject,
    Subject<int> clickSubject,
  ) {
    var data = IMUtil.parseCustomMessage(message);
    if (null != data) {
      var viewType = data['viewType'];
      if (viewType == CustomMessageType.call) {
        return _buildCallItemView(type: data['type'], content: data['content']);
      } else if (viewType == CustomMessageType.tag_message) {
        final url = data['url'];
        final duration = data['duration'];
        final text = data['text'];
        if (text != null) {
          return ChatAtText(
            text: text,
            textScaleFactor: textScaleFactor,
            allAtMap: allAtMap,
            patterns: patterns,
          );
        } else if (url != null) {
          return ChatVoiceView(
            index: index,
            clickStream: clickSubject.stream,
            isReceived: isReceivedMsg,
            soundPath: null,
            soundUrl: url,
            duration: duration,
          );
        }
      }
    }
    return null;
  }

  /// custom item view
  Widget? _buildCustomItemView(
    BuildContext context,
    int index,
    Message message,
  ) {
    final text = IMUtil.parseNotification(message);
    if (null != text) {
      return _buildNotificationTipsView(text);
    }
    return null;
  }

  Widget _buildNotificationTipsView(String text) => Container(
        alignment: Alignment.center,
        child: ChatAtText(
          text: text,
          textStyle: PageStyle.ts_999999_12sp,
          textAlign: TextAlign.center,
        ),
      );

  /// 通话item
  Widget _buildCallItemView({
    required String type,
    required String content,
  }) =>
      Row(
        children: [
          Image.asset(
            type == 'audio'
                ? ImageRes.ic_voiceCallMsg
                : ImageRes.ic_videoCallMsg,
            width: 20.h,
            height: 20.h,
          ),
          SizedBox(width: 6.w),
          Text(
            content,
            style: PageStyle.ts_333333_14sp,
          ),
        ],
      );

  /// 自定义头像
  Widget? _buildCustomLeftAvatar(Message message) {
    return AvatarView(
      size: 42.h,
      url: message.senderFaceUrl,
      text: message.senderNickname,
      textStyle: PageStyle.ts_FFFFFF_14sp,
    );
  }

  Widget? _buildCustomRightAvatar(Message message) {
    return AvatarView(
      size: 42.h,
      url: OpenIM.iMManager.uInfo.faceURL,
      text: OpenIM.iMManager.uInfo.nickname,
      textStyle: PageStyle.ts_FFFFFF_14sp,
    );
  }
}
