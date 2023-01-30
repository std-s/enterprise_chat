import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/avatar_view.dart';
import 'package:openim_enterprise_chat/src/widgets/search_box.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';
import 'package:sprintf/sprintf.dart';

import '../../res/strings.dart';
import '../../widgets/radio_button.dart';
import 'organization_logic.dart';

class OrganizationPage extends StatelessWidget {
  final logic = Get.find<OrganizationLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        showShadow: false,
        title: logic.deptTreeList.firstOrNull?.name,
        // onTap: logic.backParentTreeNode,
      ),
      backgroundColor: PageStyle.c_F8F8F8,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: PageStyle.c_FFFFFF,
              child: GestureDetector(
                onTap: logic.toSearch,
                behavior: HitTestBehavior.translucent,
                child: SearchBox(
                  enabled: false,
                  margin: EdgeInsets.fromLTRB(22.w, 11.h, 22.w, 0),
                  padding: EdgeInsets.symmetric(horizontal: 13.w),
                ),
              ),
            ),
            Obx(() => _buildTreeTitle()),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() => CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, int index) {
                            final info = logic.deptMemberList.elementAt(index);
                            return _buildStaffView(info);
                          },
                          childCount: logic.deptMemberList.length,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 12.h),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, int index) {
                            final info = logic.subDeptList.elementAt(index);
                            return _buildDepartmentView(info);
                          },
                          childCount: logic.subDeptList.length,
                        ),
                      ),
                    ],
                  )),
            ),
            if (logic.isMultiModel) Obx(() => _buildCountView()),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeTitle() {
    var children = <Widget>[];
    for (var i = 0; i < logic.deptTreeList.length; i++) {
      children.add(GestureDetector(
        onTap: () => logic.openTreeNode(i),
        child: Text(
          logic.deptTreeList.elementAt(i).name ?? '-',
          style: i == logic.deptTreeList.length - 1
              ? PageStyle.ts_1D6BED_14sp
              : PageStyle.ts_000000_14sp,
        ),
      ));
      if (i != logic.deptTreeList.length - 1) {
        children.add(Image.asset(
          ImageRes.ic_subLevel,
          width: 4.w,
          height: 7.h,
        ));
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
      color: PageStyle.c_FFFFFF,
      alignment: Alignment.centerLeft,
      child: Wrap(
        children: children,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10.h,
        spacing: 4.w,
      ),
    );
  }

  Widget _buildDepartmentView(DeptInfo dept) => Ink(
        color: PageStyle.c_FFFFFF,
        height: 57.h,
        child: InkWell(
          onTap: () => logic.openChildNode(dept),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${dept.name}（${dept.memberNum ?? 0}）',
                    style: PageStyle.ts_333333_18sp,
                  ),
                ),
                Image.asset(
                  ImageRes.ic_moreArrow,
                  width: 16.w,
                  height: 16.h,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildStaffView(DeptMemberInfo memberInfo) => Ink(
        color: PageStyle.c_FFFFFF,
        // height: 57.h,
        child: InkWell(
          onTap: () => logic.toggleDeptMember(memberInfo),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Row(
              children: [
                Visibility(
                  visible: logic.isMultiModel,
                  child: Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: Obx(() => RadioButton1(
                          isChecked: logic.checkedList.contains(memberInfo),
                        )),
                  ),
                ),
                AvatarView(
                  size: 42.h,
                  text: memberInfo.nickname,
                  url: memberInfo.faceURL,
                ),
                Expanded(
                  child: Container(
                    height: 57.h,
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(
                          color: Color(0xFFF0F0F0),
                          width: 1,
                        ),
                      ),
                    ),
                    margin: EdgeInsets.only(left: 16.w),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              memberInfo.nickname ?? '',
                              style: PageStyle.ts_333333_16sp,
                            ),
                            // Text(
                            //   '[手机在线]',
                            //   style: PageStyle.ts_999999_12sp,
                            // ),
                          ],
                        ),
                        if (memberInfo.position != null)
                          _buildTagView(memberInfo.position!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTagView(String tag) => Container(
        height: 17.h,
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.only(
          left: 10.w,
          right: 10.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.5),
          border: Border.all(
            color: PageStyle.c_A2C9F8,
            width: 1,
          ),
        ),
        child: Text(
          tag,
          style: PageStyle.ts_2691ED_10sp,
        ),
      );

  Widget _buildCountView() => Container(
        height: 47.h,
        color: PageStyle.c_FFFFFF,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => _SelectedDeptMemberView());
              },
              behavior: HitTestBehavior.translucent,
              child: RichText(
                text: TextSpan(
                  text: sprintf(StrRes.selectedNum, [logic.checkedList.length]),
                  style: PageStyle.ts_1B72EC_14sp,
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.only(left: 7.w),
                        child: Image.asset(
                          ImageRes.ic_arrowUpBlue,
                          width: 12.w,
                          height: 12.h,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: logic.confirmSelected,
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.only(
                  left: 6.w,
                  right: 3.w,
                  top: 4.h,
                  bottom: 5.h,
                ),
                decoration: BoxDecoration(
                    color: PageStyle.c_1B72EC.withOpacity(
                      logic.checkedList.isNotEmpty ? 1 : 0.7,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: PageStyle.c_000000_opacity15p,
                        blurRadius: 4,
                      ),
                    ]),
                child: Text(
                  sprintf(StrRes.confirmNum, [logic.checkedList.length, 998]),
                  style: PageStyle.ts_FFFFFF_14sp,
                ),
              ),
            ),
          ],
        ),
      );
}

class _SelectedDeptMemberView extends StatelessWidget {
  final logic = Get.find<OrganizationLogic>();

  _SelectedDeptMemberView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PageStyle.c_F6F6F6,
      appBar: EnterpriseTitleBar.back(
        showBackArrow: false,
        showShadow: false,
        actions: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              height: 28.h,
              width: 52.w,
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 10.w),
              decoration: BoxDecoration(
                color: PageStyle.c_1B72EC,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                StrRes.sure,
                style: PageStyle.ts_FFFFFF_16sp,
                // style: TextStyle(
                //   background: Paint()..color = Colors.transparent,
                //   color: Colors.white,
                //   fontSize: 16.sp,
                // ),
              ),
            ),
          )
        ],
      ),
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.only(top: 10.h),
            itemCount: logic.checkedList.length,
            itemBuilder: (_, index) =>
                _buildItemView(logic.checkedList.elementAt(index)),
          )),
    );
  }

  Widget _buildItemView(DeptMemberInfo info) => Container(
        color: PageStyle.c_FFFFFF,
        height: 75.h,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: Row(
          children: [
            AvatarView(
              size: 44.h,
              url: info.faceURL,
              text: info.nickname,
            ),
            Expanded(
              child: Container(
                height: 75.h,
                margin: EdgeInsets.only(left: 14.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(
                      color: PageStyle.c_F0F0F0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      info.nickname ?? '',
                      style: PageStyle.ts_333333_16sp,
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => logic.toggleDeptMember(info),
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        height: 75.h,
                        alignment: Alignment.center,
                        child: Text(
                          StrRes.remove,
                          style: PageStyle.ts_E80000_16sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
}
