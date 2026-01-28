import 'dart:async';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InternetConnectivity extends GetxController {
  var isConnected = false.obs;
  static InternetConnectivity to = Get.find();
  bool _lastConnectionState = true; // assume online initially

  InternetConnectivity() {
    connectivity_listen();
    check(); // initial check
  }

  // =================================================
  // CHECK CURRENT STATE
  // =================================================
  Future<bool> check() async {
    var result = await Connectivity().checkConnectivity();

    final nowOnline = result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);

    _handleStateChange(nowOnline);

    return nowOnline;
  }

  get connectionStatus => check();

  // =================================================
  // LISTEN TO CHANGES
  // =================================================
  void connectivity_listen() {
    Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        LogService.writeLog(message: "connectivity listen $result");

        final nowOnline = result.contains(ConnectivityResult.mobile) ||
            result.contains(ConnectivityResult.wifi);

        _handleStateChange(nowOnline);
      },
    );
  }

  // =================================================
  // CORE STATE MACHINE
  // =================================================
  void _handleStateChange(bool nowOnline) {
    if (_lastConnectionState == nowOnline) {
      return;
    }

    _lastConnectionState = nowOnline;
    isConnected.value = nowOnline;

    // Close any existing dialog before showing new one
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    if (nowOnline) {
      LogService.writeLog(message: "[NET] Back online");
      Future.delayed(const Duration(milliseconds: 200), () {
        showBackOnlineDialog();
      });
    } else {
      LogService.writeLog(message: "[NET] Went offline");
      Future.delayed(const Duration(milliseconds: 200), () {
        showNoInternetDialog();
      });
    }
  }

  // =================================================
  // NO INTERNET DIALOG
  // =================================================
  void showNoInternetDialog() {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Text(
                  "Please check your internet connectivity.",
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
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("OK"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.blue2,
                        ),
                        onPressed: () async {
                          Get.back();
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          await check();
                        },
                        child: const Text("Retry"),
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

  // =================================================
  // BACK ONLINE DIALOG
  // =================================================
  void showBackOnlineDialog() {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.wifi,
                    size: 34,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Connection Restored",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: MyColors.AXMDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Internet is available now. How do you want to continue?",
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
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("Continue Offline"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.blue2,
                        ),
                        onPressed: () {
                          Get.back();
                          // App flow will decide what to do next
                        },
                        child: const Text("Continue Online"),
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
}
