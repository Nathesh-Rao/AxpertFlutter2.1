import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/HomePage/controller/HomePageController.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/InApplicationWebView/page/InApplicationWebView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  HomePageController homePageController = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: homePageController.onWillPop,
      child: Obx(() => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: false,
              title: Image.asset(
                'assets/images/buzzily-logo.png',
                height: 30,
              ),
              actions: [
                Center(
                  child: Text(
                    homePageController.userName.value,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 2),
                IconButton(
                    onPressed: () {
                      Get.dialog(Dialog(
                        alignment: Alignment.topCenter,
                        backgroundColor: Colors.transparent,
                        child: Container(
                          margin: EdgeInsets.only(top: 40),
                          height: 250,
                          decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                  color: MyColors.buzzilyblack,
                                ),
                                height: 200,
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20),
                                    const CircleAvatar(
                                      radius: 35.0,
                                      backgroundImage: AssetImage(
                                        "assets/images/profile.png",
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(homePageController.userName.value, //main profile name
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: MyColors.white1,
                                          fontSize: 12,
                                          fontFamily: "nunitoreg1",
                                        )),
                                    SizedBox(height: 15),
                                    Container(
                                      height: 30.0,
                                      color: MyColors.buzzilyblack,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Container(
                                          width: 170.0,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(38)),
                                            color: Colors.blue,
                                          ),
                                          padding: const EdgeInsets.fromLTRB(4.0, 5.0, 0.0, 0.0),
                                          child: Column(children: const [
                                            Text(
                                              'Manage Your Account',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: "nunitoreg"),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Center(
                                  child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                ),
                                label: const Text(
                                  'Log Out',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                onPressed: () {},
                              )),
                            ],
                          ),
                        ),
                      ));
                    },
                    icon: Icon(
                      Icons.account_circle_rounded,
                      size: 35,
                      color: Colors.black,
                    )),
                SizedBox(width: 2),
              ],
            ),
            body: IndexedStack(
              index: homePageController.bottomIndex.value,
              children: <Widget>[
                Container(
                  color: Colors.red,
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse('google.com')),
                  ),
                ),
                InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse('google.com')),
                ),
                InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse('google.com')),
                ),
                InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse('google.com')),
                ),
                InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse('google.com')),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.shifting,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                currentIndex: homePageController.bottomIndex.value,
                onTap: (value) => homePageController.indexChange(value),
                items: [
                  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: "Active List"),
                  // BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month_sharp), label: "Calendar"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.notifications_active_outlined), label: "Notification"),
                  BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
                ]),
          )),
    );
  }
}
