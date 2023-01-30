import 'dart:convert';
import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:common_utils/common_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_date/dart_date.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mime_type/mime_type.dart';
import 'package:open_filex/open_filex.dart';
import 'package:openim_enterprise_chat/src/models/contacts_info.dart';
import 'package:openim_enterprise_chat/src/models/group_member_info.dart' as en;
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

import '../core/controller/im_controller.dart';
import '../routes/app_navigator.dart';
import '../sdk_extension/message_manager.dart';
import '../widgets/map_view.dart';
import '../widgets/preview_merge_msg.dart';
import 'http_util.dart';

/// 间隔时间完成某事
class IntervalDo {
  DateTime? last;

  void run({required Function() fuc, int milliseconds = 0}) {
    DateTime now = DateTime.now();
    if (null == last || now.difference(last ?? now).inMilliseconds > milliseconds) {
      last = now;
      fuc();
    }
  }
}

class IMUtil {
  IMUtil._();

  static int _platform = -9;

  static Future<int> getPlatform() async {
    if (_platform == -9) {
      _platform = await IMUtil._platformID(Get.context!);
    }
    return _platform;
  }

  static Future<CroppedFile?> uCrop(String path) {
    return ImageCropper().cropImage(
      sourcePath: path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        IOSUiSettings(
          title: '',
        ),
      ],
    );
  }

  static void copy({required String text}) {
    Clipboard.setData(ClipboardData(text: text));
    // IMWidget.cancel();
    IMWidget.showToast(StrRes.copySuccessfully);
  }

  static List<ISuspensionBean> convertToAZList(List<ISuspensionBean> list) {
    for (int i = 0, length = list.length; i < length; i++) {
      setAzPinyinAndTag(list[i]);
      // String pinyin = PinyinHelper.getPinyinE(list[i].getShowName());
      // String tag = pinyin.substring(0, 1).toUpperCase();
      // list[i].namePinyin = pinyin;
      // if (RegExp("[A-Z]").hasMatch(tag)) {
      //   list[i].tagIndex = tag;
      // } else {
      //   list[i].tagIndex = "#";
      // }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(list);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(list);

    // add topList.
    // contactsList.insertAll(0, topList);
    return list;
  }

  static ISuspensionBean setAzPinyinAndTag(ISuspensionBean info) {
    if (info is ContactsInfo) {
      String pinyin = PinyinHelper.getPinyinE(info.getShowName());
      String tag = pinyin.substring(0, 1).toUpperCase();
      info.namePinyin = pinyin.toUpperCase();
      if (RegExp("[A-Z]").hasMatch(tag)) {
        info.tagIndex = tag;
      } else {
        info.tagIndex = "#";
      }
    } else if (info is en.GroupMembersInfo) {
      String pinyin = PinyinHelper.getPinyinE(info.nickname!);
      if (pinyin.length == 0) {
        info.tagIndex = "#";
      } else {
        String tag = pinyin.substring(0, 1).toUpperCase();
        info.namePinyin = pinyin.toUpperCase();
        if (RegExp("[A-Z]").hasMatch(tag)) {
          info.tagIndex = tag;
        } else {
          info.tagIndex = "#";
        }
      }
    }
    return info;
  }

  static void openPicture(
    List<Message> list, {
    bool replace = false,
    int index = 0,
    String? tag,
  }) async {
    final picInfoList = <PicInfo>[];
    try {
      for (var msg in list) {
        var file;
        var picElem = msg.pictureElem;
        if (null != picElem?.sourcePath && picElem!.sourcePath!.isNotEmpty) {
          file = File(picElem.sourcePath!);
          if (!(await file.exists())) {
            file = null;
          }
        }
        picInfoList.add(PicInfo(
          file: file,
          url: picElem!.sourcePicture?.url,
          id: msg.clientMsgID,
        ));
      }
    } catch (e) {
      print('e:$e');
    }
    replace
        ? Get.off(
            () => previewPic(picList: picInfoList, index: index, tag: tag),
          )
        : Get.to(
            () => previewPic(picList: picInfoList, index: index, tag: tag),
          );
  }

  static void openVideo(Message msg, {bool replace = false}) async {
    replace
        ? Get.off(() => _previewVideo(
              path: msg.videoElem?.videoPath,
              url: msg.videoElem?.videoUrl,
              coverUrl: msg.videoElem?.snapshotUrl,
              tag: msg.clientMsgID,
            ))
        : Get.to(() => _previewVideo(
              path: msg.videoElem?.videoPath,
              url: msg.videoElem?.videoUrl,
              coverUrl: msg.videoElem?.snapshotUrl,
              tag: msg.clientMsgID,
            ));
  }

  static void openFile(Message msg) async {
    var isFrom = msg.sendID != OpenIM.iMManager.uid;
    var fileElem = msg.fileElem;
    if (null != fileElem) {
      var sourcePath = fileElem.filePath;
      var url = fileElem.sourceUrl;
      var fileName = fileElem.fileName;
      var fileSize = fileElem.fileSize;
      var cachePath = '${(await getTemporaryDirectory()).path}/${msg.clientMsgID}_$fileName';
      print('cachePath:$cachePath');
      // 原路径
      var isExitSourcePath = await isExitFile(sourcePath);
      // 自己下载保存路径
      var isExitCachePath = await isExitFile(cachePath);
      // 网络地址
      var isExitNetwork = isNotNullStr(url);
      var availablePath;
      if (isExitSourcePath) {
        availablePath = sourcePath;
      } else if (isExitCachePath) {
        availablePath = cachePath;
      }
      if (null != availablePath) {
        String? mimeType = mime(fileName);
        if (null != mimeType && mimeType.contains('video')) {
          openVideo(Message()
            ..clientMsgID = msg.clientMsgID
            ..videoElem = VideoElem(videoPath: availablePath, videoUrl: url));
        } else if (null != mimeType && mimeType.contains('image')) {
          openPicture([
            Message()
              ..clientMsgID = msg.clientMsgID
              ..pictureElem = PictureElem(
                sourcePath: availablePath,
                sourcePicture: PictureInfo(url: url),
              )
          ]);
        } else {
          OpenFilex.open(availablePath);
        }
      } else {
        print('fileName:$fileName');
        print('fileSize:$fileSize');
        print('sourcePath:$sourcePath');
        print('cachePath:$cachePath');
        print('url:$url');
        // print('logic:$logic');
        if (url == null) return;
        Get.to(() => ChatFilePreview(
              msgId: msg.clientMsgID!,
              name: fileName!,
              size: fileSize!,
              dio: dio,
              url: url,
              available: isExitNetwork || isExitSourcePath,
              cachePath: cachePath,
              onDownloadStart: () {
                IMWidget.showToast(StrRes.startDownload);
              },
              onDownloadFinished: () async {
                String? mimeType = mime(fileName);
                if (null != mimeType) {
                  await saveMediaToGallery(mimeType, cachePath);
                }
                IMWidget.showToast(sprintf(StrRes.fileSaveToPath, [cachePath]));
                if (null != mimeType && mimeType.contains('video')) {
                  openVideo(
                    Message()
                      ..clientMsgID = msg.clientMsgID
                      ..videoElem = VideoElem(
                        videoPath: cachePath,
                        videoUrl: url,
                      ),
                    replace: true,
                  );
                } else if (null != mimeType && mimeType.contains('image')) {
                  openPicture(
                    [
                      Message()
                        ..clientMsgID = msg.clientMsgID
                        ..pictureElem = PictureElem(
                          sourcePath: cachePath,
                          sourcePicture: PictureInfo(url: url),
                        )
                    ],
                    replace: true,
                  );
                } else {
                  openFileByOtherApp(cachePath);
                }
              },
            ));
      }
    }
  }

  static openFileByOtherApp(String path) async {
    OpenResult result = await OpenFilex.open(path);
    if (result.type == ResultType.noAppToOpen) {
      IMWidget.showToast("没有可支持的应用");
    } else if (result.type == ResultType.permissionDenied) {
      IMWidget.showToast("无权限访问");
    } else if (result.type == ResultType.fileNotFound) {
      IMWidget.showToast("文件已失效");
    }
  }

  static saveMediaToGallery(String mimeType, String cachePath) async {
    if (mimeType.contains('video') || mimeType.contains('image')) {
      await ImageGallerySaver.saveFile(cachePath);
    }
  }

  static Widget previewPic({
    required List<PicInfo> picList,
    int index = 0,
    String? tag,
  }) =>
      ChatPicturePreview(
        heroTag: tag,
        picList: picList,
        index: index,
        dio: dio,
        onStartDownload: (url, path) {
          IMWidget.showToast(StrRes.startDownload);
        },
        onDownloadFinished: (url, path) async {
          final result = await ImageGallerySaver.saveFile(path);
          IMWidget.showToast(sprintf(StrRes.picSaveToPath, [result['filePath']]));
        },
      );

  static Widget _previewVideo({String? path, String? url, String? coverUrl, String? tag}) =>
      ChatVideoPlayerView(
        path: path,
        url: url,
        coverUrl: coverUrl,
        heroTag: tag,
        dio: dio,
        onStartDownload: (url, path) {
          IMWidget.showToast(StrRes.startDownload);
        },
        onDownloadFinished: (url, path) async {
          final result = await ImageGallerySaver.saveFile(path);
          IMWidget.showToast(sprintf(StrRes.videoSaveToPath, [result['filePath']]));
        },
      );

  static String parseMsg(
    Message message, {
    bool isConversation = false,
    bool replaceIdToNickname = false,
  }) {
    String content;
    switch (message.contentType) {
      case MessageType.text:
        content = message.content!.trim();
        break;
      case MessageType.at_text:
        content = message.content!.trim();
        try {
          Map map = json.decode(content);
          content = map['text'];
          if (replaceIdToNickname) {
            var list = message.atElem?.atUsersInfo;
            list?.forEach((e) {
              content = content.replaceAll(
                '@${e.atUserID}',
                '@${getAtNickname(e.atUserID!, e.groupNickname!)}',
              );
            });
          }
        } catch (e) {}
        break;
      case MessageType.picture:
        content = '[${StrRes.picture}]';
        break;
      case MessageType.voice:
        content = '[${StrRes.voice}]';
        break;
      case MessageType.video:
        content = '[${StrRes.video}]';
        break;
      case MessageType.file:
        content = '[${StrRes.file}]';
        break;
      case MessageType.location:
        content = '[${StrRes.location}]';
        break;
      case MessageType.merger:
        content = '[${StrRes.chatRecord}]';
        break;
      case MessageType.card:
        content = '[${StrRes.carte}]';
        break;
      case MessageType.quote:
        content = '${message.quoteElem?.text ?? ''}';
        break;
      case MessageType.revoke:
        var isSelf = message.sendID == OpenIM.iMManager.uid;
        if (isSelf) {
          content = '"${StrRes.you}"${StrRes.revokeMsg}';
        } else {
          content = '"${message.senderNickname}"${StrRes.revokeMsg}';
        }
        break;
      case MessageType.advancedRevoke:
        var isSelf = message.sendID == OpenIM.iMManager.uid;
        var map = json.decode(message.content!);
        var info = RevokedInfo.fromJson(map);
        if (message.isSingleChat) {
          // 单聊
          if (isSelf) {
            content = '"${StrRes.you}"${StrRes.revokeMsg}';
          } else {
            content = '"${message.senderNickname}"${StrRes.revokeMsg}';
          }
        } else {
          // 群聊撤回包含：撤回自己消息，群组或管理员撤回其他人消息
          if (info.revokerID == info.sourceMessageSendID) {
            if (isSelf) {
              content = '"${StrRes.you}"${StrRes.revokeMsg}';
            } else {
              content = '"${message.senderNickname}"${StrRes.revokeMsg}';
            }
          } else {
            late String revoker;
            late String sender;
            if (info.revokerID == OpenIM.iMManager.uid) {
              revoker = UILocalizations.you;
            } else {
              revoker = info.revokerNickname!;
            }
            if (info.sourceMessageSendID == OpenIM.iMManager.uid) {
              sender = UILocalizations.you;
            } else {
              sender = info.sourceMessageSenderNickname!;
            }

            content = sprintf(
              UILocalizations.groupOwnerOrAdminRevokeAMsg,
              ['"$revoker"', '"$sender"'],
            );
          }
        }
        break;
      case MessageType.custom_face:
        content = '[${StrRes.customEmoji}]';
        break;
      case MessageType.custom:
        var data = message.customElem!.data;
        var map = json.decode(data!);
        var customType = map['customType'];
        var customData = map['data'];
        switch (customType) {
          case CustomMessageType.call:
            var type = map['data']['type'];
            content = '[${type == 'video' ? StrRes.callVideo : StrRes.callVoice}]';
            break;
          case CustomMessageType.custom_emoji:
            content = '[${StrRes.customEmoji}]';
            break;
          case CustomMessageType.tag_message:
            final text = customData['text'];
            final duration = customData['duration'];
            final url = customData['url'];
            if (text != null) {
              content = text!;
            } else if (url != null) {
              content = '[${StrRes.voice}]';
            } else {
              content = '[${StrRes.unsupportedMessage}]';
            }
            break;
          case CustomMessageType.meeting:
            content = '[${StrRes.meetingMessage}]';
            break;
          case CustomMessageType.blockedByFriend:
            content = StrRes.blockedByFriendHint;
            break;
          case CustomMessageType.deletedByFriend:
            content = sprintf(
              StrRes.deletedByFriendHint,
              [''],
            );
            break;
          default:
            content = '[${StrRes.unsupportedMessage}]';
            break;
        }
        break;
      case MessageType.oaNotification:
        // OA通知
        String detail = message.notificationElem!.detail!;
        var oa = OANotification.fromJson(json.decode(detail));
        content = oa.text!;
        break;
      default:
        // content = '消息内容未解析';
        content = '[${StrRes.unsupportedMessage}]';
        // content = message.content!.trim();
        break;
    }
    return content;
  }

  static bool isNotNullStr(String? str) => null != str && "" != str.trim();

  static Future<bool> isExitFile(String? path) async {
    return isNotNullStr(path) ? await File(path!).exists() : false;
  }

  static bool isMobile(String mobile) {
    RegExp exp =
        RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    return exp.hasMatch(mobile);
  }

  static bool isPhoneNumber(String areaCode, String mobile) {
    if (areaCode == '+86') {
      return isMobile(mobile);
    }
    return true;
  }

  // md5 加密
  static String? generateMD5(String? data) {
    if (null == data) return null;
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return digest.toString();
  }

  static bool isNoEmpty(String? value) {
    return null != value && value.trim().isNotEmpty;
  }

  static List<Message> calChatTimeInterval(
    List<Message> list, {
    bool calculate = true,
  }) {
    if (!calculate) return list;
    var milliseconds = list.first.sendTime!;
    list.first.ext = true;
    var lastShowTimeStamp = milliseconds;
    for (var i = 0; i < list.length; i++) {
      var index = i + 1;
      if (index <= list.length - 1) {
        var date1 = DateUtil.getDateTimeByMs(lastShowTimeStamp);
        var milliseconds = list.elementAt(index).sendTime!;
        var date2 = DateUtil.getDateTimeByMs(milliseconds);
        if (date2.difference(date1).inMinutes > 5) {
          lastShowTimeStamp = milliseconds;
          list.elementAt(index).ext = true;
        }
      }
    }
    return list;
  }

  // static String getChatTimeline(int milliseconds) {
  //   // int milliseconds = nanosecond ~/ (1000 * 1000);
  //   return TimelineUtil.formatA(
  //     milliseconds,
  //     languageCode: Get.locale?.languageCode ?? 'en',
  //   );
  // }
  static String getChatTimeline(int ms, [String formatToday = 'HH:mm']) {
    String format = 'yyyy/MM/dd';
    int locTimeMs = DateTime.now().millisecondsSinceEpoch;
    var languageCode = Get.locale?.languageCode ?? 'zh';

    if (DateUtil.isToday(ms, locMs: locTimeMs)) {
      final t = DateUtil.formatDateMs(ms, format: formatToday);
      print('时间点:$t');
      return t;
    }

    if (DateUtil.isYesterdayByMs(ms, locTimeMs)) {
      final t =
          '${languageCode == 'zh' ? '昨天' : 'Yesterday'} ${DateUtil.formatDateMs(ms, format: 'HH:mm')}';
      return t;
    }

    if (DateUtil.isWeek(ms, locMs: locTimeMs)) {
      final t =
          '${DateUtil.getWeekdayByMs(ms, languageCode: languageCode)} ${DateUtil.formatDateMs(ms, format: 'HH:mm')}';

      return t;
    }

    if (DateUtil.yearIsEqualByMs(ms, locTimeMs)) {
      final t = DateUtil.formatDateMs(ms, format: 'MM/dd HH:mm');
      return t;
    }

    final t = DateUtil.formatDateMs(ms, format: format);

    return t;
  }

  static String getCallTimeline(int milliseconds) {
    if (DateUtil.yearIsEqualByMs(milliseconds, DateUtil.getNowDateMs())) {
      return DateUtil.formatDateMs(milliseconds, format: 'MM/dd');
    } else {
      return DateUtil.formatDateMs(milliseconds, format: 'yyyy/MM/dd');
    }
  }

  static String seconds2HMS(int seconds) {
    int h = 0;
    int m = 0;
    int s = 0;
    int temp = seconds % 3600;
    if (seconds > 3600) {
      h = seconds ~/ 3600;
      if (temp != 0) {
        if (temp > 60) {
          m = temp ~/ 60;
          if (temp % 60 != 0) {
            s = temp % 60;
          }
        } else {
          s = temp;
        }
      }
    } else {
      m = seconds ~/ 60;
      if (seconds % 60 != 0) {
        s = seconds % 60;
      }
    }
    if (h == 0) {
      return '${m < 10 ? '0$m' : m}:${s < 10 ? '0$s' : s}';
    }
    return "${h < 10 ? '0$h' : h}:${m < 10 ? '0$m' : m}:${s < 10 ? '0$s' : s}";
  }

  ///  compress file and get file.
  static Future<File?> compressAndGetPic(File file) async {
    var path = file.path;
    var name = path.substring(path.lastIndexOf("/"));
    var targetPath = await createTempFile(fileName: name, dir: 'pic');
    CompressFormat format = CompressFormat.jpeg;
    if (name.endsWith(".jpg") || name.endsWith(".jpeg")) {
      format = CompressFormat.jpeg;
    } else if (name.endsWith(".png")) {
      format = CompressFormat.png;
    } else if (name.endsWith(".heic")) {
      format = CompressFormat.heic;
    } else if (name.endsWith(".webp")) {
      format = CompressFormat.webp;
    }

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 100,
      minWidth: 480,
      minHeight: 800,
      format: format,
    );
    return result;
  }

  static Future<String> createTempFile({
    required String dir,
    required String fileName,
  }) async {
    var path =
        (Platform.isIOS ? await getTemporaryDirectory() : await getExternalStorageDirectory())
            ?.path;
    File file = File('$path/$dir/$fileName');
    if (!(await file.exists())) {
      file.create(recursive: true);
    }
    return '$path/$dir/$fileName';
  }

  static int compareVersion(String val1, String val2) {
    var arr1 = val1.split(".");
    var arr2 = val2.split(".");
    int length = arr1.length >= arr2.length ? arr1.length : arr2.length;
    int diff = 0;
    int v1;
    int v2;
    for (int i = 0; i < length; i++) {
      v1 = i < arr1.length ? int.parse(arr1[i]) : 0;
      v2 = i < arr2.length ? int.parse(arr2[i]) : 0;
      diff = v1 - v2;
      if (diff == 0)
        continue;
      else
        return diff > 0 ? 1 : -1;
    }
    return diff;
  }

  // Here it is!
  static Size calculateTextSize(
    String text,
    TextStyle style, {
    int maxLines = 1,
    double maxWidth = double.infinity,
  }) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.size;
  }

  static Map<String, List<Message>> groupingMessage(List<Message> list) {
    var group = <String, List<Message>>{};
    list.forEach((message) {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(message.sendTime!);
      final date;
      if (DateUtil.isWeek(message.sendTime!)) {
        // 本周
        date = StrRes.thisWeek;
      } else if (dateTime.isThisMonth) {
        //当月
        date = StrRes.thisMonth;
      } else {
        // 按年月
        date = DateUtil.formatDate(dateTime, format: 'yyyy/MM');
      }
      group[date] = (group[date] ?? <Message>[])..add(message);
    });
    return group;
  }

  /// 通知解析
  static String? parseNotification(
    Message message, {
    bool isConversation = false,
  }) {
    String? text;
    try {
      if (message.contentType! >= 1000) {
        final elem = message.notificationElem!;
        final map = json.decode(elem.detail!);
        switch (message.contentType) {
          case MessageType.groupCreatedNotification:
            {
              final notification = GroupNotification.fromJson(map);
              // a 创建了群聊
              final label = StrRes.createGroupNotification;
              final a = notification.opUser!.nickname;
              text = sprintf(label, [a]);
            }
            break;
          case MessageType.groupInfoSetNotification:
            {
              final notification = GroupNotification.fromJson(map);
              if (notification.group?.notification != null &&
                  notification.group!.notification!.isNotEmpty) {
                return isConversation ? notification.group!.notification! : null;
              }
              // a 修改了群资料
              final label = StrRes.editGroupInfoNotification;
              final a = notification.opUser!.nickname;
              text = sprintf(label, [a]);
            }
            break;
          case MessageType.memberQuitNotification:
            {
              final notification = QuitGroupNotification.fromJson(map);
              // a 退出了群聊
              final label = StrRes.quitGroupNotification;
              final a = notification.quitUser!.nickname;
              text = sprintf(label, [a]);
            }
            break;
          case MessageType.memberInvitedNotification:
            {
              final notification = InvitedJoinGroupNotification.fromJson(map);
              // a 邀请 b 加入群聊
              final label = StrRes.invitedJoinGroupNotification;
              final a = notification.opUser!.nickname;
              final b = notification.invitedUserList!.map((e) => e.nickname!).toList().join('、');
              text = sprintf(label, [a, b]);
            }
            break;
          case MessageType.memberKickedNotification:
            {
              final notification = KickedGroupMemeberNotification.fromJson(map);
              // b 被 a 踢出群聊
              final label = StrRes.kickedGroupNotification;
              final a = notification.opUser!.nickname;
              final b = notification.kickedUserList!.map((e) => e.nickname).toList().join('、');
              text = sprintf(label, [b, a]);
            }
            break;
          case MessageType.memberEnterNotification:
            {
              final notification = EnterGroupNotification.fromJson(map);
              // a 加入了群聊
              final label = StrRes.joinGroupNotification;
              final a = notification.entrantUser!.nickname;
              text = sprintf(label, [a]);
            }
            break;
          case MessageType.dismissGroupNotification:
            {
              final notification = GroupNotification.fromJson(map);
              // a 解散了群聊
              final label = StrRes.dismissGroupNotification;
              final a = notification.opUser!.nickname;
              text = sprintf(label, [a]);
            }
            break;
          case MessageType.groupOwnerTransferredNotification:
            {
              final notification = GroupRightsTransferNoticication.fromJson(map);
              // a 将群转让给了 b
              final label = StrRes.transferredGroupNotification;
              final a = notification.opUser!.nickname;
              final b = notification.newGroupOwner!.nickname;
              text = sprintf(label, [a, b]);
            }
            break;
          case MessageType.groupMemberMutedNotification:
            {
              final notification = MuteMemberNotification.fromJson(map);
              // b 被 a 禁言
              final label = StrRes.muteGroupMemberNotification;
              final a = notification.opUser!.nickname;
              final b = notification.mutedUser!.nickname;
              final c = notification.mutedSeconds;
              print('---------------mutedTime:$c---');
              text = sprintf(label, [b, a, mutedTime(c!)]);
            }
            break;
          case MessageType.groupMemberCancelMutedNotification:
            {
              final notification = MuteMemberNotification.fromJson(map);
              // b 被 a 取消了禁言
              final label = StrRes.muteCancelGroupMemberNotification;
              final a = notification.opUser!.nickname;
              final b = notification.mutedUser!.nickname;
              text = sprintf(label, [b, a]);
            }
            break;
          case MessageType.groupMutedNotification:
            {
              final notification = MuteMemberNotification.fromJson(map);
              // a 开起了群禁言
              final label = StrRes.muteGroupNotification;
              final a = notification.opUser!.nickname;
              text = sprintf(label, [a]);
            }
            break;
          case MessageType.groupCancelMutedNotification:
            {
              final notification = MuteMemberNotification.fromJson(map);
              // a 关闭了群禁言
              final label = StrRes.muteCancelGroupNotification;
              final a = notification.opUser!.nickname;
              text = sprintf(label, [a]);
            }
            break;
          case MessageType.friendAddedNotification:
            {
              // 你们已成为好友
              text = StrRes.friendAddedNotification;
            }
            break;
          case MessageType.burnAfterReadingNotification:
            {
              final notification = BurnAfterReadingNotification.fromJson(map);
              if (notification.isPrivate == true) {
                text = StrRes.openPrivateChatNotification;
              } else {
                text = StrRes.closePrivateChatNotification;
              }
            }
            break;
          case MessageType.groupMemberInfoChangedNotification:
            final notification = GroupMemberInfoChangedNotification.fromJson(map);
            final a = notification.opUser!.nickname;
            text = sprintf(StrRes.groupMemberInfoChangedNotification, [a]);
            break;
        }
      }
    } catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
    }
    return text;
  }

  static String mutedTime(int mss) {
    int days = mss ~/ (60 * 60 * 24);
    int hours = (mss % (60 * 60 * 24)) ~/ (60 * 60);
    int minutes = (mss % (60 * 60)) ~/ 60;
    int seconds = mss % 60;
    return "${_combTime(days, StrRes.day)}${_combTime(hours, StrRes.hour)}${_combTime(minutes, StrRes.minute)}${_combTime(seconds, StrRes.seconds)}";
  }

  static String _combTime(int value, String unit) => value > 0 ? '$value$unit' : '';

  /// 搜索聊天内容显示规则
  static String calContent({
    required String content,
    required String key,
    required TextStyle style,
    required double usedWidth,
  }) {
    // PageStyle.ts_666666_14sp
    var size = calculateTextSize(content, style);
    // 左右间距+头像跟名称的间距+头像dax
    // var usedWidth = 22.w * 2 + 12.w + 42.h;
    var lave = 1.sw - usedWidth;
    if (size.width < lave) {
      return content;
    }
    var index = content.indexOf(key);
    if (index == -1) return content;
    var start = content.substring(0, index);
    var end = content.substring(index);
    var startSize = calculateTextSize(start, style);
    var keySize = calculateTextSize(key, style);
    if (startSize.width + keySize.width > lave) {
      if (start.length - key.length - 4 > 0) {
        return "...${content.substring(start.length - key.length - 4)}";
      } else {
        return "...$end";
      }
    } else {
      return content;
    }
  }

  static dynamic parseCustomMessage(Message message) {
    try {
      switch (message.contentType) {
        case MessageType.custom:
          {
            var data = message.customElem!.data;
            var map = json.decode(data!);
            var customType = map['customType'];
            switch (customType) {
              case CustomMessageType.call:
                {
                  var duration = map['data']['duration'];
                  var state = map['data']['state'];
                  var type = map['data']['type'];
                  var content;
                  switch (state) {
                    case 'beHangup':
                    case 'hangup':
                      content = sprintf(
                        StrRes.callDuration,
                        [IMUtil.seconds2HMS(duration)],
                      );
                      break;
                    case 'cancel':
                      content = StrRes.cancelled;
                      break;
                    case 'beCanceled':
                      content = StrRes.cancelledByCaller;
                      break;
                    case 'reject':
                      content = StrRes.rejected;
                      break;
                    case 'beRejected':
                      content = StrRes.rejectedByCaller;
                      break;
                    case 'timeout':
                      content = StrRes.callTimeout;
                      break;
                    default:
                      break;
                  }
                  if (content != null) {
                    return {
                      'viewType': CustomMessageType.call,
                      'type': type,
                      'content': content,
                    };
                  }
                }
                break;
              case CustomMessageType.custom_emoji:
                map['data']['viewType'] = CustomMessageType.custom_emoji;
                return map['data'];
              case CustomMessageType.tag_message:
                map['data']['viewType'] = CustomMessageType.tag_message;
                return map['data'];
              case CustomMessageType.meeting:
                map['data']['viewType'] = CustomMessageType.meeting;
                return map['data'];
              case CustomMessageType.deletedByFriend:
              case CustomMessageType.blockedByFriend:
                return {'viewType': customType};
            }
          }
      }
    } catch (e) {}
    return null;
  }

  /// 处理消息点击事件
  /// [messageList] 预览图片消息的时候，可用左右滑动
  static void parseClickEvent(
    Message msg, {
    List<Message> messageList = const [],
  }) async {
    if (msg.contentType == MessageType.picture) {
      var list = messageList.where((p0) => p0.contentType == MessageType.picture).toList();
      var index = list.indexOf(msg);
      if (index == -1) {
        IMUtil.openPicture([msg], index: 0, tag: msg.clientMsgID);
      } else {
        IMUtil.openPicture(list, index: index, tag: msg.clientMsgID);
      }
    } else if (msg.contentType == MessageType.video) {
      IMUtil.openVideo(msg);
    } else if (msg.contentType == MessageType.file) {
      IMUtil.openFile(msg);
    } else if (msg.contentType == MessageType.card) {
      var info = ContactsInfo.fromJson(json.decode(msg.content!));
      AppNavigator.startFriendInfo(userInfo: info);
    } else if (msg.contentType == MessageType.merger) {
      Get.to(
        () => PreviewMergeMsg(
          title: msg.mergeElem!.title!,
          messageList: msg.mergeElem!.multiMessage!,
        ),
        preventDuplicates: false,
      );
    } else if (msg.contentType == MessageType.location) {
      var location = msg.locationElem;
      Map detail = json.decode(location!.description!);
      Get.to(() => MapView(
            latitude: location.latitude!,
            longitude: location.longitude!,
            addr1: detail['name'],
            addr2: detail['addr'],
          ));
    } else if (msg.contentType == MessageType.custom_face) {
      var face = msg.faceElem;
      var map = json.decode(face!.data!);
      Get.to(
        () => previewPic(
            picList: [PicInfo(url: map['url'], id: msg.clientMsgID)],
            index: 0,
            tag: msg.clientMsgID),
      );
    }
  }

  // 1 iPhone 2 android  8 android pad 9 iPad
  static Future<int> _platformID(BuildContext context) async {
    if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      var iPad = iosInfo.utsname.machine?.toLowerCase().contains("ipad");

      if (iPad != true) {
        iPad = iosInfo.model?.toLowerCase() == "ipad";
      }

      return iPad == true ? 9 : 1;
    } else {
      // The equivalent of the "smallestWidth" qualifier on Android.
      var shortestSide = MediaQuery.of(context).size.shortestSide;
      // Determine if we should use mobile layout or not, 600 here is
      // a common breakpoint for a typical 7-inch tablet.
      return shortestSide > 600 ? 8 : 2;
    }
  }

  static String buildGroupApplicationID(GroupApplicationInfo info) {
    return '${info.groupID}-${info.creatorUserID}-${info.createTime}-${info.userID}--${info.inviterUserID}';
  }

  static String buildFriendApplicationID(FriendApplicationInfo info) {
    return '${info.fromUserID}-${info.toUserID}-${info.createTime}';
  }

  static String getAtNickname(String atUserID, String atNickname) {
    final imLogic = Get.find<IMController>();
    String nickname = atNickname;
    // if (atUserID == OpenIM.iMManager.uid) {
    //   nickname = StrRes.you;
    // } else
    if (atUserID == imLogic.atAllTag) {
      nickname = StrRes.everyone;
    }
    return nickname;
  }
}
