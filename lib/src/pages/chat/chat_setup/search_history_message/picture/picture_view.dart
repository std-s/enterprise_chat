import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import 'picture_logic.dart';

class SearchPicturePage extends StatelessWidget {
  final logic = Get.find<SearchPictureLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.back(
        title: logic.isPicture ? StrRes.picture : StrRes.video,
      ),
      backgroundColor: PageStyle.c_FFFFFF,
      body: Obx(
        () => ListView.builder(
          itemCount: logic.groupMessage.length,
          shrinkWrap: true,
          itemBuilder: (_, index) {
            var entry =
                logic.groupMessage.entries.toList().reversed.elementAt(index);
            return ItemWidget(
              list: entry.value,
              label: entry.key,
              onTap: logic.viewPicture,
            );
          },
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  ItemWidget({
    Key? key,
    required this.list,
    required this.label,
    this.onTap,
  }) : super(key: key);
  final String label;
  final List<Message> list;
  final Function(Message message)? onTap;
  final logic = Get.find<SearchPictureLogic>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, top: 20.h),
          child: Text(
            label,
            style: PageStyle.ts_333333_16sp,
          ),
        ),
        SizedBox(height: 6.h),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1.0,
            crossAxisCount: 4,
          ),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (_, index) => _itemView(list.elementAt(index)),
        ),
      ],
    );
  }

  Widget _itemView(Message message) => GestureDetector(
        onTap: () => onTap?.call(message),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: PageStyle.c_D8D8D8,
            ),
          ),
          child: ImageUtil.lowMemoryNetworkImage(
            url: logic.getSnapshotUrl(message),
            width: 94.w,
            fit: BoxFit.cover,
          ),
        ),
      );
}
