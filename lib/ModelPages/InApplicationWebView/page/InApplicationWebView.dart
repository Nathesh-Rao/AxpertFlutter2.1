import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InApplicationWebViewer extends StatefulWidget {
  InApplicationWebViewer(this.data);
  String data;

  @override
  State<InApplicationWebViewer> createState() => _InApplicationWebViewerState();
}

class _InApplicationWebViewerState extends State<InApplicationWebViewer> {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(widget.data)),
            initialOptions: options,
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    print(widget.data);
    super.initState();
  }
}
