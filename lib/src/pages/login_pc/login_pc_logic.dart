import 'package:get/get.dart';

class LoginPcLogic extends GetxController {
  late String url;

  @override
  void onInit() {
    url = Get.arguments;
    super.onInit();
  }

  void loginPc() async {}

  void cancel() {
    Get.back();
  }
}
