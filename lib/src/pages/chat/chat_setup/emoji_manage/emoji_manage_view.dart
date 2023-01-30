import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:sprintf/sprintf.dart';

import 'emoji_manage_logic.dart';

class EmojiManagePage extends StatelessWidget {
  final logic = Get.find<EmojiManageLogic>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: EnterpriseTitleBar.back(
            title: StrRes.favoriteEmoticons,
            actions: [
              _buildManageButton(),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: FavoriteEmojiListView(
                  emojiList: logic.cacheLogic.urlList,
                  selectedEmojiList: logic.selectedList.value,
                  onAddFavoriteEmoji: logic.addFavorite,
                  enabled: logic.model.value == 1,
                  onChangedSelectedStatus: logic.updateSelectedStatus,
                ),
              ),
              if (logic.model.value == 1) _buildBottomBar(),
            ],
          ),
        ));
  }

  Widget _buildManageButton() => GestureDetector(
        onTap: logic.model.value == 0 ? logic.manage : logic.completed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Text(
            logic.model.value == 0 ? StrRes.manageEmoticons : StrRes.completed,
            style: logic.model.value == 0
                ? PageStyle.ts_333333_14sp
                : PageStyle.ts_1D6BED_14sp,
          ),
        ),
      );

  Widget _buildBottomBar() => Container(
        padding: EdgeInsets.only(left: 22.w),
        decoration: BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(
              color: PageStyle.c_EAEAEA,
              width: 1.h,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              sprintf(StrRes.calEmoticonsNum,
                  [logic.cacheLogic.favoriteList.length]),
              style: PageStyle.ts_999999_16sp,
            ),
            Spacer(),
            GestureDetector(
              onTap: logic.delete,
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
                child: Text(
                  sprintf(StrRes.deleteEmoticons, [logic.selectedList.length]),
                  style: PageStyle.ts_1B61D6_16sp,
                ),
              ),
            ),
          ],
        ),
      );
}
