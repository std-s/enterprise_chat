import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:openim_enterprise_chat/src/common/apis.dart';
import 'package:openim_enterprise_chat/src/res/strings.dart';
import 'package:openim_enterprise_chat/src/widgets/titlebar.dart';

import 'workbench_js_handler.dart';
/*

class WorkbenchPage extends StatelessWidget {
  final logic = Get.find<WorkbenchLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EnterpriseTitleBar.leftTitle(
        title: StrRes.workbench,
      ),
      backgroundColor: PageStyle.c_FFFFFF,
      body: Column(
        children: [],
      ),
    );
  }
}
*/

class WorkbenchPage extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      new _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<WorkbenchPage> {
  final GlobalKey webViewKey = GlobalKey();
  late OpenIMJsHandler jsHandler;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    Apis.getClientConfig().then((value) {
      url = value['discoverPageURL'];
      webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
    });

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: EnterpriseTitleBar.leftTitle(
          title: StrRes.workbench,
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  // contextMenu: contextMenu,
                  // initialUrlRequest: URLRequest(
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  // initialFile: "assets/html/index.html",
                  initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    </head>
    <body>
        <h1>网页测试</h1>
        <script>
            window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                  window.flutter_inappwebview.callHandler('getLoginCertificate').then(function(result) {
                    // print to the console the data coming
                    // from the Flutter side.
                    console.log(JSON.stringify(result));
                    document.getElementById("loginCertificate").innerHTML = JSON.stringify(result);
             });
            });

            function getDeviceInfo(){
              window.flutter_inappwebview.callHandler('getDeviceInfo')
                  .then(function(result) {
                    // print to the console the data coming
                    // from the Flutter side.
                    document.getElementById("deviceInfo").innerHTML = JSON.stringify(result);
                    console.log(JSON.stringify(result));
                });
            }

            function getLoginUserInfo(){
              window.flutter_inappwebview.callHandler('getLoginUserInfo')
                  .then(function(result) {
                    // print to the console the data coming
                    // from the Flutter side.
                    document.getElementById("loginUserInfo").innerHTML = JSON.stringify(result);
                    console.log(JSON.stringify(result));
                });
            }

            function createGroupChat(){
               console.log('创建群聊');
               window.flutter_inappwebview.callHandler('createGroupChat');
            }

            function selectOrganizationMember(){
               console.log('创建群聊');
               window.flutter_inappwebview.callHandler('selectOrganizationMember').then(function(result) {
                    // print to the console the data coming
                    // from the Flutter side.
                    document.getElementById("members").innerHTML = JSON.stringify(result);
                    console.log(JSON.stringify(result));
               });
            }

            function viewUserInfo(){
              var userID = document.getElementById("userID0").value;
              window.flutter_inappwebview.callHandler('viewUserInfo',{'userID':userID});
            }

            function toChat(){
              var userID = document.getElementById("userID1").value;
              window.flutter_inappwebview.callHandler('getUserInfo',userID).then(function(result) {
                    // print to the console the data coming
                    // from the Flutter side.
                   // console.log(result[0].nickname);
                   // console.log(JSON.stringify(result));
                   var userID = result[0].userID;
                   var nickname = result[0].nickname;
                   var faceURL = result[0].faceURL;
                   window.flutter_inappwebview.callHandler('toChat',{'userID':userID,'nickname':nickname,'faceURL':faceURL,'sessionType':1});
              });
            }

            function selectFile(input){
              //获取第一个文件对象 （如果有多张时可使用循环files数组改变多个<img>的 src值）
             var file = input.files[0];
             //判断当前是否支持使用FileReader
             if(window.FileReader){
              //创建读取文件的对象
              var fr = new FileReader();
              //以读取文件字符串的方式读取文件 但是不能直接读取file
              //因为文件的内容是存在file对象下面的files数组中的
              //该方法结束后图片会以data:URL格式的字符串（base64编码）存储在fr对象的result中
              fr.readAsDataURL(file);
              fr.onloadend = function(){
               document.getElementById("image").src = fr.result;
              }
             }
           }

           function openPhotoSheet(){
              window.flutter_inappwebview.callHandler('openPhotoSheet').then(function(result) {
                    // print to the console the data coming
                    // from the Flutter side.
                    console.log(JSON.stringify(result));
                    console.log(result.path);
                    console.log(result.url);
                    document.getElementById("avatar").src = 'file:///'+ result.path;
             });
           }

           function showDialog(){
             window.flutter_inappwebview.callHandler('showDialog',{'title':'原生对话框','rightBtnText':'确认','leftBtnText':'取消'});
           }

        </script>
        登录凭证：<div id="loginCertificate"></div>
        <button onclick="getDeviceInfo()">当前设备信息</button>
        <div id="deviceInfo"></div>
        </br>
         <button onclick="getLoginUserInfo()">当前登录用户信息</button>
        <div id="loginUserInfo"></div>
        </br>
        <button onclick="createGroupChat()">创建群聊</button>
        </br>
        <button onclick="selectOrganizationMember()">选择联系人</button>
        <div id="members"></div>
        </br>
        用户ID: <input id="userID0" type="text" value="1153408799"><button onclick="viewUserInfo()">查看资料</button>
        </br>
        用户ID: <input id="userID1" type="text" value="1153408799"><button onclick="toChat()">去聊天</button>
        </br>
        <input id="file" type="file" onchange="selectFile(this)"/>
        <img id="image" width="100" height="100"/>
        </br>
        <button onclick="openPhotoSheet()">选择头像</button>
        <img id="avatar" width="100" height="100"/>
        <button onclick="showDialog()">显示对话框</button>
    </body>
</html>
                      """),
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    jsHandler = OpenIMJsHandler(controller);
                    jsHandler.register();
                  },
                  onLoadStart: (controller, url) {},
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    // if (![
                    //   "http",
                    //   "https",
                    //   "file",
                    //   "chrome",
                    //   "data",
                    //   "javascript",
                    //   "about"
                    // ].contains(uri.scheme)) {
                    //   if (await canLaunch(url)) {
                    //     // Launch the App
                    //     await launch(
                    //       url,
                    //     );
                    //     // and cancel the request
                    //     return NavigationActionPolicy.CANCEL;
                    //   }
                    // }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {},
                  onConsoleMessage: (controller, consoleMessage) {
                    print('==webview======$consoleMessage');
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
        ])));
  }
}
