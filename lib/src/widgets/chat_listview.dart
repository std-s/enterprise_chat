import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_enterprise_chat/src/widgets/touch_close_keyboard.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({
    Key? key,
    this.onTouch,
    this.onScrollDownLoad,
    this.onScrollUpLoad,
    this.itemCount,
    this.controller,
    required this.itemBuilder,
    this.enabledScrollUpLoad = false,
    this.onScrollToBottom,
    this.onScrollToTop,
  }) : super(key: key);
  final Function()? onTouch;
  final int? itemCount;
  final ScrollController? controller;
  final IndexedWidgetBuilder itemBuilder;

  /// 往下滚动加载，拉取历史消息
  final Future<bool> Function()? onScrollDownLoad;

  /// 往上滚动加载，在搜索消息是定位消息时用到
  final Future<bool> Function()? onScrollUpLoad;

  final Function()? onScrollToBottom;
  final Function()? onScrollToTop;

  /// 是否开启往上滚动加载，在搜索消息是定位消息时用到
  final bool enabledScrollUpLoad;

  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  var _scrollDownLoadMore = true;
  var _scrollUpLoadMore = true;

  bool _fillFirstPage() => true;

  // bool _fillFirstPage() => (widget.itemCount ?? 0) >= widget.pageSize;

  @override
  void initState() {
    /// 默认加载
    _onScrollDownLoadMore();
    widget.controller?.addListener(() {
      var max = widget.controller!.position.maxScrollExtent;
      var offset = widget.controller!.offset;
      print('========max:$max=========offset:$offset=====');
      if (_isBottom) {
        print('-------------ChatListView scroll to bottom');
        widget.onScrollToBottom?.call();
        _onScrollDownLoadMore();
      } else if (_isTop) {
        print('-------------ChatListView scroll to top');
        widget.onScrollToTop?.call();
        if (widget.enabledScrollUpLoad) {
          _onScrollUpLoadMore();
        }
      }
    });
    super.initState();
  }

  bool get _isBottom =>
      widget.controller!.offset >= widget.controller!.position.maxScrollExtent;

  bool get _isTop => widget.controller!.offset <= 0;

  void _onScrollDownLoadMore() {
    widget.onScrollDownLoad?.call().then((hasMore) {
      if (!mounted) return;
      setState(() {
        _scrollDownLoadMore = hasMore;
      });
    });
  }

  void _onScrollUpLoadMore() {
    widget.onScrollUpLoad?.call().then((hasMore) {
      if (!mounted) return;
      setState(() {
        _scrollUpLoadMore = hasMore;
      });
    });
  }

  Widget _buildLoadMoreView() => Container(
        height: 20.h,
        child: CupertinoActivityIndicator(
          color: Colors.blueAccent,
        ),
      );

  // int _length() {
  //   if (widget.itemCount == null || widget.itemCount == 0) {
  //     return 0;
  //   }
  //   return widget.itemCount! /*+ */ /*(_loadMore ? 1 : 0)*/ /* 1*/;
  // }

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      onTouch: widget.onTouch,
      child: Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          reverse: true,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: widget.itemCount ?? 0,
          padding: EdgeInsets.only(top: 10.h),
          controller: widget.controller,
          itemBuilder: (context, index) {
            return _wrapItem(index);
          },
        ),
      ),
    );
  }

  Widget _wrapItem(int index) {
    Widget? loadView;
    final child = widget.itemBuilder(context, index);
    if (index == widget.itemCount! - 1) {
      if (_scrollDownLoadMore) {
        loadView = _buildLoadMoreView();
      } else {
        loadView = SizedBox(); // 没有更多了
      }
      return Column(children: [loadView, child]);
    }
    if (index == 0 && widget.enabledScrollUpLoad) {
      if (_scrollUpLoadMore) {
        loadView = _buildLoadMoreView();
      } else {
        loadView = SizedBox(); // 没有更多了
      }
      return Column(children: [child, loadView]);
    }
    return child;
  }
}
// if (index == widget.itemCount) {
// if (_scrollDownLoadMore) {
// return _buildLoadMoreView();
// }
// return SizedBox(); // 没有更多了
// }
// if (index == 0 && widget.enabledScrollUpLoad) {
// if (_scrollUpLoadMore) {
// return _buildLoadMoreView();
// }
// return SizedBox(); // 没有更多了
// }
// return widget.itemBuilder(context, index);
