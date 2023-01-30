import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';

import '../../../res/strings.dart';
import '../../../res/styles.dart';
import '../../../widgets/avatar_view.dart';
import 'group_list_logic.dart';

class SelectByGroupListView extends StatelessWidget {
  final logic = Get.find<SelectByGroupListLogic>();

  SelectByGroupListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logic.groupList.length,
      itemBuilder: (_, index) =>
          _buildItemView(logic.groupList.elementAt(index)),
    );
  }

  Widget _buildItemView(GroupInfo info) => Ink(
        height: 68.h,
        color: PageStyle.c_FFFFFF,
        child: InkWell(
          onTap: () => logic.selectedGroup(info),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Row(
              children: [
                AvatarView(
                  size: 44.h,
                  url: info.faceURL,
                  isUserGroup: true,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 16.w),
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(
                          color: PageStyle.c_F1F1F1,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 200.w),
                          child: Text(
                            info.groupName ?? '',
                            style: PageStyle.ts_333333_16sp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          sprintf(StrRes.xPerson, [info.memberCount]),
                          style: PageStyle.ts_999999_14sp,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
