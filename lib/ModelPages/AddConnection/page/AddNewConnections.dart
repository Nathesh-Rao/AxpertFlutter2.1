import 'dart:ffi';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Controllers/AddConnectionController.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/ConnectCode.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/QRCodeScanner.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/URLDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewConnection extends StatefulWidget {
  const AddNewConnection({super.key});

  @override
  State<AddNewConnection> createState() => _AddNewConnectionState();
}

class _AddNewConnectionState extends State<AddNewConnection> {
  AddConnectionController connectionController = Get.find();
  dynamic argumentData = Get.arguments;

  @override
  void initState() {
    try {
      connectionController.index.value = 0;
      if (argumentData != null) connectionController.index.value = argumentData[0]?.toInt() ?? 0;
    } catch (e) {}
    print(connectionController.index.value);
    switch (connectionController.index.value) {
      case 0:
        connectionController.selectedRadioValue.value = "QR";
        break;
      case 1:
        connectionController.selectedRadioValue.value = "CC";
        break;
      case 2:
        connectionController.selectedRadioValue.value = "URL";
        break;
    }
  }

  var pages = [QRCodeScanner(), ConnectCode(), URLDetails()];

  @override
  void dispose() {
    print("Dispose Called");
    connectionController.updateProjectDetails = false;
    connectionController.connectionCodeController.text = "";
    connectionController.conCaptionController.text = "";
    connectionController.conNameController.text = "";
    connectionController.webUrlController.text = "";
    connectionController.armUrlController.text = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add New Connection"),
          foregroundColor: Colors.blue,
          backgroundColor: Colors.white,
          centerTitle: true,
          // bottom: PreferredSize(
          //   preferredSize: Size.fromHeight(kToolbarHeight),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //     ),
          //     child: TabBar(
          //       indicatorColor: Colors.amberAccent,
          //       unselectedLabelColor: Colors.black38,
          //       labelColor: Colors.black,
          //       indicatorWeight: 3,
          //       tabs: [
          //         Tab(text: "Scan QR Code"),
          //         Tab(text: "Connect Code"),
          //         Tab(text: "URL Details"),
          //       ],
          //     ),
          //   ),
          // ),
        ),
        body: Obx(() => Column(
              children: [
                SizedBox(height: 10),
                Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.32,
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity),
                            value: "QR",
                            groupValue: connectionController.selectedRadioValue.value,
                            onChanged: (v) {
                              connectionController.selectedRadioValue.value = v.toString();
                              connectionController.index.value = 0;
                            },
                            title: Text(
                              "Scan QR Code",
                              style: TextStyle(
                                  color: MyColors.buzzilyblack,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.32,
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity),
                            value: "CC",
                            groupValue: connectionController.selectedRadioValue.value,
                            onChanged: (v) {
                              connectionController.selectedRadioValue.value = v.toString();
                              connectionController.index.value = 1;
                            },
                            title: Text(
                              "Connection Code",
                              style: TextStyle(
                                  color: MyColors.buzzilyblack,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.32,
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity),
                            value: "URL",
                            groupValue: connectionController.selectedRadioValue.value,
                            onChanged: (v) {
                              connectionController.selectedRadioValue.value = v.toString();
                              connectionController.index.value = 2;
                            },
                            title: Text(
                              "URL Details",
                              style: TextStyle(
                                  color: MyColors.buzzilyblack,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: pages[connectionController.index.value])
              ],
            )),
      ),
    );
  }
}
