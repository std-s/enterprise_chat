import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GroupMessageReadListLogic extends GetxController {
  late Message message;
  late List<String> hasReadIDList;
  late int needReadCount;
  var hasReadMemberList = <GroupMembersInfo>[].obs;
  var unreadMemberList = <GroupMembersInfo>[].obs;

  var index = 0.obs;
  var hasReadOffset = 0;
  var unreadOffset = 0;
  var count = 40;
  final hasReadRefreshController = RefreshController();
  final unreadRefreshController = RefreshController();

  @override
  void onInit() {
    message = Get.arguments['message'];
    var readInfo = message.attachedInfoElem?.groupHasReadInfo;
    hasReadIDList = readInfo?.hasReadUserIDList ?? [];
    needReadCount = (readInfo?.groupMemberCount ?? 0) - 1;
    _queryHasReadMembersList();
    _queryUnreadMemberList();
    super.onInit();
  }

  List<String> _sublist() {
    int end = hasReadOffset + count;
    end = end < hasReadIDList.length ? end : hasReadIDList.length;
    return hasReadIDList.sublist(hasReadOffset, end);
  }

  void _queryHasReadMembersList() async {
    hasReadOffset = 0;
    if (hasReadIDList.isEmpty) {
      hasReadRefreshController.loadNoData();
      return;
    }
    var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
      groupId: message.groupID!,
      uidList: _sublist(),
    );
    if (list.isNotEmpty) {
      hasReadMemberList.assignAll(list);
    }
    if (hasReadMemberList.length != hasReadIDList.length) {
      hasReadRefreshController.loadComplete();
    } else {
      hasReadRefreshController.loadNoData();
    }
  }

  void loadHasReadMemberList() async {
    hasReadOffset = hasReadMemberList.length;
    var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
      groupId: message.groupID!,
      uidList: _sublist(),
    );
    if (list.isNotEmpty) {
      hasReadMemberList.addAll(list);
    }
    if (hasReadMemberList.length != hasReadIDList.length) {
      hasReadRefreshController.loadComplete();
    } else {
      hasReadRefreshController.loadNoData();
    }
  }

  void _queryUnreadMemberList() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberListByJoinTime(
      groupID: message.groupID!,
      joinTimeEnd: message.sendTime! ~/ 1000,
      offset: unreadOffset = 0,
      count: count,
      excludeUserIDList: [...hasReadIDList, OpenIM.iMManager.uid],
    );
    if (list.isNotEmpty) {
      unreadMemberList.assignAll(list);
    }
    if (list.length == count) {
      unreadRefreshController.loadComplete();
    } else {
      unreadRefreshController.loadNoData();
    }
  }

  void loadUnreadMemberList() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberListByJoinTime(
      groupID: message.groupID!,
      joinTimeEnd: message.sendTime! ~/ 1000,
      offset: ++unreadOffset * count,
      count: count,
      excludeUserIDList: [...hasReadIDList, OpenIM.iMManager.uid],
    );
    if (list.isNotEmpty) {
      unreadMemberList.addAll(list);
    }
    if (list.length == count) {
      unreadRefreshController.loadComplete();
    } else {
      unreadRefreshController.loadNoData();
    }
  }

  void switchTab(i) {
    if (i == 0) {
      _queryHasReadMembersList();
    } else {
      _queryUnreadMemberList();
    }
    index.value = i;
  }

  int get unreadCount => needReadCount - hasReadIDList.length;

  int get hasReadCount => hasReadIDList.length;
}
