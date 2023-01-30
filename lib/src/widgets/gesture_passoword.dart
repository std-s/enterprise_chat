import 'package:flutter/material.dart';
import 'package:gesture_password_widget/widget/gesture_password_widget.dart';
import 'package:sprintf/sprintf.dart';

import '../res/strings.dart';
import '../res/styles.dart';

class GesturePasswordView extends StatefulWidget {
  const GesturePasswordView({
    Key? key,
    this.password,
    this.canCancel = true,
    this.maxRetries = 3,
    this.onMaxRetries,
    this.onComplete,
  }) : super(key: key);
  final String? password;
  final bool canCancel;
  final int maxRetries;
  final ValueChanged<int>? onMaxRetries;
  final ValueChanged<String>? onComplete;

  @override
  State<GesturePasswordView> createState() => _GesturePasswordViewState();
}

class _GesturePasswordViewState extends State<GesturePasswordView> {
  final backgroundColor = Color(0xff252534);
  List<int>? password;
  List<int>? confirmPassword;
  late bool isVerifyPassword;
  int retries = 0;

  @override
  void initState() {
    password = widget.password?.split(",").map((e) => int.parse(e)).toList();
    isVerifyPassword = password != null;
    super.initState();
  }

  void onComplete(List<int?> result) {
    if (!mounted) return;
    setState(() {
      if (password == null) {
        password = result.cast<int>();
      } else {
        confirmPassword = result.cast<int>();
        if (isVerifyPassword) {
          if (password != confirmPassword) {
            retries++;
            if (retries == widget.maxRetries) {
              widget.onMaxRetries?.call(retries);
              retries = 0;
            }
          } else {
            widget.onComplete?.call(password!.join(','));
            retries = 0;
          }
        } else {
          if (password == confirmPassword) {
            widget.onComplete?.call(password!.join(','));
            Navigator.pop(context);
          }
        }
      }
    });
  }

  bool get isErrorConfirmPwd =>
      confirmPassword != null && confirmPassword != password;

  bool get isInputFirstPwd => password == null;

  void reset() {
    password = null;
    confirmPassword = null;
  }

  List<Widget> _buildTitle() {
    List<Widget> list = <Widget>[];
    if (isVerifyPassword) {
      list
        ..add(Text(
          StrRes.plsEnterPwd,
          style: PageStyle.ts_FFFFFF_24sp,
        ))
        ..add(Text(
          sprintf(StrRes.lockPwdErrorHint, [retries]),
          style: PageStyle.ts_D9350D_18sp,
        ));
    } else {
      list
        ..add(Text(
          isInputFirstPwd ? StrRes.plsEnterNewPwd : StrRes.plsConfirmNewPwd,
          style: PageStyle.ts_FFFFFF_24sp,
        ))
        ..add(Text(
          isErrorConfirmPwd ? StrRes.gesturePwdConfirmErrorHint : '',
          style: PageStyle.ts_D9350D_18sp,
        ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            ..._buildTitle(),
            Container(
              margin: EdgeInsets.only(top: 30.0),
              child: createXiMiGesturePasswordView(),
            ),
          ],
        ),
      ),
    );
  }

  /// A complex demo.
  /// A line has four dots and supports the effect of the selection by set [hitItem].
  Widget createXiMiGesturePasswordView() {
    return GesturePasswordWidget(
      lineColor: Colors.white,
      errorLineColor: Colors.redAccent,
      singleLineCount: 4,
      identifySize: 50.0,
      minLength: 4,
      hitShowMilliseconds: 40,
      errorItem: Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      normalItem: Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      selectedItem: Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      hitItem: Container(
        width: 15.0,
        height: 15.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      answer: password,
      color: backgroundColor,
      onComplete: onComplete,
    );
  }
}
