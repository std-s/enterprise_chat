import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

class SearchHistoryMessageLogic extends GetxController {
  final refreshController = RefreshController(initialRefresh: false);
  var searchCtrl = TextEditingController();
  var focusNode = FocusNode();
  late ConversationInfo info;
  var messageList = <Message>[].obs;
  var key = "".obs;
  var pageIndex = 1;
  var pageSize = 50;

  @override
  void dispose() {
    searchCtrl.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    info = Get.arguments;
    super.onInit();
  }

  bool isNotKey() => key.value.trim().isEmpty;

  void onChanged(String value) {
    key.value = value;
    if (value.trim().isNotEmpty) {
      search(value.trim());
    }
  }

  void clear() {
    key.value = '';
    messageList.clear();
  }

  void search(key) async {
    try {
      var result = await OpenIM.iMManager.messageManager.searchLocalMessages(
        conversationID: info.conversationID,
        keywordList: [key],
        pageIndex: pageIndex = 1,
        count: pageSize,
        messageTypeList: [MessageType.text, MessageType.at_text],
      );
      print("result:${result.totalCount}");
      if (result.totalCount == 0) {
        messageList.clear();
      } else {
        var item = result.searchResultItems!.first;
        messageList.assignAll(item.messageList!);
      }
    } finally {
      if (messageList.length < pageIndex * pageSize) {
        refreshController.loadNoData();
      }
    }
  }

  load() async {
    try {
      var result = await OpenIM.iMManager.messageManager.searchLocalMessages(
        conversationID: info.conversationID,
        keywordList: [searchCtrl.text.trim()],
        pageIndex: ++pageIndex,
        count: pageSize,
        messageTypeList: [MessageType.text, MessageType.at_text],
      );
      if (result.totalCount! > 0) {
        var item = result.searchResultItems!.first;
        messageList.addAll(item.messageList!);
      }
    } finally {
      if (messageList.length < (pageSize * pageIndex)) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    }
  }

  /// 中英文案
  Widget noFoundText() {
    var key = searchCtrl.text.trim();
    var noFound = sprintf(StrRes.noFoundMessage, ["#"]);
    var index = noFound.indexOf("#");
    print('noFound:$noFound   index:$index');
    var start = noFound.substring(0, index);
    var end = '';
    if (index + 1 < noFound.length) {
      end = noFound.substring(index + 1);
    }
    return RichText(
      text: TextSpan(
        children: [
          if (start.isNotEmpty)
            TextSpan(text: start, style: PageStyle.ts_666666_16sp),
          TextSpan(text: key, style: PageStyle.ts_1B61D6_16sp),
          if (end.isNotEmpty)
            TextSpan(text: end, style: PageStyle.ts_666666_16sp),
        ],
      ),
    );
  }

  String calContent(Message message) {
    String content = IMUtil.parseMsg(message, replaceIdToNickname: true);
    // 左右间距+头像跟名称的间距+头像dax
    var usedWidth = 22.w * 2 + 12.w + 42.h;
    return IMUtil.calContent(
      content: content,
      key: key.value,
      style: PageStyle.ts_666666_14sp,
      usedWidth: usedWidth,
    );
  }

  void searchFile() {
    AppNavigator.startSearchFile(info: info);
  }

  void searchPicture() {
    AppNavigator.startSearchPicture(info: info, type: 0);
  }

  void searchVideo() {
    AppNavigator.startSearchPicture(info: info, type: 1);
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
      conversationID: info.conversationID,
      showName: info.showName!,
      faceURL: info.faceURL,
      searchMessage: message,
    );
  }
}
