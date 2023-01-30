import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:openim_enterprise_chat/src/common/config.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/utils/data_persistence.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:openim_enterprise_chat/src/widgets/loading_view.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/controller/app_controller.dart';
import '../../core/controller/cache_controller.dart';
import '../../core/controller/push_controller.dart';
import '../../routes/app_navigator.dart';
import '../../widgets/screen_lock_title.dart';

class HomeLogic extends SuperController {
  final pushLogic = Get.find<PushController>();
  final imLogic = Get.find<IMController>();
  final cacheLogic = Get.find<CacheController>();
  final initLogic = Get.find<AppController>();
  var index = 0.obs;
  var unreadMsgCount = 0.obs;
  var unhandledFriendApplicationCount = 0.obs;
  var unhandledGroupApplicationCount = 0.obs;
  var unhandledCount = 0.obs;
  var organizationInfo = DeptInfo().obs;
  String? lockScreenPwd;
  bool isShowScreenLock = false;
  late bool isAutoLogin;
  final auth = LocalAuthentication();
  late PublishSubject<String> _errorController;

  /// 已读未读本地处理
  // var friendApplicationList = <FriendApplicationInfo>[].obs;
  // var groupApplicationList = <GroupApplicationInfo>[].obs;
  // var friendApplicationProcessing = false;
  // var groupApplicationProcessing = false;
  Function()? onScrollToUnreadMessage;

  void switchTab(int i) {
    index.value = i;
  }

  /// 获取消息未读数
  void getUnreadMsgCount() {
    OpenIM.iMManager.conversationManager.getTotalUnreadMsgCount().then((count) {
      unreadMsgCount.value = int.tryParse(count) ?? 0;
      initLogic.showBadge(unreadMsgCount.value);
    });
  }

  /// 获取好友申请未处理数
  void getUnhandledFriendApplicationCount() async {
    var i = 0;
    var list = await OpenIM.iMManager.friendshipManager.getRecvFriendApplicationList();
    // friendApplicationList.assignAll(list);
    var haveReadList = DataPersistence.getHaveReadUnHandleFriendApplication();
    haveReadList ??= <String>[];
    for (var info in list) {
      var id = IMUtil.buildFriendApplicationID(info);
      if (!haveReadList.contains(id)) {
        if (info.handleResult == 0) i++;
        // if (friendApplicationProcessing) {
        //   haveReadList.add(id);
        // } else {
        //   if (info.handleResult == 0) i++;
        // }
      }
    }
    // DataPersistence.putHaveReadUnHandleFriendApplication(haveReadList);
    unhandledFriendApplicationCount.value = i;
    unhandledCount.value = unhandledGroupApplicationCount.value + i;
  }

  /// 获取群申请未处理数
  void getUnhandledGroupApplicationCount() async {
    var i = 0;
    var list = await OpenIM.iMManager.groupManager.getRecvGroupApplicationList();
    // groupApplicationList.assignAll(list);
    var haveReadList = DataPersistence.getHaveReadUnHandleGroupApplication();
    haveReadList ??= <String>[];
    for (var info in list) {
      var id = IMUtil.buildGroupApplicationID(info);
      if (!haveReadList.contains(id)) {
        if (info.handleResult == 0) i++;
        // if (groupApplicationProcessing) {
        //   haveReadList.add(id);
        // } else {
        //   if (info.handleResult == 0) i++;
        // }
      }
    }
    // DataPersistence.putHaveReadUnHandleGroupApplication(haveReadList);
    unhandledGroupApplicationCount.value = i;
    unhandledCount.value = unhandledFriendApplicationCount.value + i;
  }

