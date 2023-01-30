import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/contacts_info.dart';
import '../../../../../routes/app_navigator.dart';
import '../../../../../utils/im_util.dart';

class PreviewMessageLogic extends GetxController {
  final scrollController = ScrollController();
  final refreshController = RefreshController();
  late String conversationID;
  late String showName;
  String? faceURL;
  late Message searchMessage;
  late ConversationInfo conversationInfo;
  var messageList = <Message>[].obs;
  String? userID;
  String? groupID;
  var atUserNameMappingMap = <String, String>{};

  /// Click on the message to process voice playback, video playback, picture preview, etc.
  final clickSubject = PublishSubject<int>();

  /// The status of message sending,
  /// there are two kinds of success or failure, true success, false failure
  final msgSendStatusSubject = PublishSubject<MsgStreamEv<bool>>();

  /// The progress of sending messages, such as the progress of uploading pictures, videos, and files
  final msgSendProgressSubject = PublishSubject<MsgStreamEv<int>>();

  /// Download progress of pictures, videos, and files
  final downloadProgressSubject = PublishSubject<MsgStreamEv<double>>();

  bool get isSingleChat => null != userID && userID!.trim().isNotEmpty;

  bool get isGroupChat => null != groupID && groupID!.trim().isNotEmpty;

  var showHighlight = true.obs;

  @override
  void onClose() {
    clickSubject.close();
    msgSendStatusSubject.close();
    msgSendProgressSubject.close();
    downloadProgressSubject.close();
    super.onClose();
  }

