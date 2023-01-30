import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../res/styles.dart';
import '../../../utils/im_util.dart';
import '../../conversation/conversation_logic.dart';

class ChatHistoryLogic extends GetxController {
  final conversationLogic = Get.find<ConversationLogic>();
  final refreshCtrl = RefreshController();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  late SearchResultItems searchResultItems;
  late String defaultSearchKey;
  var needRefresh = 1.obs;
  var pageIndex = 1;
  var pageSize = 40;

  String calContent(Message message) {
    var content = IMUtil.parseMsg(message, replaceIdToNickname: true);
    // 左右间距+头像跟名称的间距+头像dax
    var usedWidth = 22.w * 2 + 10.w + 42.h;
    return IMUtil.calContent(
      content: content,
      key: searchKey,
      style: PageStyle.ts_ADADAD_12sp,
      usedWidth: usedWidth,
    );
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    searchResultItems = Get.arguments['items'];
    defaultSearchKey = Get.arguments['searchKey'];
    searchCtrl.text = defaultSearchKey;
    if (searchResultItems.messageCount! < pageSize) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }
    super.onInit();
  }

  String get searchKey => searchCtrl.text.trim();

  void clear() {
    needRefresh.value = 0;
  }

  void changed(v) {
    clear();
  }

  void search() async {
    if (searchKey.isEmpty) return;
    var result = await OpenIM.iMManager.messageManager.searchLocalMessages(
        conversationID: searchResultItems.conversationID,
        keywordList: [searchKey],
        messageTypeList: [MessageType.text, MessageType.at_text],
        pageIndex: pageIndex = 1,
        count: pageSize);
    var list = result.searchResultItems;
    if (null != list && list.isNotEmpty) {
      searchResultItems = list.first;
      needRefresh.value = ++needRefresh.value;
      if (searchResultItems.messageCount! < pageSize) {
        refreshCtrl.loadNoData();
      } else {
        refreshCtrl.loadComplete();
      }
    } else {
      refreshCtrl.loadNoData();
    }
  }

  void load() async {
    if (searchKey.isEmpty) return;
    var result = await OpenIM.iMManager.messageManager.searchLocalMessages(
        conversationID: searchResultItems.conversationID,
        keywordList: [searchKey],
        messageTypeList: [MessageType.text, MessageType.at_text],
        pageIndex: ++pageIndex,
        count: pageSize);
    var list = result.searchResultItems;
    if (null != list && list.isNotEmpty) {
      var item = list.first;
      searchResultItems.messageList?.addAll(item.messageList!);
      needRefresh.value = ++needRefresh.value;
      if (item.messageCount! < pageSize) {
        refreshCtrl.loadNoData();
      } else {
        refreshCtrl.loadComplete();
      }
    } else {
      refreshCtrl.loadNoData();
    }
  }

  void previewMessageHistory(Message message) async {
    // var list =
    //     await OpenIM.iMManager.conversationManager.getMultipleConversation(
    //   conversationIDList: [searchResultItems.conversationID!],
    // );
    // conversationLogic.startChat(
    //   userID: list.first.userID,
    //   groupID: list.first.groupID,
    //   nickname: searchResultItems.showName!,
    //   faceURL: searchResultItems.faceURL,
    //   conversationInfo: list.first,
    //   searchMessage: message
    // );
    AppNavigator.startPreviewChatHistory(
      conversationID: searchResultItems.conversationID!,
      showName: searchResultItems.showName!,
      faceURL: searchResultItems.faceURL,
      searchMessage: message,
    );
  }
}
