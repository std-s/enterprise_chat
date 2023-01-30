import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_enterprise_chat/src/res/images.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';

class AnnouncementDialog extends StatelessWidget {
  const AnnouncementDialog({
    Key? key,
    required this.content,
  }) : super(key: key);
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PageStyle.c_FFFFFF,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 14.h,
              bottom: 26.h,
            ),
            child: Row(
              children: [
                Image.asset(ImageRes.ic_trumpet, width: 16.h, height: 16.h),
                SizedBox(width: 4.w),
                Text(
                  StrRes.groupAnnouncement,
                  style: PageStyle.ts_898989_14sp,
                ),
                Spacer(),
                Text(
                  StrRes.more,
                  style: PageStyle.ts_898989_12sp,
                ),
                Image.asset(
                  ImageRes.ic_next,
                  width: 7.w,
                  height: 12.h,
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    content,
                    style: PageStyle.ts_333333_14sp,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          Container(
            color: PageStyle.c_F5F5F5,
            height: 1,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              StrRes.iKnow,
              style: PageStyle.ts_333333_13sp,
            ),
          ),
        ],
      ),
    );
  }
}
