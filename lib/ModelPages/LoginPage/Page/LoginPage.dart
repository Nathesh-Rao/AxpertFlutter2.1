import 'dart:io';

import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Controller/LoginController.dart';
import 'package:axpertflutter/ModelPages/LoginPage/EssPortal/EssLoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
              // backgroundColor: loginController.isPortalDefault.value
              //     ? Colors.white
              //     : Color(0xff3764FC),
              backgroundColor: Colors.transparent,
              title: SizedBox(
                width: dropdownWidth,
                child: DropdownButton(
                  isExpanded: true,
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18, color: loginController.isPortalDefault.value ? Colors.black : Colors.white)),
                  dropdownColor: loginController.isPortalDefault.value ? Colors.white : Color(0xff3764FC),
                  iconEnabledColor: loginController.isPortalDefault.value ? Color(0xff3764FC) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  items: loginController.portalDropdownMenuItem(),
                  onChanged: (value) => loginController.portalDropDownItemChanged(value),
                  value: loginController.portalDropdownValue.value,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.toNamed(Routes.ProjectListingPage);
                  },
                  icon: Icon(
                    Icons.settings,
                    color: loginController.isPortalDefault.value ? Colors.black : Colors.white,
                  ),
                ),
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
