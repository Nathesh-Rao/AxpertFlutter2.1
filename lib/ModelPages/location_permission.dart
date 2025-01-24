import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../Utils/LogServices/LogService.dart';

class RequestLocationPage extends StatefulWidget {
  const RequestLocationPage({super.key});

  @override
  State<RequestLocationPage> createState() => _RequestLocationPageState();
}

class _RequestLocationPageState extends State<RequestLocationPage> {
  @override
  void initState() {
    LogService.writeLog(message: "[>] RequestLocationPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
          body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    "This application needs Full location access so that we can"
                    " always track you where ever you go between the office hours.\n\n"
                    "Please allow location permission as \nAll The Time",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Center(
                child: Image.asset("assets/images/circular_location.jpeg"),
              ),
              SizedBox(
                height: 20,
              ),
              Row(children: [
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: ElevatedButton(
                            onPressed: () {
                              _locationPermission();
                            },
                            child: Text("Allow"))))
              ]),
              SizedBox(
                height: 20,
              ),
              Row(children: [
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: TextButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.grey.shade300,
                            )),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("Not Now")))),
              ]),
            ],
          ),
        ),
      )),
    );
  }

  _locationPermission() async {
    await Geolocator.requestPermission();
    var permission = await Geolocator.checkPermission();

    if (Platform.isIOS) {
      if (permission == LocationPermission.whileInUse) {
        LogService.writeLog(message: "[i] [IOS] RequestLocationPage\nScope: _locationPermission(): true");
        Navigator.of(context).pop();
      }
    }
    if (permission == LocationPermission.always) {
      LogService.writeLog(message: "[i] RequestLocationPage\nScope: _locationPermission(): true");
      Navigator.of(context).pop();
    }
  }
}
