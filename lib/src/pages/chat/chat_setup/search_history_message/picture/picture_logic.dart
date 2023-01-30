import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPictureLogic extends GetxController {
  final refreshController = RefreshController(initialRefresh: false);
  late ConversationInfo info;
  late int type;
  var messageList = <Message>[];
  var groupMessage = <String, List<Message>>{}.obs;
  var pageIndex = 1;
  var pageSize = 50;

  bool get isPicture => type == 0;

  @override
  void onInit() {
    info = Get.arguments['info'];
    type = Get.arguments['type'];
    super.onInit();
  }

  @override
  void onReady() {
    onRefresh();
    super.onReady();
  }

  void onRefresh() async {
    try {
      pageIndex = 1;
      var result = await search();
      print("result:${result.totalCount}");
      if (result.totalCount == 0) {
        messageList.clear();
        groupMessage.clear();
      } else {
        var item = result.searchResultItems!.first;
        messageList.assignAll(item.messageList!);
        groupMessage.assignAll(IMUtil.groupingMessage(item.messageList!));
      }
    } finally {
      refreshController.refreshCompleted();
      if (messageList.length < pageIndex * pageSize) {
        refreshController.loadNoData();
      }
    }
  }

  void onLoad() async {
    try {
      pageIndex += 1;
      var result = await search();
      print("result:${result.totalCount}");
      if (result.totalCount! > 0) {
        var item = result.searchResultItems!.first;
        messageList.addAll(item.messageList!);
        groupMessage.addAll(IMUtil.groupingMessage(item.messageList!));
        groupMessage.refresh();
      }
    } finally {
      refreshController.refreshCompleted();
      if (messageList.length < pageIndex * pageSize) {
        refreshController.loadNoData();
      }
    }
  }

  Future<SearchResult> search() {
    return OpenIM.iMManager.messageManager.searchLocalMessages(
      conversationID: info.conversationID,
      keywordList: [],
      messageTypeList: [isPicture ? MessageType.picture : MessageType.video],
      pageIndex: pageIndex,
      count: pageSize,
    );
  }

  void viewPicture(Message message) {
    if (isPicture) {
      IMUtil.openPicture(
        messageList,
        index: messageList.indexOf(message),
        tag: message.clientMsgID,
      );
    } else {
      IMUtil.openVideo(message);
    }
  }

  String getSnapshotUrl(Message message) {
    return isPicture
        ? message.pictureElem!.sourcePicture!.url!
        : message.videoElem!.snapshotUrl!;
  }
}
