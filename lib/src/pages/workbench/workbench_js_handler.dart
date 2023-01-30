import 'dart:async';

import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:openim_enterprise_chat/src/models/contacts_info.dart';
import 'package:openim_enterprise_chat/src/pages/conversation/conversation_logic.dart';
import 'package:openim_enterprise_chat/src/routes/app_navigator.dart';
import 'package:openim_enterprise_chat/src/utils/http_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sp_util/sp_util.dart';

import '../../utils/data_persistence.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/im_widget.dart';

class OpenIMJsHandler {
  final InAppWebViewController controller;

  OpenIMJsHandler(this.controller);

  void register() {
    showToast();
    showDialog();
    goBack();
    scanQRCode();
    openPhotoSheet();
    getDeviceInfo();
    createGroupChat();
    getLoginUserInfo();
    getLoginCertificate();
    getUserInfo();
    toChat();
    viewUserInfo();
    selectOrganizationMember();
  }

  void _addJavaScriptHandler(
    String handlerName, {
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    controller.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) {
        return todo?.call(args);
      },
    );
  }

  /// 显示Toast
  void showToast({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('showToast',
        todo: todo ??
            (args) async {
              var msg = args.firstOrNull;
              if (msg is String) {
                IMWidget.showToast(args.firstOrNull);
              }
              return msg;
            });
  }

  /// 显示对话框
  /// {'title':'对话框标题','rightBtnText':'右侧按钮文字','leftBtnText':'左侧按钮文字'}
  void showDialog({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('showDialog',
        todo: todo ??
            (args) async {
              var map = args.firstOrNull;
              if (map is Map) {
                var confirm = await Get.dialog(CustomDialog(
                  title: map['title'],
                  rightText: map['rightBtnText'],
                  leftText: map['leftBtnText'],
                ));
                return confirm;
              }
            });
  }

  /// 显示加载loading
  void showLoading({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('showLoading', todo: todo);
  }

  /// 返回上一页，如果是最后一页直接关闭页面
  /// {'isClose':'是否关闭页面','result':'页面返回值'}
  void goBack({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('goBack', todo: (args) async {
      if (await controller.canGoBack()) {
        controller.goBack();
      } else {
        final map = args.firstOrNull;
        var isClose = true;
        var result;
        if (map is Map) {
          isClose = map['isClose'];
          result = map['result'];
        }
        if (isClose == true) {
          return todo?.call(args) ?? Get.back(result: result);
        } else {
          return todo?.call(args);
        }
      }
    });
  }

  /// 关闭页面
  void close({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('close',
        todo: todo ??
            (args) async {
              var result = args.firstOrNull;
              Get.back(result: result);
              return true;
            });
  }

  /// 重载页面
  void reload({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('reload', todo: (args) async {
      todo?.call(args) ?? controller.reload();
      return true;
    });
  }

  /// 扫码二维码
  void scanQRCode({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('scanQRCode',
        todo: todo ??
            (args) async {
              var result = await AppNavigator.startScanQrcode();
              return result;
            });
  }

  /// 拨打电话
  void makePhoneCall({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('makePhoneCall', todo: todo);
  }

  /// 发送短信
  void sendMsm({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('sendMsm', todo: todo);
  }

  /// 打开相册或拍照菜单
  /// {'crop':'是否裁剪','toUrl':'是否上传返回url'}
  void openPhotoSheet({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('openPhotoSheet',
        todo: todo ??
            (args) async {
              var map = args.firstOrNull;
              var crop = true;
              var toUrl = true;
              if (map is Map) {
                crop = map['crop'] ?? true;
                toUrl = map['toUrl'] ?? true;
              }
              final completer = Completer();
              IMWidget.openPhotoSheet(
                toUrl: toUrl,
                crop: crop,
                onData: (path, url) {
                  completer.complete({'path': path, 'url': url});
                  // return {'path': path, 'url': url};
                },
              );
              return await completer.future;
            });
  }

  /*
  /// 拍照
  void takePhoto({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('takePhoto', todo: todo);
  }

  /// 选择照片
  void openAlbum({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('openAlbum', todo: todo);
  }*/

  /// 获取图片信息
  void getImageInfo({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('getImageInfo', todo: todo);
  }

  /// 压缩图片
  void compressImage({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('compressImage', todo: todo);
  }

  /// 预览图片
  void previewImage({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('previewImage', todo: todo);
  }

  /// 获取设备信息
  void getDeviceInfo({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('getDeviceInfo',
        todo: todo ??
            (args) async {
              final deviceInfoPlugin = DeviceInfoPlugin();
              final deviceInfo = await deviceInfoPlugin.deviceInfo;
              final map = deviceInfo.toMap();
              return map;
            });
  }

  /// 获取app语言
  void getAppLanguage({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('getAppLanguage',
        todo: todo ??
            (args) async {
              var index = DataPersistence.getLanguage();
              switch (index) {
                case 1:
                  return 'zh';
                case 2:
                  return 'en';
                default:
                  return 'default';
              }
            });
  }

  /// 选择文件
  void chooseFile({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('chooseFile', todo: todo);
  }

  /// 获取网络状态
  void getNetworkStatus({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('getNetworkStatus', todo: todo);
  }

  /// 预览文件
  void previewFile({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('previewFile', todo: (args) async {
      // OpenFile.open('');
    });
  }

  /// 下载文件
  void downloadFile({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('downloadFile',
        todo: todo ??
            (args) async {
              var url = args.firstOrNull;
              if (url is String) {
                var name = url.substring(url.lastIndexOf('/'));
                var dir = await getTemporaryDirectory();
                var path = dir.path + name;
                await dio.download(
                  url,
                  path,
                  options: Options(receiveTimeout: 120 * 1000),
                );
                final result = await ImageGallerySaver.saveFile(path);
                IMWidget.showToast('下载成功');
                // OpenFile.open(path);
              }
            });
  }

  /// 上传文件
  void uploadFile({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('uploadFile', todo: todo);
  }

  /// 保存数据
  void setStorage({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('setStorage',
        todo: todo ??
            (args) async {
              var value = args.firstOrNull;
              if (value is String) {
                await SpUtil.putString('webStorage', value);
              }
            });
  }

  /// 获取数据
  void getStorage({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('getStorage',
        todo: todo ??
            (args) async {
              return SpUtil.getString('webStorage');
            });
  }

  /// 删除数据
  void deleteStorage({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('deleteStorage',
        todo: todo ??
            (args) async {
              await SpUtil.remove('webStorage');
            });
  }

  /// 获取登录凭证
  void getLoginCertificate({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('getLoginCertificate',
        todo: todo ??
            (args) async {
              return DataPersistence.getLoginCertificate()?.toJson();
            });
  }

  /// 获取登用户信息
  void getLoginUserInfo({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('getLoginUserInfo',
        todo: todo ??
            (args) async {
              return OpenIM.iMManager.uInfo.toJson();
            });
  }

  /// 获取用户信息
  void getUserInfo({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('getUserInfo',
        todo: todo ??
            (args) async {
              var list = await OpenIM.iMManager.userManager.getUsersInfo(
                uidList: args.map((e) => e.toString()).toList(),
              );
              return list.map((e) => e.toJson()).toList();
            });
  }

  /// 分享
  void share({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('share', todo: todo);
  }

  /// 聊天
  /// {'groupID':'群聊对象群id','userID':'单聊对象用户id','faceURL':'头像','nickname':'昵称'}
  void toChat({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('toChat',
        todo: todo ??
            (args) async {
              var logic = Get.find<ConversationLogic>();
              var map = args.firstOrNull;
              if (map is Map) {
                logic.startChat(
                  groupID: map['groupID'],
                  nickname: map['nickname'],
                  faceURL: map['faceURL'],
                  userID: map['userID'],
                  sessionType: map['sessionType'],
                );
              }
            });
  }

  /// 创建组聊天，如果不带成员列表则跳转app选择类别页。
  /// {'groupType':'群类型','members':[]}
  void createGroupChat({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('createGroupChat',
        todo: todo ??
            (args) async {
              var map = args.firstOrNull;
              var groupType = GroupType.general;
              var members;
              if (map is Map) {
                if (map['groupType'] is int) groupType = map['groupType'];
                members = map['members'];
              }
              if (members is List) {
                final iterable = members.map((e) => ContactsInfo.fromJson(e));
                AppNavigator.startCreateGroupInChatSetup(
                  groupType: groupType,
                  members: iterable.toList(),
                );
              } else {
                return AppNavigator.createGroup(
                  groupType: groupType,
                );
              }
            });
  }

  /// 查看用户信息
  /// 如果不是好友可添加好友，包含进去聊天入口，发起音视频入口
  /// {'userID':'用户id','nickname':'昵称','faceURL':'头像'}
  void viewUserInfo({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('viewUserInfo',
        todo: todo ??
            (args) async {
              var map = args.firstOrNull;
              if (map is Map) {
                AppNavigator.startFriendInfo(
                  userInfo: UserInfo(
                    userID: map['userID'],
                    nickname: map['nickname'],
                    faceURL: map['faceURL'],
                  ),
                );
              }
            });
  }

  /// 选择组织架构成员
  /// {'deptInfo':{},'checkedList':[]}
  void selectOrganizationMember({
    Future<dynamic> Function(List<dynamic> args)? todo,
  }) {
    _addJavaScriptHandler('selectOrganizationMember',
        todo: todo ??
            (args) async {
              var map = args.firstOrNull;
              // var isMultiModel = map['isMultiModel'];
              var deptInfo;
              var checkedList;
              if (map is Map) {
                if (map['deptInfo'] is Map) {
                  deptInfo = DeptInfo.fromJson(map['deptInfo']);
                }
                if (map['checkedList'] is List) {
                  checkedList = (map['checkedList'] as List)
                      .map((e) => DeptMemberInfo.fromJson(e))
                      .toList();
                }
              }

              final list = await AppNavigator.startOrganization(
                isMultiModel: true,
                deptInfo: deptInfo,
                checkedList: checkedList ?? [],
              );
              return list?.map((e) => e.toJson()).toList();
            });
  }
}
