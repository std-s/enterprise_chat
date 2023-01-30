import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../utils/im_util.dart';

class SearchFileLogic extends GetxController {
  final refreshController = RefreshController(initialRefresh: false);
  late ConversationInfo info;
  var messageList = <Message>[].obs;
  var pageIndex = 1;
  var pageSize = 50;

  @override
  void onInit() {
    info = Get.arguments;
    super.onInit();
  }

  @override
  void onReady() {
    onRefresh();
    super.onReady();
  }

  onRefresh() async {
    try {
      pageIndex = 1;
      var result = await search();
      print("result:${result.totalCount}");
      if (result.totalCount == 0) {
        messageList.clear();
      } else {
        var item = result.searchResultItems!.first;
        messageList.assignAll(item.messageList!);
      }
    } finally {
      refreshController.refreshCompleted();
      if (messageList.length < pageIndex * pageSize) {
        refreshController.loadNoData();
      }
    }
  }

  onLoad() async {
    try {
      ++pageIndex;
      var result = await search();
      print("result:${result.totalCount}");
      if (result.totalCount! > 0) {
        var item = result.searchResultItems!.first;
        messageList.addAll(item.messageList!);
      }
    } finally {
      if (messageList.length < pageIndex * pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    }
  }

  Future<SearchResult> search() {
    return OpenIM.iMManager.messageManager.searchLocalMessages(
      conversationID: info.conversationID,
      keywordList: [],
      messageTypeList: [MessageType.file],
      pageIndex: pageIndex,
      count: pageSize,
    );
  }

  void viewFile(Message message) {
    IMUtil.openFile(message);
  }
}
