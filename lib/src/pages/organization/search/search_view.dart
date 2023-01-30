import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/widgets/im_widget.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import '../../../res/images.dart';
import '../../../res/strings.dart';
import '../../../res/styles.dart';
import '../../../widgets/avatar_view.dart';
import '../../../widgets/radio_button.dart';
import '../../../widgets/search_box.dart';
import '../../../widgets/titlebar.dart';
import 'search_logic.dart';

class SearchOrganizationPage extends StatelessWidget {
  final logic = Get.find<SearchOrganizationLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.searchTitle(
        searchBox: SearchBox(
          controller: logic.searchCtrl,
          focusNode: logic.focusNode,
          enabled: true,
          autofocus: true,
          // margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 22.w),
          // margin: EdgeInsets.fromLTRB(12.w, 0, 0, 0),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          hintText: StrRes.search,
          height: 41.h,
          clearBtn: Container(
            child: Image.asset(
              ImageRes.ic_clearInput,
              color: Color(0xFF999999),
              width: 20.w,
              height: 20.w,
            ),
          ),
          onSubmitted: (v) => logic.search(),
          onCleared: logic.clear,
        ),
      ),
      body: TouchCloseSoftKeyboard(
        child: SmartRefresher(
          controller: logic.refreshCtrl,
          footer: IMWidget.buildFooter(),
          enablePullDown: false,
          enablePullUp: true,
          onLoading: logic.load,
          child: Obx(() => logic.isNotResult
              ? _buildNoSearchResultView()
              : ListView.builder(
                  itemCount: logic.memberList.length,
                  itemBuilder: (_, index) => _buildItemView(
                    logic.memberList.elementAt(index),
                  ),
                )),
        ),
      ),
    );
  }

  Widget _buildItemView(DeptMemberInfo info) => Ink(
        // height: 64.h,
        color: PageStyle.c_FFFFFF,
        child: InkWell(
          onTap: () => logic.viewMemberInfo(info),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Row(
              children: [
                Visibility(
                  visible: logic.isMultiModel,
                  child: Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: Obx(
                      () => RadioButton1(
                        isChecked: logic.isChecked(info),
                      ),
                    ),
                  ),
                ),
                AvatarView(
                  url: info.faceURL,
                  text: info.nickname,
                  size: 42.h,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 14.w),
                    padding: EdgeInsets.only(
                      right: 22.w,
                      top: 7.h,
                      bottom: 7.h,
                    ),
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(
                          color: Color(0xFFF0F0F0),
                          width: 1,
                        ),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SearchKeywordText(
                              text: info.nickname ?? '',
                              keyText: logic.searchCtrl.text.trim(),
                              style: PageStyle.ts_333333_14sp,
                              keyStyle: PageStyle.ts_1B72EC_14sp,
                            ),
                            SizedBox(
                              width: 6.w,
                            ),
                            SearchKeywordText(
                              text: info.position ?? '',
                              keyText: logic.searchCtrl.text.trim(),
                              style: PageStyle.ts_666666_12sp,
                              keyStyle: PageStyle.ts_1B72EC_12sp,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        SearchKeywordText(
                          text: info.parentDepartmentList
                                  ?.map((e) => e.name ?? '')
                                  .join('-') ??
                              '',
                          keyText: logic.searchCtrl.text.trim(),
                          style: PageStyle.ts_ADADAD_10sp,
                          keyStyle: PageStyle.ts_1B72EC_10sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildNoSearchResultView() => Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 162.h,
              ),
              Image.asset(
                ImageRes.ic_searchEmpty,
                width: 163.h,
                height: 163.h,
              ),
              Text(
                StrRes.noSearchResult,
                style: PageStyle.ts_BABABA_16sp,
              )
            ],
          ),
        ),
      );
}
