import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_codes.dart';
import 'package:country_code_picker/selection_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openim_enterprise_chat/src/pages/chat/group_setup/group_member_manager/member_list/member_list_logic.dart';
import 'package:openim_enterprise_chat/src/pages/register/select_avatar/select_avatar_view.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/utils/http_util.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import 'bottom_sheet_view.dart';

class IMWidget {
  static final ImagePicker _picker = ImagePicker();

  static final List<CountryCode> _countryCodes =
      codes.map((json) => CountryCode.fromJson(json)).toList();

  static void openPhotoSheet({
    Function(String path, String? url)? onData,
    bool crop = true,
    bool toUrl = true,
    bool isAvatar = false,
    bool fromGallery = true,
    bool fromCamera = true,
    Function(int? index)? onIndexAvatar,
  }) {
    Get.bottomSheet(
      BottomSheetView(
        items: [
          if (isAvatar)
            SheetItem(
              label: StrRes.defaultAvatar,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              onTap: () async {
                var index = await Get.to(() => SelectAvatarPage());
                onIndexAvatar?.call(index);
              },
            ),
          if (fromGallery)
            SheetItem(
              label: StrRes.album,
              borderRadius: isAvatar
                  ? null
                  : BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
              onTap: () {
                PermissionUtil.storage(() async {
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (null != image?.path) {
                    var map = await _uCropPic(
                      image!.path,
                      crop: crop,
                      toUrl: toUrl,
                    );
                    onData?.call(map['path'], map['url']);
                  }
                });
              },
            ),
          if (fromCamera)
            SheetItem(
              label: StrRes.camera,
              onTap: () {
                PermissionUtil.camera(() async {
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (null != image?.path) {
                    var map = await _uCropPic(
                      image!.path,
                      crop: crop,
                      toUrl: toUrl,
                    );
                    onData?.call(map['path'], map['url']);
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>> _uCropPic(
    String path, {
    bool crop = true,
    bool toUrl = true,
  }) async {
    CroppedFile? cropFile;
    String? url;
    if (crop) {
      cropFile = await IMUtil.uCrop(path);
      if (cropFile == null) {
        // 放弃选择
        return {'path': cropFile?.path ?? path, 'url': url};
      }
    }
    if (toUrl) {
      if (null != cropFile) {
        print('-----------crop path: ${cropFile.path}');
        url = await HttpUtil.uploadImageForMinio(path: cropFile.path);
      } else {
        print('-----------source path: $path');
        url = await HttpUtil.uploadImageForMinio(path: path);
      }
      print('url:$url');
    }
    return {'path': cropFile?.path ?? path, 'url': url};
  }

  static void showToast(String msg) {
    if (msg.trim().isNotEmpty) EasyLoading.showToast(msg);
  }

  static void openIMCallSheet(
    String label,
    Function(int index) onTapSheetItem,
  ) {
    Get.bottomSheet(
      BottomSheetView(
        itemBgColor: PageStyle.c_FFFFFF,
        items: [
          SheetItem(
            label: sprintf(StrRes.callX, [label]),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            textStyle: PageStyle.ts_666666_16sp,
            height: 53.h,
          ),
          SheetItem(
            label: StrRes.callVoice,
            icon: ImageRes.ic_callVoice,
            alignment: MainAxisAlignment.start,
            onTap: () => onTapSheetItem.call(0),
          ),
          SheetItem(
            label: StrRes.callVideo,
            icon: ImageRes.ic_callVideo,
            alignment: MainAxisAlignment.start,
            onTap: () => onTapSheetItem.call(1),
          ),
        ],
      ),
      // barrierColor: Colors.transparent,
    );
  }

  static void openIMGroupCallSheet({
    required String groupID,
    required Function(int index, List<String> inviteeUserIDList) onTap,
  }) {
    Get.bottomSheet(
      BottomSheetView(
        itemBgColor: PageStyle.c_FFFFFF,
        items: [
          SheetItem(
            label: StrRes.callVoice,
            icon: ImageRes.ic_callVoice,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            alignment: MainAxisAlignment.start,
            onTap: () => _groupCall(groupID, 0, onTap),
          ),
          SheetItem(
            label: StrRes.callVideo,
            icon: ImageRes.ic_callVideo,
            alignment: MainAxisAlignment.start,
            onTap: () => _groupCall(groupID, 1, onTap),
          ),
        ],
      ),
      // barrierColor: Colors.transparent,
    );
  }

  static _groupCall(
    String groupID,
    int index,
    Function(int index, List<String> inviteeUserIDList) onTap,
  ) async {
    var result = await AppNavigator.startGroupMemberList(
      gid: groupID,
      defaultCheckedUidList: [OpenIM.iMManager.uid],
      action: OpAction.GROUP_CALL,
    );
    if (result != null) {
      List<String> uidList = result;
      onTap.call(index, uidList);
    }
  }

  static Future<String?> showCountryCodePicker() async {
    var result = await Get.dialog(Center(
      child: SelectionDialog(
        _countryCodes,
        [],
        showCountryOnly: false,
        // emptySearchBuilder: widget.emptySearchBuilder,
        // searchDecoration: widget.searchDecoration,
        // searchStyle: widget.searchStyle,
        // textStyle: widget.dialogTextStyle,
        // boxDecoration: widget.boxDecoration,
        showFlag: true,
        // flagWidth: widget.flagWidth,
        // flagDecoration: widget.flagDecoration,
        size: Size(1.sw - 60.w, 1.sh * 3 / 4),
        // backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        // hideSearch: true,
        closeIcon: const Icon(Icons.close),
      ),
    ));
    if (null == result) return null;
    return (result as CountryCode).dialCode;
  }

  static void openNoDisturbSettingSheet(
      {bool isGroup = false,
      bool showBlock = true,
      Function(int index)? onTap}) {
    Get.bottomSheet(
      BottomSheetView(
        items: [
          SheetItem(
            label: StrRes.receiveMessageButNotPrompt,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            onTap: () => onTap?.call(0),
          ),
          if (showBlock)
            SheetItem(
              label: isGroup ? StrRes.blockGroupMessages : StrRes.blockFriends,
              onTap: () => onTap?.call(1),
            ),
        ],
      ),
    );
  }

  static Widget buildHeader() => WaterDropMaterialHeader(
        backgroundColor: PageStyle.c_1B72EC,
      );

  static Widget buildFooter() => CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            // body = Text("pull up load");
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            // body = Text("Load Failed!Click retry!");
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.canLoading) {
            // body = Text("release to load more");
            body = CupertinoActivityIndicator();
          } else {
            // body = Text("No more Data");
            body = SizedBox();
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      );

  static void openJoinGroupSettingSheet({Function(int index)? onTap}) {
    Get.bottomSheet(
      BottomSheetView(
        items: [
          SheetItem(
            label: StrRes.allowAnyoneJoinGroup,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            onTap: () => onTap?.call(0),
          ),
          SheetItem(
            label: StrRes.inviteNotVerification,
            onTap: () => onTap?.call(1),
          ),
          SheetItem(
            label: StrRes.needVerification,
            onTap: () => onTap?.call(2),
          ),
        ],
      ),
    );
  }
}
