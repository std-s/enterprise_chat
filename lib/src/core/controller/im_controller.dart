import 'dart:io';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/common/config.dart';
import 'package:openim_enterprise_chat/src/core/callback/im_callback.dart';

import '../../../main.dart';
import '../../common/apis.dart';
import '../../utils/data_persistence.dart';
import '../../utils/im_util.dart';

void resident() {
  AliveHelp.invokeMethod("startAudioVideoService");
  AliveHelp.invokeMethod("flutterInitialized");
}

void residentRemove() {
  AliveHelp.invokeMethod("stopService");
}

class IMController extends GetxController with IMCallback {
  late Rx<UserInfo> userInfo;
  late String atAllTag;

  @override
  void onClose() {
    super.close();
    // OpenIM.iMManager.unInitSDK();
    super.onClose();
  }

  @override
  void onInit() async {
    super.onInit();
    // Initialize SDK

    Future.delayed(0.seconds, () {
      initialOpenIM();
    });
  }

  void initialOpenIM() async {
    await OpenIM.iMManager.initSDK(
      platform: await IMUtil.getPlatform(),
      apiAddr: Config.imApiUrl(),
      wsAddr: Config.imWsUrl(),
      dataDir: '${Config.cachePath}/',
      objectStorage: Config.objectStorage(),
      logLevel: 1,
      listener: OnConnectListener(
        onConnecting: () {
          connectionStatus(0);
        },
        onConnectFailed: (code, error) {
          connectionStatus(-1);
        },
        onConnectSuccess: () {
          connectionStatus(1);
        },
        onKickedOffline: kickedOffline,
        onUserSigExpired: () {},
      ),
    );
    if (Platform.isAndroid) saveServerConfig();
    // Set listener
    OpenIM.iMManager
      //
      ..userManager.setUserListener(OnUserListener(
        onSelfInfoUpdated: (u) {
          userInfo.update((val) {
            val?.nickname = u.nickname;
            val?.faceURL = u.faceURL;
            val?.gender = u.gender;
            val?.birth = u.birth;
            val?.birthTime = u.birthTime;
            val?.email = u.email;
            val?.remark = u.remark;
            val?.ex = u.ex;
            val?.globalRecvMsgOpt = u.globalRecvMsgOpt;
          });
          // userInfo.value = u;
        },
      ))
      // Add message listener (remove when not in use)
      ..messageManager.setAdvancedMsgListener(OnAdvancedMsgListener(
        onRecvMessageRevoked: recvMessageRevoked,
        onRecvC2CMessageReadReceipt: recvC2CMessageReadReceipt,
        onRecvNewMessage: recvNewMessage,
        onRecvGroupMessageReadReceipt: recvGroupMessageReadReceipt,
        onRecvMessageRevokedV2: recvMessageRevokedV2,
      ))

      // Set up message sending progress listener
      ..messageManager.setMsgSendProgressListener(OnMsgSendProgressListener(
        onProgress: progressCallback,
      ))

      // Set up friend relationship listener
      ..friendshipManager.setFriendshipListener(OnFriendshipListener(
        onBlacklistAdded: blacklistAdded,
        onBlacklistDeleted: blacklistDeleted,
        onFriendApplicationAccepted: friendApplicationAccepted,
        onFriendApplicationAdded: friendApplicationAdded,
        onFriendApplicationDeleted: friendApplicationDeleted,
        onFriendApplicationRejected: friendApplicationRejected,
        onFriendInfoChanged: friendInfoChanged,
        onFriendAdded: friendAdded,
        onFriendDeleted: friendDeleted,
      ))

      // Set up conversation listener
      ..conversationManager.setConversationListener(OnConversationListener(
        onConversationChanged: conversationChanged,
        onNewConversation: newConversation,
        onTotalUnreadMessageCountChanged: totalUnreadMsgCountChanged,
        // totalUnreadMsgCountChanged: (i) => unreadMsgCountCtrl.addSafely(i),
        onSyncServerFailed: () {
          connectionStatus(4);
        },
        onSyncServerFinish: () {
          connectionStatus(3);
        },
        onSyncServerStart: () {
          connectionStatus(2);
        },
      ))

      // Set up group listener
      ..groupManager.setGroupListener(OnGroupListener(
        onGroupApplicationAccepted: groupApplicationAccepted,
        onGroupApplicationAdded: groupApplicationAdded,
        onGroupApplicationDeleted: groupApplicationDeleted,
        onGroupApplicationRejected: groupApplicationRejected,
        onGroupInfoChanged: groupInfoChanged,
        onGroupMemberAdded: groupMemberAdded,
        onGroupMemberDeleted: groupMemberDeleted,
        onGroupMemberInfoChanged: groupMemberInfoChanged,
        onJoinedGroupAdded: joinedGroupAdded,
        onJoinedGroupDeleted: joinedGroupDeleted,
      ))
      ..workMomentsManager.setWorkMomentsListener(OnWorkMomentsListener(
        onRecvNewNotification: recvNewNotification,
      ))
      ..organizationManager.setOrganizationListener(OnOrganizationListener(
        onOrganizationUpdated: () {},
      ));

    initializedSubject.sink.add(true);
  }

  // Future login(String uid, String token) async {
  //   var user = await OpenIM.iMManager.login(uid: uid, token: token);
  //   userInfo = user.obs;
  //   _queryMyFullInfo();
  //   _queryAtAllTag();
  // }

  Future login(String uid, String token) async {
    var status = await OpenIM.iMManager.getLoginStatus();
    print('---------LoginStatus-------|$status');
    var user;
    if (status == 101 || status == 102) {
      OpenIM.iMManager.isLogined = true;
      OpenIM.iMManager.uid = uid;
      OpenIM.iMManager.token = token;
      user = await OpenIM.iMManager.userManager.getSelfUserInfo();
      OpenIM.iMManager.uInfo = user;
    } else {
      user = await OpenIM.iMManager.login(uid: uid, token: token);
      print('---------im login success-------');
    }
    Future(() => resident());
    userInfo = Rx(user);
    _queryMyFullInfo();
    _queryAtAllTag();
  }

  Future logout() {
    return OpenIM.iMManager.logout();
  }

  /// @所有人ID
  void _queryAtAllTag() async {
    atAllTag = await OpenIM.iMManager.conversationManager.getAtAllTag();
  }

  void _queryMyFullInfo() async {
    final data = await Apis.queryMyFullInfo();
    if (data is Map) {
      userInfo.update((val) {
        val?.allowAddFriend = data['allowAddFriend'];
        val?.allowBeep = data['allowBeep'];
        val?.allowVibration = data['allowVibration'];
      });
    }
  }

  ///存一下配置交给android原生用
  void saveServerConfig() {
    DataPersistence.putServerConfig({
      'serverIP': Config.serverIp(),
      'authUrl': Config.appAuthUrl(),
      'chatTokenUrl': Config.chatTokenUrl(),
      'apiUrl': Config.imApiUrl(),
      'wsUrl': Config.imWsUrl(),
      'objectStorage': Config.objectStorage(),
      'storageDir': '${Config.cachePath}/',
    });
  }
}
