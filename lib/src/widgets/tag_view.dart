import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_enterprise_chat/src/res/styles.dart';

class TagView extends StatelessWidget {
  const TagView({
    Key? key,
    required this.tag,
    this.onTap,
  }) : super(key: key);
  final String tag;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 9.w,
          top: 4.h,
          bottom: 4.h,
          right: 6.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.5),
          border: Border.all(
            color: PageStyle.c_C7C7C8,
            width: 1.h,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: PageStyle.ts_000000_12sp,
            ),
            SizedBox(
              width: 10.w,
            ),
            Icon(
              Icons.close,
              color: Color(0xFF9c9e9f),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
