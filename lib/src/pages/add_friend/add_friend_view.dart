import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/search_box.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import 'add_friend_logic.dart';

class AddFriendPage extends StatelessWidget {
  final logic = Get.find<AddFriendLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: logic.getTitle(),
        showShadow: false,
      ),
      backgroundColor: PageStyle.c_F8F8F8,
      body: Column(
        children: [
          Container(
            color: PageStyle.c_FFFFFF,
            child: GestureDetector(
              onTap: () => logic.toSearchPage(),
              behavior: HitTestBehavior.translucent,
              child: SearchBox(
                enabled: false,
                margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 22.w),
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                hintText: logic.isAddFriend
                    ? StrRes.searchUserDescribe
                    : StrRes.searchGroupDescribe,
              ),
            ),
          ),
          if (logic.isAddFriend)
            _buildItemView(
              icon: ImageRes.ic_mineQrCode,
              title: StrRes.myQrcode,
              desc: StrRes.inviteScan,
              alignment: Alignment.bottomCenter,
              showUnderline: true,
              onTap: () => logic.toMyQrcode(),
            ),
          _buildItemView(
              icon: ImageRes.ic_scan,
              title: StrRes.scan,
              desc: StrRes.scanQrcodeCarte,
              alignment: Alignment.topCenter,
              onTap: () => logic.toScanQrcode()),
        ],
      ),
    );
  }

  Widget _buildItemView({
    required String icon,
    required String title,
    required String desc,
    AlignmentGeometry? alignment,
    Function()? onTap,
    bool showUnderline = false,
  }) =>
      Ink(
        color: PageStyle.c_FFFFFF,
        height: 70.h,
        child: InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 26.w),
            decoration: showUnderline
                ? BoxDecoration(
                    border: BorderDirectional(
                      bottom: BorderSide(
                        color: Color(0xFFF1F1F1),
                        width: .5,
                      ),
                    ),
                  )
                : null,
            child: Row(
              children: [
                Image.asset(
                  icon,
                  width: 25.w,
                  height: 25.h,
                  color: Color(0xFF206BED),
                ),
                SizedBox(
                  width: 22.w,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: PageStyle.ts_333333_18sp,
                      ),
                      Text(
                        desc,
                        style: PageStyle.ts_999999_12sp,
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  ImageRes.ic_next,
                  width: 7.w,
                  height: 13.h,
                  color: Color(0xFF999999),
                )
              ],
            ),
          ),
        ),
      );
}
