import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

import '../res/strings.dart';
import '../res/styles.dart';

class ScreenLockTitle extends StatelessWidget {
  const ScreenLockTitle({
    Key? key,
    required this.stream,
  }) : super(key: key);

  final Stream<String> stream;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(StrRes.plsEnterPwd, style: PageStyle.ts_FFFFFF_24sp),
      StreamBuilder(
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData) {
            return Text(
              sprintf(StrRes.lockPwdErrorHint, [snapshot.data]),
              style: PageStyle.ts_D9350D_18sp,
            );
          }
          return SizedBox();
        },
        stream: stream,
      ),
    ]);
  }
}
