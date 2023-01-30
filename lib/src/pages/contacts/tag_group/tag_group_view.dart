import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/models/tag_group.dart';
import 'package:openim_enterprise_chat/src/pages/contacts/tag_group/tag_group_logic.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/radio_button.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import '../../../widgets/search_box.dart';
import '../../../widgets/titlebar.dart';

class TagGroupPage extends StatelessWidget {
  final logic = Get.find<TagGroupLogic>();

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Obx(
        () => Scaffold(
          appBar: EnterpriseTitleBar.back(
            title: StrRes.tag,
            // actions: [_buildEditButton()],
            showShadow: false,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: logic.newTag,
            child: Icon(Icons.add, size: 40),
            backgroundColor: PageStyle.c_1D6BED,
          ),
          body: Column(
            children: [
              _buildSearchView(),
              logic.tagGroup.isEmpty
                  ? _buildEmptyView()
                  : logic.isSearching
                      ? (logic.searchList.isEmpty
                          ? _buildEmptyView()
                          : _buildSearchListView())
                      : _buildListView()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() => Expanded(
        child: ListView.builder(
          itemCount: logic.tagGroup.length,
          itemBuilder: (_, index) {
            final info = logic.tagGroup.elementAt(index);
            return Obx(
              () => Slidable(
                key: ValueKey(info.tagID!),
                child: _buildItemView(info),
                startActionPane: _buildActionPane(info),
                endActionPane: _buildActionPane(info),
              ),
            );
          },
        ),
      );

  Widget _buildSearchListView() => Expanded(
        child: ListView.builder(
          itemCount: logic.searchList.length,
          itemBuilder: (_, index) {
            final info = logic.searchList.elementAt(index);
            return Obx(
              () => Slidable(
                key: ValueKey(info.tagID!),
                child: _buildItemView(info),
                startActionPane: _buildActionPane(info),
                endActionPane: _buildActionPane(info),
              ),
            );
          },
        ),
      );

  Widget _buildSearchView() => Container(
        margin: EdgeInsets.only(bottom: 14.h),
        color: PageStyle.c_FFFFFF,
        child: SearchBox(
          hintText: StrRes.search,
          controller: logic.controller,
          margin: EdgeInsets.symmetric(
            horizontal: 22.w,
            vertical: 10.h,
          ),
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          enabled: true,
          onChanged: logic.search,
          onCleared: logic.clear,
          clearBtn: Container(
            child: Image.asset(
              ImageRes.ic_clearInput,
              color: Color(0xFF999999),
              width: 20.w,
              height: 20.w,
            ),
          ),
        ),
      );

  ActionPane _buildActionPane(TagInfo info) => ActionPane(
        motion: ScrollMotion(),
        extentRatio: .2,
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (_) => logic.deleteTag(info),
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: StrRes.delete,
          ),
        ],
      );

  Widget _buildItemView(TagInfo info) => GestureDetector(
        onTap: () => logic.toggleCheck(info),
        behavior: HitTestBehavior.translucent,
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          color: PageStyle.c_FFFFFF,
          child: Row(
            children: [
              if (logic.editing.value)
                Container(
                  margin: EdgeInsets.only(right: 28.w),
                  child: RadioButton(
                    style: RadioStyle.BLUE,
                    isChecked: logic.checkList.contains(info),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SearchKeywordText(
                    text: info.tagName!,
                    style: PageStyle.ts_333333_18sp,
                    keyText: logic.key.value,
                    keyStyle: PageStyle.ts_1B61D6_18sp,
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  SizedBox(
                    width: 1.sw - 44.w,
                    child: Text(
                      info.userList!.map((e) => e.userName!).join('、'),
                      style: PageStyle.ts_ADADAD_12sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildEditButton() => GestureDetector(
        onTap: logic.toggleEdit,
        child: Container(
          child: Text(
            logic.editing.value ? StrRes.delete : StrRes.edit,
            style: logic.editing.value
                ? PageStyle.ts_D9350D_14sp
                : PageStyle.ts_333333_14sp,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 5.h,
          ),
        ),
      );

  Widget _buildEmptyView() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 88.h,
          ),
          Center(
            child: Image.asset(
              ImageRes.ic_emptyTag,
              height: 123.h,
            ),
          ),
          Text(
            StrRes.emptyTag,
            style: PageStyle.ts_999999_14sp,
          )
        ],
      );
}
