import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../res/images.dart';
import '../../../res/styles.dart';
import '../../../widgets/avatar_view.dart';
import '../../../widgets/radio_button.dart';
import 'organization_list_logic.dart';

class SelectByOrganizationListView extends StatelessWidget {
  final logic = Get.find<SelectByOrganizationListLogic>();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PageStyle.c_F8F8F8,
      child: Column(
        children: [
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
        ],
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
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(
                  color: Color(0xFFF0F0F0),
                  width: 1,
                ),
              ),
            ),
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

  Widget _buildStaffView(DeptMemberInfo memberInfo) {
    var disabled = logic.isDefaultChecked(memberInfo);
    return Ink(
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
                  child: disabled
                      ? RadioButton1(isChecked: true, enabled: false)
                      : Obx(
                          () => RadioButton1(
                            isChecked: logic.isChecked(memberInfo),
                          ),
                        ),
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
  }

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
}
