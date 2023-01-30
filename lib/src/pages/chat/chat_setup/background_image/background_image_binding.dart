import 'package:get/get.dart';

import 'background_image_logic.dart';

class BackgroundImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BackgroundImageLogic());
  }
}