  @override
  void onInit() {
    isAutoLogin = Get.arguments['isAutoLogin'];
    _errorController = PublishSubject<String>();
    if (isAutoLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showLockScreenPwd());
    }
    imLogic.unreadMsgCountEventSubject.listen((value) {
      unreadMsgCount.value = value;
    });
    imLogic.friendApplicationChangedSubject.listen((value) {
      getUnhandledFriendApplicationCount();
    });
    imLogic.groupApplicationChangedSubject.listen((value) {
      getUnhandledGroupApplicationCount();
    });
    // imLogic.memberAddedSubject.listen((value) {
    //   getUnhandledGroupApplicationCount();
    // });
    super.onInit();
  }

  @override
  void onReady() {
    // queryClientConfig();
    // queryOrganization();
    getUnreadMsgCount();
    getUnhandledFriendApplicationCount();
    getUnhandledGroupApplicationCount();
    cacheLogic.initCallRecords();
    cacheLogic.initFavoriteEmoji();
    super.onReady();
  }

  @override
  void onClose() {
    _errorController.close();
    super.onClose();
  }

  void _queryOrganization() async {
    var info = await OpenIM.iMManager.organizationManager.getDeptInfo(
      departmentID: '0',
    );
    organizationInfo.update((val) {
      val?.departmentID = info.departmentID;
      val?.faceURL = info.faceURL;
      val?.name = info.name;
      val?.parentID = info.parentID;
      val?.order = info.order;
      val?.departmentType = info.departmentType;
      val?.createTime = info.createTime;
      val?.subDepartmentNum = info.subDepartmentNum;
      val?.memberNum = info.memberNum;
      val?.ex = info.ex;
      val?.attachedInfo = info.attachedInfo;
    });
  }

  String get organizationName => organizationInfo.value.name ?? Config.deptName;

  String get organizationID => organizationInfo.value.departmentID ?? Config.deptID;

  void scrollToUnreadMessage(index) {
    onScrollToUnreadMessage?.call();
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {
    WidgetsBinding.instance.addPostFrameCallback((_) => showLockScreenPwd());
  }

  Future<void> localAuth() async {
    final didAuthenticate = await auth.authenticate(
      localizedReason: '扫描您的指纹（或面部或其他）以进行身份验证',
      options: AuthenticationOptions(
        // stickyAuth: true,
        biometricOnly: true,
      ),
      authMessages: <AuthMessages>[
        AndroidAuthMessages(
          signInTitle: ' ',
          cancelButton: '不，谢谢',
        ),
        IOSAuthMessages(
          cancelButton: '不，谢谢',
        ),
      ],
    );
    if (didAuthenticate) {
      Get.back();
    }
  }

  void showLockScreenPwd() async {
    if (isShowScreenLock) return;
    lockScreenPwd = DataPersistence.getLockScreenPassword();
    if (null != lockScreenPwd) {
      final isEnabledBiometric = DataPersistence.isEnabledBiometric() == true;
      bool enabled = false;
      if (isEnabledBiometric) {
        final isSupportedBiometrics = await auth.isDeviceSupported();
        final canCheckBiometrics = await auth.canCheckBiometrics;
        enabled = isSupportedBiometrics && canCheckBiometrics;
      }
      isShowScreenLock = true;
      screenLock(
        context: Get.context!,
        correctString: lockScreenPwd!,
        maxRetries: 3,
        // title: Text(StrRes.plsEnterPwd, style: PageStyle.ts_FFFFFF_24sp),
        title: ScreenLockTitle(stream: _errorController.stream),
        canCancel: false,
        customizedButtonChild: enabled ? const Icon(Icons.fingerprint) : null,
        customizedButtonTap: enabled ? () async => await localAuth() : null,
        onOpened: enabled ? () async => await localAuth() : null,
        onUnlocked: () {
          isShowScreenLock = false;
          Get.back();
        },
        onMaxRetries: (_) async {
          Get.back();
          await LoadingView.singleton.wrap(asyncFunction: () async {
            await imLogic.logout();
            await DataPersistence.removeLoginCertificate();
            await DataPersistence.clearLockScreenPassword();
            await DataPersistence.closeBiometric();
            pushLogic.logout();
          });
          AppNavigator.startLogin();
        },
        onError: (retries) {
          _errorController.sink.add(
            retries.toString(),
          );
        },
      );
    }
  }
}
