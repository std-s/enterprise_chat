// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.



void main() async {
  var list = [1, 9, 6, 2, 5, 3];
  list.sort((a, b) {
    if (a > b)
      return -1;
    else if (a < b)
      return 1;
    else
      return 0;
  });
  print('$list');
}
