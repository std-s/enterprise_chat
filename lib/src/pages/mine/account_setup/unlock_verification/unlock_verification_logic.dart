import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/utils/data_persistence.dart';

class UnlockVerificationLogic extends GetxController {
  final passwordEnabled = false.obs;
  final fingerprintEnabled = false.obs;
  final gestureEnabled = false.obs;
  final biometricsEnabled = false.obs;
  final isSupportedBiometric = false.obs;
  final canCheckBiometrics = false.obs;
  String? lockScreenPwd;
  final auth = LocalAuthentication();
  late List<BiometricType> availableBiometrics;

  @override
  void onInit() {
    checkingSupported();
    lockScreenPwd = DataPersistence.getLockScreenPassword();
    biometricsEnabled.value = DataPersistence.isEnabledBiometric() == true;
    passwordEnabled.value = lockScreenPwd != null;
    super.onInit();
  }

  void checkingSupported() async {
    isSupportedBiometric.value = await auth.isDeviceSupported();
    canCheckBiometrics.value = await auth.canCheckBiometrics;
    availableBiometrics = await auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
    }

    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.weak)) {
      // Specific types of biometrics are available.
      // Use checks like this with caution!
    }
  }

  void toggleBiometricLock() async {
    if (biometricsEnabled.value) {
      await DataPersistence.closeBiometric();
      biometricsEnabled.value = false;
    } else {
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
        await DataPersistence.openBiometric();
        biometricsEnabled.value = true;
      }
    }
  }

  void togglePwdLock() {
    if (passwordEnabled.value) {
      closePwdLock();
    } else {
      openPwdLock();
    }
  }

  void closePwdLock() {
    screenLock(
      context: Get.context!,
      correctString: lockScreenPwd!,
      title: Text(
        StrRes.plsEnterPwd,
        style: PageStyle.ts_FFFFFF_24sp,
      ),
      onUnlocked: () async {
        await DataPersistence.clearLockScreenPassword();
        await DataPersistence.closeBiometric();
        passwordEnabled.value = false;
        biometricsEnabled.value = false;
        Get.back();
      },
    );
  }

  void openPwdLock() {
    final controller = InputController();
    screenLockCreate(
      context: Get.context!,
      inputController: controller,
      title: Text(
        StrRes.plsEnterNewPwd,
        style: PageStyle.ts_FFFFFF_24sp,
      ),
      confirmTitle: Text(
        StrRes.plsConfirmNewPwd,
        style: PageStyle.ts_FFFFFF_24sp,
      ),
      cancelButton: Text(
        StrRes.cancel,
        style: PageStyle.ts_FFFFFF_16sp,
      ),
      onConfirmed: (matchedText) async {
        lockScreenPwd = matchedText;
        await DataPersistence.putLockScreenPassword(matchedText);
        passwordEnabled.value = true;
        Get.back();
      },
      footer: TextButton(
        onPressed: () {
          // Release the confirmation state and return to the initial input state.
          controller.unsetConfirmed();
        },
        child: Text(
          StrRes.resetInput,
          style: PageStyle.ts_1B72EC_16sp,
        ),
      ),
    );
  }
}
