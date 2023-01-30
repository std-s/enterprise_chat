import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/pages/conversation/conversation_logic.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../res/styles.dart';
import '../../utils/im_util.dart';

class GlobalSearchLogic extends GetxController {
  final conversationLogic = Get.find<ConversationLogic>();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final textSearchResultItems = <SearchResultItems>[].obs;
  final fileSearchResultItems = <SearchResultItems>[].obs;
  final fileMessageList = <Message>[].obs;
  final groupList = <GroupInfo>[].obs;
  final refreshController = RefreshController();
  final deptMemberList = <DeptMemberInfo>[].obs;
  final friendList = <FriendInfo>[].obs;
  var count = 20;

  final tabs = [
    StrRes.searchAll,
    StrRes.searchContacts,
    StrRes.searchGroup,
    StrRes.searchChatHistory,
    StrRes.searchFile,
  ];
  var index = 0.obs;

  String calContent(Message message) {
    String content = IMUtil.parseMsg(message, replaceIdToNickname: true);
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

  void expandMessageGroup(SearchResultItems item) {
    if (item.messageCount! > 1) {
      AppNavigator.startExpandChatHistory(
        searchResultItems: item,
        searchKey: searchKey,
      );
    } else {
      previewMessageHistory(item);
    }
  }

  /// 最多显示3条
  List<T> subList<T>(List<T> list) =>
      list.sublist(0, list.length > 3 ? 3 : list.length).toList();

  String get searchKey => searchCtrl.text.trim();

  void switchTab(int index) {
    this.index.value = index;
  }

  void clear() {
    textSearchResultItems.clear();
    fileSearchResultItems.clear();
    fileMessageList.clear();
    groupList.clear();
    deptMemberList.clear();
    friendList.clear();
    focusNode.requestFocus();
  }

  void search() {
    searchText();
    searchFile();
    searchFriends();
    searchGroup();
    searchDeptMemberList();
  }

  /// 搜索朋友
  void searchFriends() async {
    if (searchKey.isEmpty) return;
    friendList.clear();
    var list = await OpenIM.iMManager.friendshipManager.searchFriends(
      keywordList: [searchCtrl.text.trim()],
      isSearchNickname: true,
      isSearchRemark: true,
    );
    friendList.assignAll(list);
  }

  /// 搜索聊天记录
  void searchText() async {
    if (searchKey.isEmpty) return;
    textSearchResultItems.clear();
    var result = await OpenIM.iMManager.messageManager.searchLocalMessages(
      keywordList: [searchKey],
      messageTypeList: [MessageType.text, MessageType.at_text],
    );
    var list = result.searchResultItems;
    if (null != list && list.isNotEmpty) {
      textSearchResultItems.addAll(list);
    }
  }

  /// 搜索文件
  void searchFile() async {
    if (searchKey.isEmpty) return;
    fileSearchResultItems.clear();
    fileMessageList.clear();
    var result = await OpenIM.iMManager.messageManager.searchLocalMessages(
      keywordList: [searchKey],
      messageTypeList: [MessageType.file],
    );
    var list = result.searchResultItems;
    if (null != list && list.isNotEmpty) {
      fileSearchResultItems.addAll(list);
      list.forEach((element) {
        fileMessageList.addAll(element.messageList!);
      });
    }
  }

  /// 搜索群
  void searchGroup() async {
    if (searchKey.isEmpty) return;
    groupList.clear();
    var list = await OpenIM.iMManager.groupManager.searchGroups(
      keywordList: [searchKey],
      isSearchGroupName: true,
    );
    if (list.isNotEmpty) {
      groupList.addAll(list);
    }
  }

  /// 搜索组织架构成员
  void searchDeptMemberList() async {
    if (searchKey.isEmpty) return;
    deptMemberList.clear();
    var result = await _searchDeptMember(0);
    deptMemberList.assignAll(result.departmentMemberList ?? []);
  }

  void loadDeptMemberList() async {
    var result = await _searchDeptMember(deptMemberList.length);
    deptMemberList.addAll(result.departmentMemberList ?? []);
  }

  _searchDeptMember(int offset) async {
    var result = await OpenIM.iMManager.organizationManager.searchOrganization(
      keyWord: searchCtrl.text.trim(),
      isSearchUserName: true,
      isSearchEnglishName: true,
      isSearchPosition: true,
      offset: offset,
      count: count,
    );
    if ((result.departmentMemberList?.length ?? 0) < count) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
    return result;
  }

  void previewMessageHistory(SearchResultItems item) async {
    AppNavigator.startPreviewChatHistory(
      conversationID: item.conversationID!,
      showName: item.showName!,
      faceURL: item.faceURL,
      searchMessage: item.messageList!.first,
    );
  }

  void previewGroupInfo(GroupInfo info) {
    conversationLogic.startChat(
      groupID: info.groupID,
      nickname: info.groupName,
      faceURL: info.faceURL,
      type: 1,
      sessionType: info.sessionType,
    );
  }

  void previewFile(Message message) {
    IMUtil.openFile(message);
  }

  void previewMemberInfo(DeptMemberInfo info) {
    AppNavigator.startFriendInfo(
      userInfo: UserInfo(
        userID: info.userID,
        nickname: info.nickname,
        faceURL: info.faceURL,
      ),
    );
  }

  void previewFriendInfo(FriendInfo info) {
    AppNavigator.startFriendInfo(
      userInfo: UserInfo(
        userID: info.userID,
        nickname: info.nickname,
        faceURL: info.faceURL,
      ),
    );
  }

  bool isSearchEmpty() {
    if (index.value == 0) {
      return searchKey.isNotEmpty &&
          deptMemberList.isEmpty &&
          friendList.isEmpty &&
          groupList.isEmpty &&
          textSearchResultItems.isEmpty &&
          fileMessageList.isEmpty;
    } else if (index.value == 1) {
      return searchKey.isNotEmpty &&
          deptMemberList.isEmpty &&
          friendList.isEmpty;
    } else if (index.value == 2) {
      return searchKey.isNotEmpty && groupList.isEmpty;
    } else if (index.value == 3) {
      return searchKey.isNotEmpty && textSearchResultItems.isEmpty;
    } else if (index.value == 4) {
      return searchKey.isNotEmpty && fileMessageList.isEmpty;
    }
    return false;
  }

  bool get showMoreFriends =>
      friendList.length > 3 || deptMemberList.length > 3;

  bool get showMoreDeptMember =>
      friendList.isEmpty && deptMemberList.length > 3;

  bool get showMoreGroup => groupList.length > 3;

  bool get showMoreMessage => textSearchResultItems.length > 3;

  bool get showMoreFile => fileMessageList.length > 3;
}
