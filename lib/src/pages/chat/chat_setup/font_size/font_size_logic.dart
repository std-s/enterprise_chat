import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/common/config.dart';
import 'package:openim_enterprise_chat/src/pages/chat/chat_logic.dart';
import 'package:openim_enterprise_chat/src/utils/data_persistence.dart';

class FontSizeLogic extends GetxController {
  var chatLogic = Get.find<ChatLogic>();
  var factor = 1.0.obs;

  @override
  void onInit() {
    factor.value = DataPersistence.getChatFontSizeFactor();
    super.onInit();
  }

  void changed(dynamic fac) {
    factor.value = fac;
  }

  void saveFactor() async {
    await chatLogic.changeFontSize(factor.value);
    // Get.back();
  }

  void reset() async {
    await chatLogic.changeFontSize(factor.value = Config.textScaleFactor);
  }
}
