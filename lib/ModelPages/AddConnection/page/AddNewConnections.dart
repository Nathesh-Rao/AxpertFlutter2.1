import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Controllers/AddConnectionController.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/ConnectCode.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/QRCodeScanner.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/URLDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Utils/LogServices/LogService.dart';
import '../../ProjectListing/Model/ProjectModel.dart';

class AddNewConnection extends StatefulWidget {
  const AddNewConnection({super.key});

  @override
  State<AddNewConnection> createState() => _AddNewConnectionState();
}

class _AddNewConnectionState extends State<AddNewConnection> {
  AddConnectionController projectController = Get.find();
  dynamic argumentData = Get.arguments;
  ProjectModel? project;
  var pages = [];

  @override
  void initState() {
    super.initState();
    LogService.writeLog(message: "[>] AddNewConnection");
    if (argumentData != null && argumentData is List && argumentData.length > 1) {
      project = argumentData[1];
    }
    pages = [QRCodeScanner(), ConnectCode(), URLDetails(project: project)];

    try {
      projectController.index.value = 0;
      projectController.heading.value = "Add new Connection";
      if (argumentData != null) projectController.index.value = argumentData[0]?.toInt() ?? 0;
    } catch (e) {
      LogService.writeLog(message: "[ERROR] AddNewConnection\Scope: initState\nError: $e");
    }
    print(projectController.index.value);
    switch (projectController.index.value) {
      case 0:
        projectController.selectedRadioValue.value = "QR";
        break;
      case 1:
        projectController.selectedRadioValue.value = "CC";
        break;
      case 2:
        projectController.selectedRadioValue.value = "URL";
        projectController.heading.value = "Edit Connection";
        break;
    }
  }

  @override
  void dispose() {
    //projectController.updateProjectDetails = false;
    projectController.connectionCodeController.text = "";
    projectController.conCaptionController.text = "";
    projectController.conNameController.text = "";
    projectController.webUrlController.text = "";
    projectController.armUrlController.text = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(projectController.heading.value),
          foregroundColor: MyColors.blue2,
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned(
                right: -50,
                bottom: 30,
                child: ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(80), topLeft: Radius.circular(80), topRight: Radius.circular(80)),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: MediaQuery.of(context).size.width,
                    color: MyColors.yellow1,
                  ),
                )),
            Obx(() => Column(
                  children: [
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.32,
                              child: RadioListTile(
                                activeColor: MyColors.blue2,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity),
                                value: "QR",
                                groupValue: projectController.selectedRadioValue.value,
                                onChanged: (v) {
                                  projectController.selectedRadioValue.value = v.toString();
                                  projectController.index.value = 0;
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
                                activeColor: MyColors.blue2,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity),
                                value: "CC",
                                groupValue: projectController.selectedRadioValue.value,
                                onChanged: (v) {
                                  projectController.selectedRadioValue.value = v.toString();
                                  projectController.index.value = 1;
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
                                activeColor: MyColors.blue2,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity),
                                value: "URL",
                                groupValue: projectController.selectedRadioValue.value,
                                onChanged: (v) {
                                  projectController.selectedRadioValue.value = v.toString();
                                  projectController.index.value = 2;
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
                    Expanded(child: pages[projectController.index.value])
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