  @override
  void onInit() {
    conversationID = Get.arguments['conversationID'];
    showName = Get.arguments['showName'];
    faceURL = Get.arguments['faceURL'];
    searchMessage = Get.arguments['searchMessage'];
    // 自定义消息点击事件
    clickSubject.listen((index) {
      print('index:$index');
      parseClickEvent(indexOfMessage(index, calculate: false));
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(seconds: 2), () {
        showHighlight.value = false;
      });
    });
    super.onInit();
  }

  @override
  void onReady() {
    lockMessageLocation();
    super.onReady();
  }

  /// 搜索定位消息位置
  lockMessageLocation() async {
    var cList =
        await OpenIM.iMManager.conversationManager.getMultipleConversation(
      conversationIDList: [conversationID],
    );
    conversationInfo = cList.first;
    userID = conversationInfo.userID;
    groupID = conversationInfo.groupID;

    var upList = await OpenIM.iMManager.messageManager.getHistoryMessageList(
      startMsg: searchMessage,
      conversationID: conversationInfo.conversationID,
      // userID: userID,
      // groupID: groupID,
      count: 10,
    );

    var downList =
        await OpenIM.iMManager.messageManager.getHistoryMessageListReverse(
      startMsg: searchMessage,
      conversationID: conversationInfo.conversationID,
      // userID: userID,
      // groupID: groupID,
      count: 10,
    );

    upList.add(searchMessage);
    // downList..insert(0, searchMessage);
    messageList.assignAll(upList);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      while (scrollController.position.pixels !=
          scrollController.position.maxScrollExtent) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        await SchedulerBinding.instance.endOfFrame;
      }
      if (downList.isNotEmpty) {
        messageList.addAll(downList);
      }
    });
    _loadStatusSetup(downList);
  }

  Future scrollToBottom() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      while (scrollController.position.pixels !=
          scrollController.position.maxScrollExtent) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        await SchedulerBinding.instance.endOfFrame;
      }
    });
  }

  onRefresh() async {
    var list = await OpenIM.iMManager.messageManager.getHistoryMessageList(
      startMsg: messageList.first,
      conversationID: conversationInfo.conversationID,
      // userID: userID,
      // groupID: groupID,
      count: 10,
    );
    messageList.insertAll(0, list);
    refreshController.refreshCompleted();
  }

  onLoad() async {
    var list =
        await OpenIM.iMManager.messageManager.getHistoryMessageListReverse(
      startMsg: messageList.last,
      conversationID: conversationInfo.conversationID,
      // userID: userID,
      // groupID: groupID,
      count: 10,
    );
    if (list.isNotEmpty) {
      messageList.addAll(list);
    }
    _loadStatusSetup(list);
  }

  void _loadStatusSetup(List list) {
    if (list.isNotEmpty) {
      if (list.length < 10) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    } else {
      refreshController.loadNoData();
    }
  }

  Color? getHighlightColor(Message message) {
    if (message == searchMessage && showHighlight.value) {
      return Color(0xFFFDF5E9);
    }
    return null;
  }

  String? getShowTime(Message message) {
    if (message.ext == true) {
      return IMUtil.getChatTimeline(message.sendTime!);
    }
    return null;
  }

  Message indexOfMessage(int index, {bool calculate = true}) =>
      IMUtil.calChatTimeInterval(
        messageList,
        calculate: calculate,
      ).elementAt(index);

  Map<String, String> getAtMapping(Message message) {
    if (isGroupChat) {
      final map = <String, String>{};
      if (message.contentType == MessageType.at_text) {
        var list = message.atElem!.atUsersInfo;
        list?.forEach((e) {
          map[e.atUserID!] = e.groupNickname!;
          atUserNameMappingMap.putIfAbsent(e.atUserID!, () => e.groupNickname!);
        });
      }
      return atUserNameMappingMap;
    }
    return {};
  }

  /// 通知类型消息
  bool isNotificationType(Message message) => message.contentType! >= 1000;

  /// 处理消息点击事件
  void parseClickEvent(Message msg) async {
    // log("message:${json.encode(msg)}");
    IMUtil.parseClickEvent(msg, messageList: messageList);
    // if (msg.contentType == MessageType.picture) {
    //   var list = messageList
    //       .where((p0) => p0.contentType == MessageType.picture)
    //       .toList();
    //   var index = list.indexOf(msg);
    //   if (index == -1) {
    //     IMUtil.openPicture([msg], index: 0, tag: msg.clientMsgID);
    //   } else {
    //     IMUtil.openPicture(list, index: index, tag: msg.clientMsgID);
    //   }
    // } else if (msg.contentType == MessageType.video) {
    //   IMUtil.openVideo(msg);
    // } else if (msg.contentType == MessageType.file) {
    //   IMUtil.openFile(msg);
    // } else if (msg.contentType == MessageType.card) {
    //   var info = ContactsInfo.fromJson(json.decode(msg.content!));
    //   AppNavigator.startFriendInfo(userInfo: info);
    // } else if (msg.contentType == MessageType.merger) {
    //   Get.to(
    //     () => PreviewMergeMsg(
    //       title: msg.mergeElem!.title!,
    //       messageList: msg.mergeElem!.multiMessage!,
    //     ),
    //     preventDuplicates: false,
    //   );
    // } else if (msg.contentType == MessageType.location) {
    //   var location = msg.locationElem;
    //   Map detail = json.decode(location!.description!);
    //   Get.to(() => MapView(
    //         latitude: location.latitude!,
    //         longitude: location.longitude!,
    //         addr1: detail['name'],
    //         addr2: detail['addr'],
    //       ));
    // }
  }

  /// 点击引用消息
  void onTapQuoteMsg(Message message) {
    if (message.contentType == MessageType.quote) {
      parseClickEvent(message.quoteElem!.quoteMessage!);
    } else if (message.contentType == MessageType.at_text) {
      parseClickEvent(message.atElem!.quoteMessage!);
    }
  }

  void onTapLeftAvatar(Message message) {
    var info = ContactsInfo.fromJson({
      'userID': message.sendID!,
      'nickname': message.senderNickname,
      'faceURL': message.senderFaceUrl,
    });
    viewUserInfo(info);
  }

  void clickAtText(id) {}

  void viewUserInfo(UserInfo info) {
    AppNavigator.startFriendInfo(
      userInfo: info,
      showMuteFunction: false,
      groupID: groupID!,
    );
  }

  void clickLinkText(url, type) async {
    if (type == PatternType.AT) {
      clickAtText(url);
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void copy(Message message) {
    IMUtil.copy(text: message.content!);
  }
}
