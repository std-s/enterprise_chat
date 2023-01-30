import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaterMarkBgView extends StatelessWidget {
  final String? path;
  final String text;
  final TextStyle? textStyle;
  final Widget child;
  final Widget? floatView;

  const WaterMarkBgView({
    Key? key,
    this.path,
    this.text = '',
    this.textStyle,
    required this.child,
    this.floatView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (path?.isNotEmpty == true)
            Image.file(File(path!), fit: BoxFit.cover),
          if (text.isNotEmpty) _buildWaterMarkTextView(context: context),
          child,
          if (null != floatView) floatView!,
        ],
      ),
    );
  }

  Widget _buildWaterMarkTextView({required BuildContext context}) {
    var style = textStyle ??
        TextStyle(
          color: Color(0xFFBEBEBE).withOpacity(0.3),
          fontSize: 18.sp,
          decoration: TextDecoration.none,
        );
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    var size = _textSize(text, style);
    double itemW = size.width;
    double itemH = size.height;

    int rowCount = (screenW / itemW).round() + 1;
    int columnCount = (screenH / itemH).round() + 1;

    double maxW = screenW * 1.5;
    double maxH = screenH * 1.5;

    List<Widget> children = List.filled(
      columnCount * rowCount,
      Container(
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
        // child: Transform(
        //   alignment: Alignment.center,
        //   transform: Matrix4.skewY(-0.4),
        //   child: Center(
        //     child: Text(
        //       text,
        //       style: textStyle,
        //       textAlign: TextAlign.center,
        //       maxLines: 1,
        //     ),
        //   ),
        // ),
      ),
    );
    return Transform(
      transform: Matrix4.skewY(-0.6),
      child: OverflowBox(
        maxWidth: maxW,
        maxHeight: maxH,
        alignment: Alignment.center,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 50.w,
          runSpacing: 100.h,
          children: children,
        ),
        // child: GridView(
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: rowCount,
        //   ),
        //   physics: NeverScrollableScrollPhysics(),
        //   children: children,
        // ),
      ),
    );
  }

  // Here it is!
  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
