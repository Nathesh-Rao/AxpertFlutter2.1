import 'dart:async';
import 'dart:io';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_downloader_flutter/file_downloader_flutter.dart';

class InApplicationWebViewer extends StatefulWidget {
  InApplicationWebViewer(this.data);

  String data;

  @override
  State<InApplicationWebViewer> createState() => _InApplicationWebViewerState();
}

class _InApplicationWebViewerState extends State<InApplicationWebViewer> {
  dynamic argumentData = Get.arguments;
  MenuHomePageController menuHomePageController = Get.find();

  // final Completer<InAppWebViewController> _controller = Completer<InAppWebViewController>();
  late InAppWebViewController _webViewController;

  // final _key = UniqueKey();
  var hasAppBar = false;
  bool _progressBarActive = true;
  late StreamSubscription subscription;
  CookieManager cookieManager = CookieManager.instance();
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'ico', 'xlsx', 'xls', 'docx', 'doc', 'pdf'];

  @override
  void initState() {
    super.initState();
    try {
      if (argumentData != null) widget.data = argumentData[0];
      if (argumentData != null) hasAppBar = argumentData[1] ?? false;
    } catch (e) {}
    // widget.data = "https://amazon.in"
    print(widget.data);
    clearCookie();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      menuHomePageController.switchPage.value = false;
    });
    //Navigator.pop(context);
  }

  InAppWebViewSettings settings = InAppWebViewSettings(
    transparentBackground: true,
    javaScriptEnabled: true,
    // incognito: true,
    javaScriptCanOpenWindowsAutomatically: true,
    useOnDownloadStart: true,
    useShouldOverrideUrlLoading: true,
    // mediaPlaybackRequiresUserGesture: false,
    useHybridComposition: false,
    hardwareAcceleration: false,
  );

  void _download(String url) async {
    try {
      print("download Url: $url");
      String fname = url.split('/').last.split('.').first;
      print("download FileName: $fname");
      FileDownloaderFlutter().urlFileSaver(url: url, fileName: fname);
    } catch (e) {
      print(e.toString());
    }
  }

  void _download_old(String url) async {
    if (Platform.isAndroid) {
      try {
        print("download Url: $url");
        String fname = url.split('/').last.split('.').first;
        print("download FileName: $fname");
        FileDownloaderFlutter().urlFileSaver(url: url, fileName: fname);
      } catch (e) {
        print(e.toString());
      }
    }

    if (Platform.isIOS) {
      var status = await Permission.storage.request().isGranted;
      if (status) {
        Directory documents = await getApplicationDocumentsDirectory();
        print(documents.path);
        await FlutterDownloader.enqueue(
          url: url,
          // fileName: "Download.pdf",
          savedDir: documents.path,
          showNotification: true, // show download progress in status bar (for Android)
          openFileFromNotification: true, // click on notification to open downloaded file (for Android)
        );

        // print("Task id: $taskId");
      } else {
        print("Permission Denied");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: hasAppBar == true
            ? AppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                centerTitle: false,
                title: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/axpert_03.png",
                        height: 25,
                      ),
                      Text(
                        "xpert",
                        style: TextStyle(fontFamily: 'Gellix-Black', color: HexColor("#133884"), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: Builder(builder: (BuildContext context) {
            return Stack(children: <Widget>[
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.data))),
                initialSettings: settings,
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onDownloadStartRequest: (controller, downloadStartRequest) {
                  print("Download");
                  print("Requested url: ${downloadStartRequest.url.toString()}");
                  _download(downloadStartRequest.url.toString());
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print("Console Message received");
                  print(consoleMessage.toString());
                  if (consoleMessage.toString().contains("axm_mainpageloaded")) {
                    try {
                      if (menuHomePageController.switchPage.value == true) {
                        menuHomePageController.switchPage.toggle();
                      } else {
                        Get.back();
                      }
                    } catch (e) {}
                  }
                },
                onProgressChanged: (controller, value) {
                  print('Progress---: $value : DT ${DateTime.now()}');
                  if (value == 100) {
                    setState(() {
                      _progressBarActive = false;
                    });
                  }
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;
                  print("Override url: $uri");
                  if (imageExtensions.any((ext) => uri.toString().endsWith(ext))) {
                    _download(uri.toString());
                    return Future.value(NavigationActionPolicy.CANCEL);
                  }
                  return Future.value(NavigationActionPolicy.ALLOW);
                },
              ),
              _progressBarActive
                  ? Container(
                      color: Colors.white,
                      child: Center(
                        child: SpinKitRotatingCircle(
                          size: 40,
                          itemBuilder: (context, index) {
                            final colors = [MyColors.blue2, MyColors.blue2, MyColors.blue2];
                            final color = colors[index % colors.length];
                            return DecoratedBox(decoration: BoxDecoration(color: color, shape: BoxShape.circle));
                          },
                        ),
                      ))
                  : Stack(),
            ]);
          }),
        ),
        //floatingActionButton: favoriteButton(),
      ),
    );
  }

  void clearCookie() async {
    await cookieManager.deleteAllCookies();
    print("Cookie cleared");
  }
}
