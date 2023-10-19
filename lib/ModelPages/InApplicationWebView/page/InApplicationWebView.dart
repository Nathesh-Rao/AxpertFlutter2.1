import 'dart:async';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class InApplicationWebViewer extends StatefulWidget {
  InApplicationWebViewer(this.data);
  String data;
  @override
  State<InApplicationWebViewer> createState() => _InApplicationWebViewerState();
}

class _InApplicationWebViewerState extends State<InApplicationWebViewer> {
  dynamic argumentData = Get.arguments;
  MenuHomePageController menuHomePageController = Get.find();
  final Completer<InAppWebViewController> _controller = Completer<InAppWebViewController>();
  late InAppWebViewController _webViewController;
  final _key = UniqueKey();
  bool _progressBarActive = true;
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    try {
      if (argumentData != null) widget.data = argumentData[0];
      print("Data: " + widget.data);
    } catch (e) {}
  }

  @override
  void dispose() {
    menuHomePageController.switchPage.value = false;
    //Navigator.pop(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.data);
    return Scaffold(
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: SafeArea(
        child: Builder(builder: (BuildContext context) {
          return Stack(children: <Widget>[
            InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(widget.data)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  incognito: true,
                ),
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadHttpError: (controller, url, statusCode, description) =>
                  print(statusCode.toString() + url.toString() + description),

              onProgressChanged: (controller, value) {
                // print('Progress---: $value');
                if (value == 100) {
                  setState(() {
                    _progressBarActive = false;
                  });
                }
              },

              // set geolocationEnable true or not
            ),
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
                : Stack(),
          ]);
        }),
      ),
      //floatingActionButton: favoriteButton(),
    );
  }
}
