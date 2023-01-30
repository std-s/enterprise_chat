import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../chat_logic.dart';

class BackgroundImageLogic extends GetxController {
  final _picker = ImagePicker();
  final _chatLogic = Get.find<ChatLogic>();

  openAlbum() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image?.path != null) {
      _buildImage(image!.path);
    }
  }

  openCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (image?.path != null) {
      _buildImage(image!.path);
    }
  }

  _buildImage(String path) async {
    String? value = await CommonUtil.createThumbnail(
      path: path,
      minWidth: 1.sw,
      minHeight: 1.sh,
    );
    if (null != value) _chatLogic.changeBackground(value);
  }

  recover() {
    _chatLogic.clearBackground();
  }
}
