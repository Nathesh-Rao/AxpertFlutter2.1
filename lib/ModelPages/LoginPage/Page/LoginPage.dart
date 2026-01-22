import 'dart:io';

import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Controller/LoginController.dart';
import 'package:axpertflutter/ModelPages/LoginPage/EssPortal/EssLoginPage.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constants/MyColors.dart';
import 'DefaultLoginPageWidget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController loginController = Get.put(LoginController());
  PullToRefreshController pullToRefreshController = PullToRefreshController();
  @override
  Widget build(BuildContext context) {
    var dropdownWidth = MediaQuery.of(context).size.width * .35;

    return Obx(() => PopScope(
          onPopInvoked: (didPop) {
            exit(0);
          },
          // Adding an Appbar for easy switching and to allocate the switching widgets
          child: Scaffold(
            extendBodyBehindAppBar: true,
            // appBar: Platform.isIOS
            //     ? AppBar(
            //         elevation: 0,
            //         toolbarHeight: 1,
            //         backgroundColor: Colors.white,
            //       )
            //     : null,
            //
            //a simple reactive variable [isPortalDefault] is using for the
            //time being to switch colors
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 45,
              // backgroundColor: loginController.isPortalDefault.value
              //     ? Colors.white
              //     : Color(0xff3764FC),
              backgroundColor: Colors.transparent,
              // title: Visibility(
              //   visible: false,
              //   child: SizedBox(
              //     width: dropdownWidth,
              //     child: DropdownButton(
              //       isExpanded: true,
              //       style: GoogleFonts.poppins(
              //           textStyle: TextStyle(
              //               fontWeight: FontWeight.w500,
              //               fontSize: 18,
              //               color: loginController.isPortalDefault.value
              //                   ? Colors.black
              //                   : Colors.white)),
              //       dropdownColor: loginController.isPortalDefault.value
              //           ? Colors.white
              //           : Color(0xff3764FC),
              //       iconEnabledColor: loginController.isPortalDefault.value
              //           ? Color(0xff3764FC)
              //           : Colors.white,
              //       borderRadius: BorderRadius.circular(10),
              //       items: loginController.portalDropdownMenuItem(),
              //       onChanged: (value) =>
              //           loginController.portalDropDownItemChanged(value),
              //       value: loginController.portalDropdownValue.value,
              //     ),
              //   ),
              // ),
              centerTitle: false,
              title: Obx(
                () => !loginController.isOfflineLogin.value
                    ? SizedBox.shrink()
                    : Container(
                        // margin: EdgeInsets.only(top: 5),
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                            color: loginController.isOfflineLogin.value
                                ? MyColors.baseRed.withValues(alpha: 0.1)
                                : MyColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              color: loginController.isOfflineLogin.value
                                  ? MyColors.baseRed
                                  : MyColors.green,
                              size: 12,
                            ),
                            Text(
                              loginController.isOfflineLogin.value
                                  ? "Offline"
                                  : "Online",
                              style: GoogleFonts.poppins(
                                  color: MyColors.AXMDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: IconButton(
                      onPressed: () {
                        Get.toNamed(Routes.ProjectListingPage);
                      },
                      icon: Icon(
                        CupertinoIcons.plus_rectangle_fill_on_rectangle_fill,
                        color: MyColors.AXMDark,
                      )),
                )
              ],
            ),
            resizeToAvoidBottomInset: false,
            body: getLoginWidget(),
          ),
        ));
  }

  Widget getLoginWidget() {
    switch (loginController.portalDropdownValue.value.toLowerCase()) {
      case "ess":
        return EssLoginPage();

      default:
        return DefaultLoginPageWidget();
    }
  }
}
