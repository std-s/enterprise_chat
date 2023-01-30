import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/button.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import 'login_pc_logic.dart';

class LoginPcPage extends StatelessWidget {
  final logic = Get.find<LoginPcLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: StrRes.scanQrLogin,
      ),
      backgroundColor: PageStyle.c_FFFFFF,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 79.h,
            child: FaIcon(
              FontAwesomeIcons.desktop,
              color: PageStyle.c_000000_opacity10p,
              size: 105.h,
            ),
          ),
          Positioned(
            top: 233.h,
            child: Text(
              StrRes.pcLoginConfirmation,
              style: PageStyle.ts_333333_18sp,
            ),
          ),
          Positioned(
            top: 503.h,
            width: 295.w,
            child: Button(
              text: StrRes.confirmLogin,
              textStyle: PageStyle.ts_FFFFFF_18sp,
              height: 44.h,
              enabled: true,
              onTap: logic.loginPc,
            ),
          ),
          Positioned(
            top: 584.h,
            child: GestureDetector(
              onTap: logic.cancel,
              child: Text(
                StrRes.cancelLogin,
                style: PageStyle.ts_999999_18sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
