import 'package:flutter/services.dart';

class PasswordTextInputFormatter extends TextInputFormatter {
  static const String chineseRegex = "[\\u4e00-\\u9fa5]";

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // String oldV = oldValue.text;
    // String newV = newValue.text;
    // int newIndex = newValue.selection.end;
    // int oldIndex = oldValue.selection.end;
    if (oldValue.text.trim() == newValue.text.trim() ||
        newValue.text.contains(" ") ||
        _isContainChinese(newValue) ||
        newValue.text.length > 20) {
      // 输入空格
      return oldValue;
    }
    return newValue;
    // return TextEditingValue(
    //   text: value,
    //   selection: TextSelection.collapsed(offset: selectionIndex),
    // );
  }

  static bool _isContainChinese(TextEditingValue value) =>
      RegExp(chineseRegex).firstMatch(value.text) != null;
}
