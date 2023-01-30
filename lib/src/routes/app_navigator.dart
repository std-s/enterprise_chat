import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/models/contacts_info.dart';
import 'package:openim_enterprise_chat/src/pages/add_friend/search/search_logic.dart';
import 'package:openim_enterprise_chat/src/pages/chat/group_setup/group_member_manager/member_list/member_list_logic.dart';
import 'package:openim_enterprise_chat/src/pages/select_contacts/select_contacts_logic.dart';
import 'package:openim_enterprise_chat/src/widgets/qr_view.dart';

import '../core/controller/im_controller.dart';
import '../pages/add_friend/add_friend_logic.dart';
import '../pages/contacts/search_add_group/search_add_group_logic.dart';
import 'app_pages.dart';

class AppNavigator {
  static void backLogin() {
    residentRemove();
    Get.until((route) => Get.currentRoute == AppRoutes.LOGIN);
  }

  static void startLogin() {
    residentRemove();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  static void startRegister(String way) {
    residentRemove();
    Get.toNamed(AppRoutes.REGISTER, arguments: {'registerWay': way});
  }

  static void startRegisterVerifyPhoneOrEmail({
    String? email,
    String? phoneNumber,
    String? areaCode,
    required int usedFor,
    String? invitationCode,
  }) {
    Get.toNamed(AppRoutes.REGISTER_VERIFY_PHONE, arguments: {
      'phoneNumber': phoneNumber,
      'areaCode': areaCode,
      'email': email,
      'usedFor': usedFor,
      'invitationCode': invitationCode
    });
  }

  /// [usedFor] 1：注册，2：重置密码
  static void startSetupPwd(
      {String? phoneNumber,
      String? areaCode,
      String? email,
      required String verifyCode,
      required int usedFor,
      String? invitationCode}) {
    Get.toNamed(AppRoutes.SETUP_PWD, arguments: {
      'phoneNumber': phoneNumber,
      'areaCode': areaCode,
      'email': email,
      'verifyCode': verifyCode,
      'usedFor': usedFor,
      'invitationCode': invitationCode
    });
  }

  static void startRegisterSetupSelfInfo(
      {String? phoneNumber,
      String? areaCode,
      String? email,
      required String verifyCode,
      required String password,
      String? invitationCode}) {
    Get.toNamed(AppRoutes.REGISTER_SETUP_SELF_INFO, arguments: {
      'phoneNumber': phoneNumber,
      'areaCode': areaCode,
      'email': email,
      'verifyCode': verifyCode,
      'password': password,
      'invitationCode': invitationCode
    });
  }

  static void startMain({bool isAutoLogin = false}) {
    Get.offAllNamed(AppRoutes.HOME, arguments: {'isAutoLogin': isAutoLogin});
  }

  static void startBackMain() {
    Get.until((route) => Get.currentRoute == AppRoutes.HOME);
  }

  static Future<T?>? startChat<T>({
    int type = 0,
    String? uid,
    String? gid,
    String? name,
    String? icon,
    String? draftText,
    bool isValidChat = true,
    ConversationInfo? conversationInfo,
    Message? searchMessage,
  }) async {
    var arguments = {
      'uid': uid,
      'gid': gid,
      'name': name,
      'icon': icon,
      'draftText': draftText,
      'isValidChat': isValidChat,
      'conversationInfo': conversationInfo,
      'searchMessage': searchMessage,
    };
    // var result = await navigator?.push(
    //   CustomMaterialPageRoute(
    //     settings: RouteSettings(name: AppRoutes.CHAT, arguments: arguments),
    //     builder: (_) {
    //       return GetBuilder(
    //         init: ChatLogic(),
    //         builder: (controller) => ChatPage(),
    //       );
    //     },
    //   ),
    // );
    // return result;
    switch (type) {
      case 0:
        return Get.toNamed(AppRoutes.CHAT, arguments: arguments);
      case 1:
        return Get.offNamedUntil(
          AppRoutes.CHAT,
          (route) => route.settings.name == AppRoutes.HOME,
          arguments: arguments,
        );
      default:
        return Get.offNamed(AppRoutes.CHAT, arguments: arguments);
    }
  }

  static void startChatSetup({
    required String uid,
    required String name,
    required String icon,
  }) {
    Get.toNamed(AppRoutes.CHAT_SETUP, arguments: {
      'uid': uid,
      'name': name,
      'icon': icon,
    });
  }

  static void startGroupSetup({
    required String gid,
    required String name,
    required String icon,
  }) {
    Get.toNamed(AppRoutes.GROUP_SETUP, arguments: {
      'gid': gid,
      'name': name,
      'icon': icon,
    });
  }

  static Future<T?>? startSelectContacts<T>({
    required SelAction action,
    List<String>? defaultCheckedUidList,
    List<String>? excludeUidList,
    List<ContactsInfo>? checkedList,
    String? groupID,
  }) {
    return Get.toNamed<T>(
      AppRoutes.SELECT_CONTACTS,
      arguments: {
        'action': action,
        'defaultCheckedUidList': defaultCheckedUidList,
        'excludeUidList': excludeUidList,
        'checkedList': checkedList,
        'groupID': groupID,
      },
    );
  }

  static void startAddContacts() {
    Get.toNamed(AppRoutes.ADD_CONTACTS);
  }

  static void startFriendApplicationList() {
    Get.toNamed(AppRoutes.NEW_FRIEND_APPLICATION);
  }

  static void startFriendList() {
    Get.toNamed(AppRoutes.FRIEND_LIST);
  }

  static void startGroupList() {
    Get.toNamed(AppRoutes.GROUP_LIST);
  }

  static Future<T?>? startFriendInfo<T>({
    required UserInfo userInfo,
    String? groupID,
    bool showMuteFunction = false,
    bool offAllWhenDelFriend = false,
  }) {
    return Get.toNamed(AppRoutes.FRIEND_INFO, arguments: {
      'userInfo': userInfo,
      'groupID': groupID,
      'showMuteFunction': showMuteFunction,
      'offAllWhenDelFriend': offAllWhenDelFriend,
    });
  }

  /// 扫一扫进去
  static Future<T?>? startFriendInfoFromScan<T>({
    required UserInfo info,
  }) {
    return Get.offAndToNamed(AppRoutes.FRIEND_INFO, arguments: {
      'userInfo': info,
      'showMuteFunction': false,
    });
  }

  static Future<T?>? startSearchAddGroup<T>({required GroupInfo info}) {
    return Get.toNamed(AppRoutes.SEARCH_ADD_GROUP, arguments: {
      'info': info,
      'method': JoinGroupMethod.search,
    });
  }

  static Future<T?>? startSearchAddGroupFromScan<T>({required GroupInfo info}) {
    return Get.offAndToNamed(AppRoutes.SEARCH_ADD_GROUP, arguments: {
      'info': info,
      'method': JoinGroupMethod.qrcode,
    });
  }

  static void startFriendIDCode({required UserInfo info}) {
    Get.toNamed(AppRoutes.FRIEND_ID_CODE, arguments: info);
  }

  static void startSendFriendRequest({required UserInfo info}) {
    Get.toNamed(AppRoutes.SEND_FRIEND_REQUEST, arguments: info);
  }

  static Future<T?>? startSetFriendRemarksName<T>({required UserInfo info}) {
    return Get.toNamed(AppRoutes.FRIEND_REMARK, arguments: info);
  }

  static void startAddFriend({AddType type = AddType.friend}) {
    Get.toNamed(AppRoutes.ADD_FRIEND, arguments: type);
  }

  static void startAddFriendBySearch() {
    Get.toNamed(
      AppRoutes.ADD_FRIEND_BY_SEARCH,
      arguments: {'searchType': SearchType.user},
    );
  }

  static void startAddGroupBySearch() {
    Get.toNamed(
      AppRoutes.ADD_FRIEND_BY_SEARCH,
      arguments: {'searchType': SearchType.group},
    );
  }

  static Future<T?>? startAcceptFriendRequest<T>({required FriendApplicationInfo apply}) {
    return Get.toNamed(
      AppRoutes.ACCEPT_FRIEND_REQUEST,
      arguments: apply,
    );
  }

  static void startMyQrcode() {
    Get.toNamed(AppRoutes.MY_QRCODE);
  }

  static void startMyInfo() {
    Get.toNamed(AppRoutes.MY_INFO /*, arguments: userInfo*/);
  }

  static void startMyID() {
    Get.toNamed(AppRoutes.MY_ID);
  }

  static void startSetUserName() {
    Get.toNamed(AppRoutes.SETUP_USER_NAME);
  }

  // static void startCall({dynamic data}) {
  //   Get.toNamed(AppRoutes.CALL, arguments: data);
  // }

  static void startCreateGroupInChatSetup({
    required List<ContactsInfo> members,
    required int groupType,
  }) {
    Get.toNamed(
      AppRoutes.CREATE_GROUP_IN_CHAT_SETUP,
      arguments: {'members': members, 'groupType': groupType},
    );
    // Get.offNamed(
    //   AppRoutes.CREATE_GROUP_IN_CHAT_SETUP,
    //   arguments: {'members': members},
    // );
  }

  static void startGroupNameSet({required GroupInfo info}) {
    Get.toNamed(AppRoutes.GROUP_NAME_SETUP, arguments: info);
  }

  static void startModifyMyNicknameInGroup({
    required GroupInfo groupInfo,
    required GroupMembersInfo membersInfo,
  }) {
    Get.toNamed(AppRoutes.MY_GROUP_NICKNAME, arguments: {
      'groupInfo': groupInfo,
      'membersInfo': membersInfo,
    });
  }

  static Future<T?>? startEditAnnouncement<T>({required String groupID}) {
    return Get.toNamed(AppRoutes.GROUP_ANNOUNCEMENT_SETUP, arguments: groupID);
  }

  static void startViewGroupQrcode({required GroupInfo info}) {
    Get.toNamed(AppRoutes.GROUP_QRCODE, arguments: info);
  }

  static Future<T?>? startGroupMemberManager<T>({required GroupInfo info}) {
    return Get.toNamed(
      AppRoutes.GROUP_MEMBER_MANAGER,
      arguments: info,
    );
  }

  static Future<T?>? startGroupMemberList<T>({
    required String gid,
    required OpAction action,
    List<GroupMembersInfo>? list,
    List<String>? defaultCheckedUidList,
  }) {
    return Get.toNamed(
      AppRoutes.GROUP_MEMBER_LIST,
      arguments: {
        'gid': gid,
        'list': list,
        'action': action,
        'defaultCheckedUidList': defaultCheckedUidList,
      },
    );
  }

  static void startViewGroupId({required GroupInfo info}) {
    Get.toNamed(AppRoutes.GROUP_ID, arguments: info);
  }

  static void startJoinGroup() {
    Get.toNamed(AppRoutes.JOIN_GROUP);
  }

  static void startAccountSetup() {
    Get.toNamed(AppRoutes.ACCOUNT_SETUP);
  }

  static void startAboutUs() {
    Get.toNamed(AppRoutes.ABOUT_US);
  }

  static void startAddMyMethod() {
    Get.toNamed(AppRoutes.ADD_MY_METHOD);
  }

  static void startBlacklist() {
    Get.toNamed(AppRoutes.BLACKLIST);
  }

  static Future<T?>? startSearchFriend<T>({required List<ContactsInfo> list}) {
    return Get.toNamed(AppRoutes.SEARCH_FRIEND, arguments: list);
  }

  static Future<T?>? startSearchGroup<T>({required List<GroupInfo> list}) {
    return Get.toNamed(AppRoutes.SEARCH_GROUP, arguments: list);
  }

  static Future<T?>? startSearchMember<T>({
    required String groupID,
    GroupMembersInfo? info,
    OpAction? action,
  }) {
    return Get.toNamed(AppRoutes.SEARCH_MEMBER, arguments: {
      'groupID': groupID,
      'info': info,
      'action': action,
    });
  }

  static void startCallRecords() {
    Get.toNamed(AppRoutes.CALL_RECORDS);
  }

  static Future<T?>? startScanQrcode<T>() {
    return Get.to(() => QrcodeView());
  }

  static Future<T?>? startLanguageSetup<T>() {
    return Get.toNamed(AppRoutes.LANGUAGE_SETUP);
  }

  static void createGroup({
    int groupType = GroupType.general,
    List<String>? defaultCheckedUidList,
  }) async {
    // 发起人
    final myself = OpenIM.iMManager.uid;
    defaultCheckedUidList ??= <String>[];
    if (!defaultCheckedUidList.contains(myself)) {
      defaultCheckedUidList.add(myself);
    }
    var list = await startSelectContacts(
      action: SelAction.CRATE_GROUP,
      defaultCheckedUidList: defaultCheckedUidList,
    );
    if (null != list) {
      startCreateGroupInChatSetup(members: list, groupType: groupType);
    }
  }

  static void applyEnterGroup(GroupInfo info, JoinGroupMethod method) {
    Get.toNamed(AppRoutes.APPLY_ENTER_GROUP, arguments: {
      'info': info,
      'method': method,
    });
  }

  static void startGroupApplication() {
    Get.toNamed(AppRoutes.GROUP_APPLICATION);
  }

  static Future<T?>? startHandleGroupApplication<T>(
    GroupInfo gInfo,
    GroupApplicationInfo aInfo,
  ) {
    return Get.toNamed(AppRoutes.HANDLE_GROUP_APPLICATION, arguments: {
      'aInfo': aInfo,
      'gInfo': gInfo,
    });
  }

  static Future<T?>? startOrganization<T>({
    bool isMultiModel = false,
    DeptInfo? deptInfo,
    List<DeptMemberInfo> checkedList = const [],
  }) {
    return Get.toNamed(
      AppRoutes.ORGANIZATION,
      arguments: {
        'isMultiModel': isMultiModel,
        'deptInfo': deptInfo,
        'checkedList': checkedList,
      },
    );
  }

  static void startForgetPassword({String accountType = "phone"}) {
    Get.toNamed(AppRoutes.FORGET_PASSWORD, arguments: {"accountType": accountType});
  }

  static void startEmojiManage() {
    Get.toNamed(AppRoutes.EMOJI_MANAGE);
  }

  static void startFontSizeSetup() {
    Get.toNamed(AppRoutes.FONT_SIZE);
  }

  static void startTag() {
    Get.toNamed(AppRoutes.TAG);
  }

  static Future<T?>? startTagNew<T>() {
    return Get.toNamed(AppRoutes.TAG_NEW);
  }

  static void startGroupHaveReadList({
    required Message message,
  }) {
    Get.toNamed(AppRoutes.GROUP_HAVE_READ, arguments: {
      'message': message,
    });
  }

  static void startMessageSearch({required ConversationInfo info}) {
    Get.toNamed(AppRoutes.SEARCH_HISTORY_MESSAGE, arguments: info);
  }

  static void startSearchFile({required ConversationInfo info}) {
    Get.toNamed(AppRoutes.SEARCH_FILE, arguments: info);
  }

  /// [type] 0:picture 1:video
  static void startSearchPicture({
    required ConversationInfo info,
    required int type,
  }) {
    Get.toNamed(AppRoutes.SEARCH_PICTURE, arguments: {
      'info': info,
      'type': type,
    });
  }

  static void startSetGroupMemberMute({
    required String groupID,
    required String userID,
  }) {
    Get.toNamed(AppRoutes.SET_MEMBER_MUTE, arguments: {
      'groupID': groupID,
      'userID': userID,
    });
  }

  static startOANotificationList({
    required ConversationInfo info,
  }) {
    return Get.toNamed(AppRoutes.OA_NOTIFICATION_LIST, arguments: info);
  }

  static startSetChatBackground() {
    return Get.toNamed(AppRoutes.SET_BACKGROUND_IMAGE);
  }

  static startLoginPc({required String args}) {
    return Get.offAndToNamed(AppRoutes.LOGIN_PC, arguments: args);
  }

  static startGlobalSearch() {
    return Get.toNamed(AppRoutes.GLOBAL_SEARCH);
  }

  static startExpandChatHistory({
    required SearchResultItems searchResultItems,
    required String searchKey,
  }) {
    return Get.toNamed(
      AppRoutes.GLOBAL_SEARCH_CHAT_HISTORY,
      arguments: {
        'items': searchResultItems,
        'searchKey': searchKey,
      },
    );
  }

  static startPreviewChatHistory({
    required String conversationID,
    required String showName,
    String? faceURL,
    required Message searchMessage,
  }) {
    return Get.toNamed(
      AppRoutes.PREVIEW_CHAT_HISTORY,
      arguments: {
        'conversationID': conversationID,
        'showName': showName,
        'faceURL': faceURL,
        'searchMessage': searchMessage,
      },
    );
  }

  static startSearchOrganization({bool isMultiModel = false}) {
    return Get.toNamed(
      AppRoutes.SEARCH_ORGANIZATION,
      arguments: {'isMultiModel': isMultiModel},
    );
  }

  static startSearchSelectContacts() {
    return Get.toNamed(
      AppRoutes.SEARCH_SELECT_CONTACTS,
      arguments: {},
    );
  }

  static startGroupMemberPermissionSet({required GroupInfo info}) {
    return Get.toNamed(
      AppRoutes.GROUP_MEMBER_PERMISSION,
      arguments: {'info': info},
    );
  }

  static startJoinMeeting() {
    return Get.toNamed(AppRoutes.JOIN_MEETING, arguments: {});
  }

  static startLaunchMeeting() {
    return Get.toNamed(AppRoutes.LAUNCH_MEETING, arguments: {});
  }

  static Future? startGetMoments([String? userID]) {
    return Get.toNamed(AppRoutes.WORK_MOMENTS,
        parameters: userID == null ? null : {'userID': userID});
  }

  // @param type 0:图文 1:视频
  static Future? startPublishMoments([int type = 0]) {
    return Get.toNamed(AppRoutes.WORK_MOMENTS + AppRoutes.PUBLISH_MOMENTS,
        parameters: {'type': type.toString()});
  }

  static Future? startPublishWhoCanView(Map param) {
    return Get.toNamed(AppRoutes.WORK_MOMENTS + AppRoutes.MOMENTS_WHO_CAN_VIEW, arguments: param);
  }

  // @param type 0: 人 1：组织架构 2：群组 3: 人没有统计&没有搜索
  // @param exclusiveUsers 与users的选中互斥
  // @param title 选择成员页的title
  static Future? startMomentsSelectedMember(
      {required List users, List? exclusiveUsers, int type = 0, String? title}) {
    return Get.toNamed(AppRoutes.WORK_MOMENTS + AppRoutes.MOMENTS_SELECTED_MEMBER, arguments: {
      'type': type.toString(),
      'title': title,
      'users': users,
      'exclusiveUsers': exclusiveUsers
    });
  }

  static Future? startMomentsNewMessage() {
    return Get.toNamed(AppRoutes.WORK_MOMENTS + AppRoutes.MOMENTS_NEW_MESSAGE);
  }

  static Future? startMomentsDetail(String id) {
    return Get.toNamed(AppRoutes.WORK_MOMENTS + AppRoutes.MOMENTS_DETAIL, parameters: {'id': id});
  }

  static Future? startOtherMoments(String userID) {
    return Get.toNamed(AppRoutes.WORK_MOMENTS + AppRoutes.OTHERS_MOMENTS,
        parameters: {'userID': userID});
  }

  static startUnlockVerification() {
    return Get.toNamed(
      AppRoutes.UNLOCK_VERIFICATION,
      arguments: {},
    );
  }
}
