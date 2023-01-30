import 'package:get/get.dart';

import 'picture_logic.dart';

class SearchPictureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchPictureLogic());
  }
}
