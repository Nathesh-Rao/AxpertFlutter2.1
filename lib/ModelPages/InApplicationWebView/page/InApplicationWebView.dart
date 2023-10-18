import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class InApplicationWebViewer extends StatefulWidget {
  InApplicationWebViewer(this.data);
  String data;

  @override
  State<InApplicationWebViewer> createState() => _InApplicationWebViewerState();
}

class _InApplicationWebViewerState extends State<InApplicationWebViewer> {
  bool _isConnectionAvailable = true;
  bool _progressBarActive = true;
  final Completer<AndroidInAppWebViewController> controllerCompleter = Completer<AndroidInAppWebViewController>();
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        // clearCache: true,
        // incognito: true,
        cacheEnabled: true,
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        useOnDownloadStart: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        horizontalScrollBarEnabled: false,
      ),
      android: AndroidInAppWebViewOptions(
        hardwareAcceleration: true,
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  checkConnection() async {
    var connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      setState(() {
        _isConnectionAvailable = false;
      });

      showDialogBox();
    }
  }

  showDialogBox() => showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text("No Connection"),
            content: const Text('Please check your internet connectivity'),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                    Navigator.pop(context, 'Cancel');
                  },
                  child: Text("Ok")),
            ],
          ));

  @override
  void initState() {
    // print(widget.data);
    super.initState();
    checkConnection();
    // if (Platform.isAndroid) _initForAndroid();
    // if (Platform.isIOS) _initForIOS();
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping("downloader_send_port");
  }

  // Future<void> _initForAndroid() async {
  //   AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  //   WidgetsFlutterBinding.ensureInitialized();
  //
  //   await FlutterDownloader.registerCallback(downloadCallback);
  //   bool isSuccess = await IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
  //   _port.listen((dynamic data) {
  //     String id = data[0];
  //     int status = data[1];
  //     int progress = data[2];
  //     setState(() async {
  //       if (progress == 100 && status == 3) {
  //         await FlutterDownloader.open(taskId: id);
  //       }
  //     });
  //     // _openDownloadedFile(progress, id);
  //   });
  // }

  // _initForIOS() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await FlutterDownloader.registerCallback(downloadCallback);
  //   bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
  //   _port.listen((dynamic data) {
  //     String id = data[0];
  //     int status = data[1];
  //     int progress = data[2];
  //     setState(() {
  //       // print("Progress: $progress and status: $status and sttt: $DownloadTaskStatus.complete; id: $id");
  //       if (progress == 100 && status == 3 && id != null) {
  //         FlutterDownloader.open(taskId: id);
  //         print("Completedddd $status");
  //       }
  //     });
  //     // _openDownloadedFile(progress, id);
  //   });
  // }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  // void _download(String url) async {
  //   if (Platform.isAndroid) {
  //     final deviceInfo = await DeviceInfoPlugin().androidInfo;
  //     var status;
  //     if (deviceInfo.version.sdkInt > 32) {
  //       status = await Permission.photos.request().isGranted;
  //       print(">32");
  //     } else {
  //       status = await Permission.storage.request().isGranted;
  //     }
  //     if (status) {
  //       final id = await FileDownloader.downloadFile(
  //         url: url,
  //         onProgress: (fileName, progress) {
  //           // print("On Progressssss");
  //         },
  //         onDownloadCompleted: (path) {
  //           // print("Download Completed:   $path");
  //           //OpenFile.open(path);
  //           OpenFile.open(path);
  //         },
  //       );
  //     } else {
  //       print('Permission Denied');
  //     }
  //   }
  //   // if(Platform.isAndroid){
  //   //   final deviceInfo = await DeviceInfoPlugin().androidInfo;
  //   //   var status;
  //   //   if (deviceInfo.version.sdkInt > 32) {
  //   //         status = await Permission.photos.request().isGranted;
  //   //         print(">32");
  //   //       } else {
  //   //         status = await Permission.storage.request().isGranted;
  //   //       }
  //   //   if(status){
  //   //     var documents = await AndroidPathProvider.downloadsPath;
  //   //     print(documents);
  //   //     final taskId = await FlutterDownloader.enqueue(
  //   //       url: url,
  //   //       // fileName: "Download.pdf",
  //   //       savedDir: documents,
  //   //       showNotification: true, // show download progress in status bar (for Android)
  //   //       openFileFromNotification: true, // click on notification to open downloaded file (for Android)
  //   //     );
  //   //     print("Task id: $taskId");
  //   //   }
  //   //   else{
  //   //     print("Permission Denied");
  //   //   }
  //   //
  //   // }
  //   if (Platform.isIOS) {
  //     var status = await Permission.storage.request().isGranted;
  //     if (status) {
  //       Directory documents = await getApplicationDocumentsDirectory();
  //       print(documents.path);
  //       final taskId = await FlutterDownloader.enqueue(
  //         url: url,
  //         // fileName: "Download.pdf",
  //         savedDir: documents.path,
  //         showNotification: true, // show download progress in status bar (for Android)
  //         openFileFromNotification: true, // click on notification to open downloaded file (for Android)
  //       );
  //       // print("Task id: $taskId");
  //     } else {
  //       print("Permission Denied");
  //     }
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   super.dispose();
  //   IsolateNameServer.removePortNameMapping('downloader_send_port');
  //   WidgetsBinding.instance.removeObserver(this);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return _isConnectionAvailable ? showWebView() : ShowNoInterNetView();
          },
        ),
      ),
    );
  }

  showWebView() {
    return Stack(
      children: [
        InAppWebView(
          androidOnGeolocationPermissionsShowPrompt: (controller, origin) async {
            return GeolocationPermissionShowPromptResponse(
              allow: true,
              origin: origin,
              retain: true,
            );
          },
          initialUrlRequest: URLRequest(url: Uri.parse(widget.data)),
        ),
        // initialOptions: options,
        // shouldOverrideUrlLoading: (controller, navigationAction) {
        //   return Future.value(NavigationActionPolicy.ALLOW);
        // },
        // onWebViewCreated: (controller) {
        //   _controller = controller;
        // },
        // onDownloadStartRequest: (controller, downloadStartRequest) {
        //   print("started");
        //   _download(downloadStartRequest.url.toString());
        // },
        // androidOnPermissionRequest: (controller, origin, resources) async {
        //   return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
        // },
        // onLoadError: err,
        //   onProgressChanged: (controller, progress) {
        //     if (progress == 100) {
        //       setState(() {
        //         _progressBarActive = false;
        //       });
        //     }
        //   },
        // ),
        _progressBarActive
            ? Container(
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
            : Container()
      ],
    );
  }

  void err(InAppWebViewController c, Uri? cc, int ii, String ss) {
    print("error while load $ss");
  }

  ShowNoInterNetView() {
    return Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        height: 100,
      ),
      Text(
        "No Internet Connection.",
        style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold),
      )
    ]));
  }
}
