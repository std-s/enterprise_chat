1. 开发环境，更新该文档时
    - Flutter (stable, 3.3.2)
    - macOS (M1, 12.5)
    - Xcode (13.4)/iOS 13
    - Android Studio (version 2021.2)/Android toolchain - develop for Android devices (Android SDK version 33.0.0)

2. 终端执行以下命令，安装依赖库。

    ```ruby
    cd enterprise_chat/
    fluter clean
    #安装依赖
    flutter pub get
    ```
3. 编译运行：([可选IDE运行](https://docs.flutter.dev/get-started/editor))

    ```ruby
    cd enterprise_chat/
    #如果在苹果设备上运行
    cd ios/
    rm -rf Pods/
    rm -f Podfile.lock
    pod update 
    
    #编译运行
    flutter run
    ```
5. 修改android 的applicationId 和 iOS 的bundle identifier，这些在各个厂商平台申请推送的时候会用到。

- android：替换 io.openim.app.enterprisechat 为自己的 applicationId
- a. /android/app/build.gradle 的 applicationId "io.openim.app.enterprisechat"
- b. /android/app/src/main/AndroidManifest.xml 的 package="io.openim.app.enterprisechat"
- c. /android/app/src/debug/AndroidManifest.xml 的 package="io.openim.app.enterprisechat"
- d.  /android/app/src/profile/AndroidManifest.xml 的 package="io.openim.app.enterprisechat"

- ios: 
- a. 双击Runner.xcworkspace，安装图片进行修改。
- b. 修改bundle identifier，参考工程根目录的 /bundleid.jpg
- c. 修改signing，参考工程根目录的 /signing.jpg

6. 推送：
为简化接入流程，使用个推平台，具体接入流程参考[个推文档](https://docs.getui.com/getui/mobile/vendor/vendor_open)
- 根据文档设置好个推平台
- 找到/android/app/build.gradle，在manifestPlaceholders = [] 填入各厂商的key；
- 特别注意华为等厂商，需要生成签名证书，然后替换/android/app/openim文件，并在/android/app/build.gradle的signingConfigs中替换相关信息；
- 找到/lib/src/core/controller/push_controller.dart，找到“//iOS 配置”，填入个推的相关key；

7. 打包：
- android：在工程的根目录执行 flutter build apk 即生成apk包，位于/enterprise_chat/build/app/outputs/realese
- ios: 在工程的根目录执行 flutter build ios 即生成ipa包，位于/enterprise_chat/build/ios/
