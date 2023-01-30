import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/common/apis.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';

enum SearchType {
  user,
  group,
}

class AddFriendBySearchLogic extends GetxController {
  var searchCtrl = TextEditingController();
  var focusNode = FocusNode();
  var searchGroup = PublishSubject<dynamic>();
  var searchUser = PublishSubject<List<UserInfo>>();
  var searchType = SearchType.user;

  // UserInfo? userInfo;
  // GroupInfo? groupInfo;

  /// 根据用户id查询用户信息
  void search() async {
    if (isSearchUser) {
      // var list = await OpenIM.iMManager.userManager
      //     .getUsersInfo(uidList: [searchCtrl.text]);
      var list = await LoadingView.singleton.wrap(
        asyncFunction: () => Apis.searchUserFullInfo(content: searchCtrl.text),
      );
      print('list: $list');
      if (list is List && list.isNotEmpty) {
        final userList = list.map((e) => UserInfo.fromJson(e)).toList();
        searchUser.addSafely(userList);
      } else {
        searchUser.addSafely([]);
      }
    } else {
      var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
        gidList: [searchCtrl.text],
      );
      if (list.isNotEmpty) {
        searchGroup.addSafely(list.first);
      } else {
        searchGroup.addSafely('');
      }
    }
  }

  void viewUserInfo(UserInfo userInfo) {
    AppNavigator.startFriendInfo(userInfo: userInfo);
    // if (isSearchUser) {
    //   AppNavigator.startFriendInfo(userInfo: userInfo!);
    // } else {
    //   AppNavigator.startSearchAddGroup(info: groupInfo!);
    // }
  }

  void viewGroupInfo(GroupInfo groupInfo) {
    AppNavigator.startSearchAddGroup(info: groupInfo);
  }

  @override
  void onReady() {
    searchCtrl.addListener(() {
      if (searchCtrl.text.isEmpty) {
        focusNode.requestFocus();
        searchUser.addSafely([]);
        searchGroup.addSafely('');
      }
    });
    super.onReady();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    focusNode.dispose();
    searchGroup.close();
    searchUser.close();
    super.onClose();
  }

  @override
  void onInit() {
    searchType = Get.arguments['searchType'] ?? SearchType.user;
    super.onInit();
  }

  bool get isSearchUser => searchType == SearchType.user;

  String getMatchContent(UserInfo userInfo) {
    final keyword = searchCtrl.text;
    String searchPrefix = "%s";
    if (keyword == userInfo.userID) {
      searchPrefix = "ID：%s";
    } else if (keyword == userInfo.phoneNumber) {
      searchPrefix = "手机号：%s";
    } else if (keyword == userInfo.email) {
      searchPrefix = "邮箱：%s";
    } else if (keyword == userInfo.nickname) {
      searchPrefix = "昵称：%s";
    }
    return sprintf(searchPrefix, [keyword]);
  }
}
