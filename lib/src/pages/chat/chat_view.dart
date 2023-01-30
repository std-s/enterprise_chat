import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:openim_enterprise_chat/src/widgets/water_mark_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';

import '../../sdk_extension/message_manager.dart';
import '../../widgets/avatar_view.dart';
import '../../widgets/chat_listview.dart';
import 'chat_logic.dart';

class ChatPage extends StatelessWidget {
  final logic = Get.find<ChatLogic>();

  Widget _itemView(int index, Message message) => ChatItemView(
        key: logic.itemKey(message),
        index: index,
        message: message,
        timeStr: logic.getShowTime(message),
        messageTimeStr: IMUtil.getChatTimeline(message.sendTime!, 'HH:mm:ss'),
        isSingleChat: logic.isSingleChat,
        clickSubject: logic.clickSubject,
        msgSendStatusSubject: logic.msgSendStatusSubject,
        msgSendProgressSubject: logic.msgSendProgressSubject,
        popPageCloseMenuSubject: logic.forceCloseMenuSub,
        multiSelMode: logic.showCheckbox(message),
        multiList: logic.multiSelList.value,
        allAtMap: logic.getAtMapping(message),
        delaySendingStatus: true,
        textScaleFactor: logic.scaleFactor.value,
        isPrivateChat: logic.isPrivateChat(message),
        readingDuration: logic.readTime(message),
        isPlayingSound: logic.isPlaySound(message),
        onFailedResend: () {
          logic.failedResend(message);
        },
        onDestroyMessage: () {
          logic.deleteMsg(message);
        },
        onViewMessageReadStatus: () {
          logic.viewGroupMessageReadStatus(message);
        },
        onMultiSelChanged: (checked) {
          logic.multiSelMsg(message, checked);
        },
        onTapCopyMenu: () {
          logic.copy(message);
        },
        onTapDelMenu: () {
          logic.deleteMsg(message);
        },
        onTapForwardMenu: () {
          logic.forward(message);
        },
        onTapReplyMenu: () {
          logic.setQuoteMsg(message);
        },
        onTapRevokeMenu: () {
          logic.revokeMsgV2(message);
        },
        onTapMultiMenu: () {
          logic.openMultiSelMode(message);
        },
        onTapAddEmojiMenu: () {
          logic.addEmoji(message);
        },
        visibilityChange: (context, index, message, visible) {
          logic.markMessageAsRead(message, visible);
        },
        onLongPressLeftAvatar: () {
          logic.onLongPressLeftAvatar(message);
        },
        onLongPressRightAvatar: () {},
        onTapLeftAvatar: () {
          logic.onTapLeftAvatar(message);
        },
        onTapRightAvatar: () {},
        onClickAtText: (uid) {
          logic.clickAtText(uid);
        },
        onTapQuoteMsg: () {
          logic.onTapQuoteMsg(message);
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
        enabledReadStatus: logic.enabledReadStatus(message),
        isBubbleMsg: !logic.isNotificationType(message) && !logic.isFailedHintMessage(message),
        customLeftAvatarBuilder: () => _buildCustomLeftAvatar(message),
        customRightAvatarBuilder: () => _buildCustomRightAvatar(message),
        enabledTranslationMenu: false,
        enabledCopyMenu: logic.showCopyMenu(message),
        enabledRevokeMenu: logic.showRevokeMenu(message),
        enabledReplyMenu: logic.showReplyMenu(message),
        enabledMultiMenu: logic.showMultiMenu(message),
        enabledForwardMenu: logic.showForwardMenu(message),
        enabledDelMenu: logic.showDelMenu(message),
        enabledAddEmojiMenu: logic.showAddEmojiMenu(message),
        onPopMenuShowChanged: logic.onPopMenuShowChanged,
        leftName: logic.newestNickname(message),
        showLongPressMenu: !logic.isMuted,
        showNoticeMessage: true,
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() => WillPopScope(
          onWillPop: logic.willPop(),
          child: ChatVoiceRecordLayout(
            locale: Get.locale,
            maxRecordSec: 60,
            builder: (bar) => Obx(() => Scaffold(
                  backgroundColor: PageStyle.c_FFFFFF,
                  appBar: EnterpriseTitleBar.chatTitle(
                    title: logic.getTitle(),
                    subTitle: logic.getSubTile(),
                    onClickMoreBtn: () => logic.chatSetup(),
                    leftButton: logic.multiSelMode.value ? StrRes.cancel : null,
                    onClose: () => logic.exit(),
                    showOnlineStatus: logic.showOnlineStatus(),
                    online: logic.onlineStatus.value,
                    showCallButton: false,
                    showMoreButton: logic.isValidChat.value,
                    count: logic.unreadMsgCount.value,
                  ),
                  body: SafeArea(
                    child: WaterMarkBgView(
                      text: logic.markText,
                      path: logic.background.value,
                      floatView: logic.participants.isNotEmpty ? _buildCallingLinkView() : null,
                      child: Column(
                        children: [
                          if (logic.announcement.value.isNotEmpty) _buildAnnouncementFloatView(),
                          Expanded(
                            child: ChatListView(
                              onTouch: () => logic.closeToolbox(),
                              itemCount: logic.messageList.length,
                              controller: logic.scrollController,
                              onScrollDownLoad: () => logic.getHistoryMsgList(),
                              onScrollToTop: logic.onScrollToTop,
                              itemBuilder: (_, index) {
                                final message = logic.indexOfMessage(index);
                                // 公告弹出展示
                                // if (logic.isAnnouncementMessage(message)) {
                                //   return SizedBox();
                                // }
                                return Obx(
                                  () => _itemView(index, message),
                                );
                              },
                            ),
                          ),
                          ChatInputBoxView(
                            controller: logic.inputCtrl,
                            allAtMap: logic.atUserNameMappingMap,
                            toolbox: ChatToolsView(
                              onTapAlbum: () => logic.onTapAlbum(),
                              onTapCamera: () => logic.onTapCamera(),
                              onTapCarte: () => logic.onTapCarte(),
                              onTapFile: () => logic.onTapFile(),
                              onTapLocation: () => logic.onTapLocation(),
                              onStopVoiceInput: () => logic.onStopVoiceInput(),
                              onStartVoiceInput: () => logic.onStartVoiceInput(),
                            ),
                            multiOpToolbox: ChatMultiSelToolbox(
                              onDelete: () => logic.mergeDelete(),
                              onMergeForward: () => logic.mergeForward(),
                            ),
                            emojiView: ChatEmojiView(
                              onAddEmoji: logic.onAddEmoji,
                              onDeleteEmoji: logic.onDeleteEmoji,
                              onAddFavorite: () => logic.emojiManage(),
                              favoriteList: logic.cacheLogic.urlList,
                              onSelectedFavorite: logic.sendCustomEmoji,
                              textEditingController: logic.inputCtrl,
                            ),
                            onSubmitted: (v) => logic.sendTextMsg(),
                            forceCloseToolboxSub: logic.forceCloseToolbox,
                            voiceRecordBar: bar,
                            quoteContent: logic.quoteContent.value,
                            onClearQuote: () => logic.setQuoteMsg(null),
                            multiMode: logic.multiSelMode.value,
                            focusNode: logic.focusNode,
                            inputFormatters: [AtTextInputFormatter(logic.openAtList)],
                            isGroupMuted: logic.isGroupMuted,
                            muteEndTime: logic.muteEndTime.value,
                            isInBlacklist: logic.isSingleChat ? logic.isInBlacklist.value : false,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            onCompleted: (sec, path) {
              logic.sendVoice(duration: sec, path: path);
            },
          ),
        ));
  }

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
    if (logic.isFailedHintMessage(message)) {
      var data = IMUtil.parseCustomMessage(message);
      if (null != data) {
        var viewType = data['viewType'];
        if (viewType == CustomMessageType.deletedByFriend) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 1.sw - 20),
                child: RichText(
                  text: TextSpan(
                    text: sprintf(
                      StrRes.deletedByFriendHint,
                      [logic.getTitle()],
                    ),
                    style: PageStyle.ts_999999_12sp,
                    children: [
                      TextSpan(
                        text: StrRes.sendFriendVerification,
                        style: PageStyle.ts_1D6BED_12sp,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => logic.sendFriendVerification(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        } else if (viewType == CustomMessageType.blockedByFriend) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // alignment: Alignment.center,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: PageStyle.c_979797,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  StrRes.blockedByFriendHint,
                  style: PageStyle.ts_FFFFFF_12sp,
                ),
              )
            ],
          );
        }
      }
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
            type == 'audio' ? ImageRes.ic_voiceCallMsg : ImageRes.ic_videoCallMsg,
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
    String? nickname;
    String? faceUrl;
    if (logic.isSingleChat) {
      nickname = logic.name.value;
      faceUrl = logic.icon.value;
    } else {
      var info = logic.memberUpdateInfoMap[message.sendID];
      nickname = info?.nickname;
      faceUrl = info?.faceURL;
    }
    return AvatarView(
      size: 42.h,
      url: faceUrl ?? message.senderFaceUrl,
      text: nickname ?? message.senderNickname,
      textStyle: PageStyle.ts_FFFFFF_14sp,
      onTap: () {
        logic.onTapLeftAvatar(message);
      },
    );
  }

  Widget? _buildCustomRightAvatar(Message message) {
    String? nickname;
    String? faceUrl;
    if (logic.isGroupChat) {
      var info = logic.memberUpdateInfoMap[message.sendID];
      nickname = info?.nickname;
      faceUrl = info?.faceURL;
    }
    return AvatarView(
      size: 42.h,
      url: faceUrl ?? message.senderFaceUrl,
      text: nickname ?? message.senderNickname,
      textStyle: PageStyle.ts_FFFFFF_14sp,
    );
  }

  /// 群公告item
  Widget _buildAnnouncementFloatView() => GestureDetector(
        onTap: logic.previewGroupAnnouncement,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: PageStyle.c_F0F6FF,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Image.asset(ImageRes.ic_trumpet, width: 16.h, height: 16.h),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  logic.announcement.value,
                  style: PageStyle.ts_617183_12sp,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FaIcon(
                FontAwesomeIcons.angleRight,
                size: 12.h,
                color: PageStyle.c_898989,
              )
            ],
          ),
        ),
      );

  /// 群通话提示链接，点击加入通话。
  Widget _buildCallingLinkView() {
    final maxCount = 12;
    Widget _buildLinkView() => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: logic.expandCallingMemberPanel,
          child: Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                Image.asset(
                  ImageRes.ic_calling,
                  width: 10.w,
                  height: 10.h,
                ),
                6.horizontalSpace,
                Expanded(
                  child: Text(
                    sprintf(StrRes.groupVideoCallHint, [logic.participants.length]),
                    style: PageStyle.ts_5496EB_12sp,
                  ),
                ),
                Transform.rotate(
                  angle: (logic.showCallingMember.value ? 1 : 0) * pi,
                  child: Image.asset(
                    ImageRes.ic_arrowDownBlue,
                    width: 9.w,
                    height: 6.h,
                  ),
                ),
              ],
            ),
          ),
        );
    Widget _buildMemberView() => Container(
          decoration: BoxDecoration(
            color: PageStyle.c_FDFEFF,
            borderRadius: BorderRadius.circular(2.r),
          ),
          margin: EdgeInsets.only(bottom: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 9.w,
                  mainAxisSpacing: 9.h,
                ),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    logic.participants.length > maxCount ? maxCount : logic.participants.length,
                itemBuilder: (context, index) {
                  final info = logic.participants.elementAt(index).groupMemberInfo;
                  if (index == maxCount - 1) {
                    return Container(
                      decoration: BoxDecoration(
                        color: PageStyle.c_5496EB,
                        borderRadius: BorderRadius.circular(5.88.r),
                      ),
                      child: Center(
                        child: Image.asset(
                          ImageRes.ic_more,
                          color: PageStyle.c_FFFFFF,
                          width: 32.w,
                        ),
                      ),
                    );
                  }
                  return AvatarView(
                    url: info?.faceURL,
                    text: info?.nickname,
                    borderRadius: BorderRadius.circular(5.88.r),
                  );
                },
              ),
              Container(
                color: PageStyle.c_979797,
                height: .5,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: null,
                child: Container(
                  height: 44.h,
                  alignment: Alignment.center,
                  child: Text(
                    StrRes.joinIn,
                    style: PageStyle.ts_5496EB_14sp,
                  ),
                ),
              ),
            ],
          ),
        );
    return Column(
      children: [
        Container(
          color: PageStyle.c_F1F7FF,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLinkView(),
              if (logic.showCallingMember.value) _buildMemberView(),
            ],
          ),
        ),
      ],
    );
  }
}
