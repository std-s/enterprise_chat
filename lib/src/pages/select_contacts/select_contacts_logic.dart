import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/models/contacts_info.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:openim_enterprise_chat/src/widgets/custom_dialog.dart';
import 'package:sprintf/sprintf.dart';

enum SelAction {
  FORWARD,
  CARTE,
  CRATE_GROUP,
  ADD_MEMBER,
  RECOMMEND,
  CREATE_TAG,
}

class SelectContactsLogic extends GetxController {
  var index = 0.obs;
  var contactsList = <ContactsInfo>[].obs;
  var checkedList = <ContactsInfo>[].obs;
  var defaultCheckedUidList = <String>[].obs;
  var action;
  List<String>? excludeUidList;
  String? groupID;

  @override
  void onInit() {
    action = Get.arguments['action'] as SelAction;
    // 添加成员
    groupID = Get.arguments['groupID'];
    // 排除的uid
    excludeUidList = Get.arguments['excludeUidList'];
    // 默认选中，且不能修改
    var defaultCheckedUidList = Get.arguments['defaultCheckedUidList'];
    // 已经选中的
    var checkedList = Get.arguments['checkedList'];
    if (defaultCheckedUidList is List) {
      this.defaultCheckedUidList.addAll(defaultCheckedUidList.cast());
    }
    if (checkedList is List) {
      this.checkedList.addAll(checkedList.cast());
    }
    super.onInit();
  }

  bool isMultiModel() {
    return action == SelAction.CRATE_GROUP ||
        action == SelAction.ADD_MEMBER ||
        action == SelAction.CREATE_TAG;
  }

  bool isSendCarte() => SelAction.CARTE == action;

  void switchTab(i) {
    index.value = i;
  }

  void getFriends() {
    OpenIM.iMManager.friendshipManager
        .getFriendListMap()
        .then((list) {
          if (null != excludeUidList && excludeUidList!.isNotEmpty) {
            var l = <ContactsInfo>[];
            list.forEach((e) {
              var info = ContactsInfo.fromJson(e);
              if (!excludeUidList!.contains(info.userID)) {
                l.add(info);
              }
            });
            return l;
          }
          return list.map((e) => ContactsInfo.fromJson(e)).toList();
        })
        .then((list) => IMUtil.convertToAZList(list))
        .then((list) => contactsList.assignAll(list.cast<ContactsInfo>()));
  }

  void selectedContacts(ContactsInfo info) {
    if (isMultiModel()) {
      if (checkedList.contains(info)) {
        checkedList.remove(info);
      } else {
        checkedList.add(info);
      }
      // info.isChecked = !(info.isChecked ?? false);
      contactsList.refresh();
      return;
    }
    var title;
    var content;
    var url;
    var type;
    switch (action) {
      case SelAction.FORWARD:
        title = StrRes.confirmSendTo;
        content = info.getShowName();
        url = info.faceURL;
        type = DialogType.FORWARD;
        break;
      case SelAction.CARTE:
        title = StrRes.confirmSendCarte;
        type = DialogType.BASE;
        break;
      case SelAction.RECOMMEND:
        title = sprintf(StrRes.confirmRecommendFriend, [info.getShowName()]);
        type = DialogType.BASE;
        break;
      default:
        break;
    }
    Get.dialog(CustomDialog(
      title: title,
      content: content,
      url: url,
      type: type,
    )).then((confirm) {
      if (confirm == true) {
        Get.back(
          result: {
            "userID": info.userID,
            "nickname": info.nickname,
            "faceURL": info.faceURL,
          },
        );
      }
    });
  }

  void selectedGroup(GroupInfo info) {
    var title;
    var content;
    var url;
    var type;
    switch (action) {
      case SelAction.FORWARD:
        title = StrRes.confirmSendTo;
        content = info.groupName;
        url = info.faceURL;
        type = DialogType.FORWARD;
        break;
      case SelAction.CARTE:
        title = StrRes.confirmSendCarte;
        type = DialogType.BASE;
        break;
      case SelAction.RECOMMEND:
        title = sprintf(StrRes.confirmRecommendFriend, [info.groupName]);
        type = DialogType.BASE;
        break;
      default:
        break;
    }
    Get.dialog(CustomDialog(
      title: title,
      content: content,
      url: url,
      type: type,
    )).then((confirm) {
      if (confirm == true) {
        Get.back(
          result: {
            "groupID": info.groupID,
            "groupName": info.groupName,
            "faceURL": info.faceURL,
          },
        );
      }
    });
  }

  // void _search(String text) {
  //   if (ObjectUtil.isEmpty(text)) {
  //     _handleList(originList);
  //   } else {
  //     List<Languages> list = originList.where((v) {
  //       return v.name.toLowerCase().contains(text.toLowerCase());
  //     }).toList();
  //     _handleList(list);
  //   }
  // }

  void removeContacts(ContactsInfo info) {
    checkedList.remove(info);
    contactsList.refresh();
  }

  void confirmSelected() {
    if (checkedList.isEmpty) return;
    // 创建群组
    if (action == SelAction.CRATE_GROUP) {
      checkedList.addAll(
        contactsList.where((e) => defaultCheckedUidList.contains(e.userID)),
      );
      Get.back(result: checkedList.value);
      // AppNavigator.startCreateGroupInChatSetup(members: checkedList.value);
    } else if (action == SelAction.ADD_MEMBER) {
      // 添加成员
      Get.back(result: checkedList.value);
    } else if (action == SelAction.CREATE_TAG) {
      // 添加成员
      // Get.until((route) => route.route == AppRoutes.TAG_NEW);
      // navigator?.popUntil(ModalRoute.withName(AppRoutes.TAG_NEW));
      // Get.offNamedUntil(
      //   AppRoutes.TAG_NEW,
      //   ModalRoute.withName(AppRoutes.TAG_NEW),
      //   arguments: checkedList.value,
      // );
      Get.back(result: checkedList.value);
    }
  }

  @override
  void onReady() {
    getFriends();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void toSearch() {
    AppNavigator.startSearchSelectContacts();
  }

  /// 邀请群成员
  updateDefaultCheckedList(List<String> uidList) async {
    if (groupID != null) {
      var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupId: groupID!,
        uidList: uidList,
      );
      defaultCheckedUidList.addAll(list.map((e) => e.userID!));
    }
  }
}
