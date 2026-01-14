import 'dart:async';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InternetConnectivity extends GetxController {
  var isConnected = false.obs;

  InternetConnectivity() {
    connectivity_listen();
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      isConnected.value = true;
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      isConnected.value = true;
      return true;
    }
    isConnected.value = false;
    showError();
    return false;
  }

  get connectionStatus => check();

  // void showError() {
  //   if (Get.isDialogOpen == true) {
  //     return; // Do nothing if dialog exists
  //   }
  //   Get.defaultDialog(
  //     contentPadding: EdgeInsets.all(10),
  //     titlePadding: EdgeInsets.only(top: 20),
  //     title: "No Connection!",
  //     middleText: "Please check your internet connectivity",
  //     barrierDismissible: false,
  //     //"No Internet Connections are available.\nPlease try again later",
  //     confirm: ElevatedButton(
  //         onPressed: () async {
  //           Get.back();
  //           Timer(Duration(milliseconds: 400), () async {
  //             check().then((value) {
  //               if (value == true) {
  //                 doRefresh(Get.currentRoute);
  //               }
  //             });
  //           });
  //         },
  //         child: Text("Ok")),
  //     // cancel: TextButton(
  //     //     onPressed: () {
  //     //       Get.back();
  //     //     },
  //     //     child: Text("Ok"))
  //   );
  // }
  void showError() {
    if (Get.isDialogOpen == true) {
      return;
    }

    const String tag = "[OFFLINE_DIALOG_001]";

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // block back button
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===== ICON =====
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.wifi_off,
                    size: 34,
                    color: Colors.redAccent,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "No Connection",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: MyColors.AXMDark,
                  ),
                ),

                const SizedBox(height: 8),

                // ===== MESSAGE =====
                Text(
                  "You are currently offline.\nYou can retry or continue in offline mode.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MyColors.AXMGray,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: MyColors.blue2),
                        ),
                        onPressed: () async {
                          Get.back();

                          LogService.writeLog(
                              message: "$tag[INFO] Retry connection clicked");

                          Timer(const Duration(milliseconds: 400), () async {
                            final ok = await check();
                            if (ok == true) {
                              doRefresh(Get.currentRoute);
                            }
                          });
                        },
                        child: Text(
                          "Retry",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: MyColors.blue2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ---- OFFLINE ----
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.blue2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Get.back();

                          LogService.writeLog(
                              message: "$tag[INFO] Enter offline mode clicked");

                          Get.offAllNamed(Routes.SplashScreen);
                        },
                        child: Text(
                          "Axpert Offline",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  connectivity_listen() async {
    await Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) async {
        LogService.writeLog(message: "connectivity listen $result");
        if (result.contains(ConnectivityResult.mobile) ||
            result.contains(ConnectivityResult.wifi)) {
          isConnected.value = true;
        } else {
          isConnected.value = false;
          showError();
        }
      },
      // (result){
      //     if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      //       isConnected.value = true;
      //     } else {
      //       isConnected.value = false;
      //       showError();
      //     }
      // }
    );
  }
}

doRefresh(String currentRoute) {
  print(currentRoute);
  switch (currentRoute) {
    case Routes.Login:
      // LoginController loginController = Get.find();
      // loginController.fetchUserTypeList();
      break;
    default:
      break;
  }
}
