import 'dart:async';

import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/core/controller/im_controller.dart';
import 'package:openim_enterprise_chat/src/core/controller/push_controller.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/utils/data_persistence.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';

class SplashLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final pushLogic = Get.find<PushController>();

  var loginCertificate = DataPersistence.getLoginCertificate();

  bool get isExistLoginCertificate =>
      loginCertificate != null && null != uid && null != token;

  String? get uid => loginCertificate?.userID;

  String? get token => loginCertificate?.imToken;

  late StreamSubscription initializedSub;

  @override
  void onInit() {
    initializedSub = imLogic.initializedSubject.listen((value) async {
      print('---------------------initialized---------------------');
      if (isExistLoginCertificate) {
        await _login();
      } else {
        AppNavigator.startLogin();
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  _login() async {
    try {
      print('---------login---------- uid: $uid, token: $token');
      await imLogic.login(uid!, token!);
      print('---------im login success-------');
      pushLogic.login(uid!);
      print('---------jpush login success----');
      AppNavigator.startMain(isAutoLogin: true);
    } catch (e) {
      IMWidget.showToast('$e');
      await DataPersistence.removeLoginCertificate();
      AppNavigator.startLogin();
    }
  }

  @override
  void onClose() {
    initializedSub.cancel();
    super.onClose();
  }
}
