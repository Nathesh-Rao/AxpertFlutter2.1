import 'dart:async';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';

class WebViewCalendar extends StatefulWidget {
  String weburl = Const.getFullProjectUrl('aspx/AxMain.aspx?pname=hMy%20Calendar&authKey=AXPERT-') +
      AppStorage().retrieveValue(AppStorage.SESSIONID);

  WebViewCalendar();
  @override
  _WebViewCalendarState createState() => _WebViewCalendarState();
}

class _WebViewCalendarState extends State<WebViewCalendar> {
  final Completer<InAppWebViewController> _controller = Completer<InAppWebViewController>();
  late InAppWebViewController _webViewController;
  final _key = UniqueKey();
  var hasAppBar = false;
  bool _progressBarActive = true;
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //Navigator.pop(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.weburl);
    return Scaffold(
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
                      "assets/images/axpert.png",
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
              initialUrlRequest: URLRequest(url: Uri.parse(widget.weburl)),
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
    );
  }
}
