import 'package:axpertflutter/ModelPages/AddConnection/Controllers/AddConnectionController.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/ConnectCode.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/QRCodeScanner.dart';
import 'package:axpertflutter/ModelPages/AddConnection/Widgets/URLDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNewConnection extends StatefulWidget {
  const AddNewConnection({super.key});

  @override
  State<AddNewConnection> createState() => _AddNewConnectionState();
}

class _AddNewConnectionState extends State<AddNewConnection> {
  AddConnectionController connectionController = Get.find();
  int? _index;
  dynamic argumentData = Get.arguments;

  @override
  void initState() {
    if (argumentData != null) _index = argumentData[0]?.toInt() ?? 0;
  }

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
    return DefaultTabController(
      initialIndex: _index?.toInt() ?? 0,
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Add New Connection"),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.cyan,
                ),
                child: TabBar(
                  indicatorColor: Colors.amberAccent,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: "Scan QR Code"),
                    Tab(text: "Connect Code"),
                    Tab(text: "URL Details"),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
              children: [QRCodeScanner(), ConnectCode(), URLDetails()]),
        ),
      ),
    );
  }
}
