import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/utils/im_util.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../widgets/im_widget.dart';
import 'file_logic.dart';

class SearchFilePage extends StatelessWidget {
  final logic = Get.find<SearchFileLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: StrRes.file,
      ),
      body: Obx(() => SmartRefresher(
            controller: logic.refreshController,
            header: WaterDropMaterialHeader(),
            footer: IMWidget.buildFooter(),
            onLoading: logic.onLoad,
            // onRefresh: logic.onRefresh,
            enablePullDown: false,
            enablePullUp: true,
            child: ListView.builder(
              itemCount: logic.messageList.length,
              itemBuilder: (_, index) =>
                  _buildItemView(logic.messageList.reversed.elementAt(index)),
            ),
          )),
    );
  }

  Widget _buildItemView(Message message) => GestureDetector(
        onTap: () => logic.viewFile(message),
        behavior: HitTestBehavior.translucent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
          margin: EdgeInsets.only(bottom: 6.h),
          color: PageStyle.c_FFFFFF,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  AvatarView(
                    size: 30.h,
                    url: message.senderFaceUrl,
                    text: message.senderNickname,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      message.senderNickname!,
                      style: PageStyle.ts_666666_14sp,
                    ),
                  ),
                  Text(
                    IMUtil.getChatTimeline(message.sendTime!),
                    style: PageStyle.ts_999999_12sp,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  FaIcon(
                    CommonUtil.fileIcon(message.fileElem!.fileName!),
                    color: Color(0xFFfec852),
                    size: 40.h,
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.fileElem!.fileName!,
                        style: PageStyle.ts_333333_12sp,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        CommonUtil.formatBytes(message.fileElem!.fileSize!),
                        style: PageStyle.ts_999999_12sp,
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );
}
