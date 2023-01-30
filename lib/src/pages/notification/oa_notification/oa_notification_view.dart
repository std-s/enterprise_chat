import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'oa_notification_logic.dart';

class OANotificationPage extends StatelessWidget {
  final logic = Get.find<OANotificationLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: logic.info.showName,
      ),
      backgroundColor: PageStyle.c_F8F8F8,
      body: Obx(() => SmartRefresher(
            controller: logic.refreshController,
            header: IMWidget.buildHeader(),
            footer: IMWidget.buildFooter(),
            enablePullDown: false,
            enablePullUp: true,
            onLoading: () => logic.loadNotification(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              itemCount: logic.messageList.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                final message = logic.messageList.reversed.elementAt(index);
                return _buildItemView(index, message, logic.parse(message));
              },
            ),
          )),
    );
  }

  Widget _buildItemView(int index, Message message, OANotification oa) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 15.h,
          ),
          Text(
            IMUtil.getChatTimeline(message.sendTime!),
            style: PageStyle.ts_999999_12sp,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarView(
                url: oa.notificationFaceURL,
                builder: oa.notificationFaceURL == null
                    ? () => _buildCustomAvatar()
                    : null,
                size: 48.h,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      oa.notificationName!,
                      style: PageStyle.ts_333333_14sp,
                    ),
                    GestureDetector(
                      onTap: () => logic.jump(oa),
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        margin: EdgeInsets.only(top: 8.h),
                        // width: double.infinity,
                        decoration: BoxDecoration(
                          color: PageStyle.c_FFFFFF,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              oa.notificationName!,
                              style: PageStyle.ts_333333_16sp,
                            ),
                            Text(
                              oa.text!,
                              style: PageStyle.ts_999999_12sp,
                            ),
                            if (oa.mixType == 1 ||
                                oa.mixType == 2 ||
                                oa.mixType == 3)
                              Container(
                                margin: EdgeInsets.only(top: 12.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (oa.mixType == 1)
                                      _buildPictureView(message, oa, index),
                                    if (oa.mixType == 2)
                                      _buildVideoView(message, oa, index),
                                    if (oa.mixType == 3)
                                      _buildFileView(message, oa, index),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      );

  Widget _buildPictureView(Message message, OANotification oa, int index) =>
      ChatPictureView(
        msgId: message.clientMsgID!,
        isReceived: true,
        snapshotPath: null,
        snapshotUrl: oa.pictureElem?.snapshotPicture?.url,
        sourcePath: oa.pictureElem?.sourcePath,
        sourceUrl: oa.pictureElem?.sourcePicture?.url,
        // width: oa.pictureElem?.sourcePicture?.width?.toDouble(),
        // height: oa.pictureElem?.sourcePicture?.height?.toDouble(),
        // widgetWidth: 68.w,
        width: 100.w,
        height: 100.w,
        widgetWidth: 100.w,
        index: index,
      );

  // Widget _buildVideoView(OANotification oa, int index) {
  //   final width = oa.videoElem?.snapshotWidth?.toDouble();
  //   final height = oa.videoElem?.snapshotHeight?.toDouble();
  //   final size = logic.calSize(oa, width!, height!);
  //   return Container(
  //     color: Colors.grey,
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         ImageUtil.networkImage(
  //           url: oa.videoElem!.snapshotUrl!,
  //           width: size.width,
  //           height: size.height,
  //           fit: BoxFit.contain,
  //         ),
  //         ImageUtil.play(),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildVideoView(Message message, OANotification oa, int index) =>
      ChatVideoView(
        msgId: message.clientMsgID!,
        isReceived: true,
        snapshotPath: oa.videoElem?.snapshotPath,
        snapshotUrl: oa.videoElem?.snapshotUrl,
        videoPath: oa.videoElem?.videoPath,
        videoUrl: oa.videoElem?.videoUrl,
        width: 100.w,
        height: 100.w,
        widgetWidth: 100.w,
        // width: oa.videoElem?.snapshotWidth?.toDouble(),
        // height: oa.videoElem?.snapshotHeight?.toDouble(),
        index: index,
      );

  Widget _buildFileView(Message message, OANotification oa, int index) =>
      ChatFileView(
        msgId: message.clientMsgID!,
        fileName: oa.fileElem!.fileName!,
        bytes: oa.fileElem!.fileSize ?? 0,
        width: 80.w,
        index: index,
      );

  /// 系统通知自定义头像
  Widget? _buildCustomAvatar() => Container(
        color: PageStyle.c_5496EB,
        height: 48.h,
        width: 48.h,
        alignment: Alignment.center,
        child: FaIcon(
          FontAwesomeIcons.solidBell,
          color: PageStyle.c_FFFFFF,
        ),
      );
}
