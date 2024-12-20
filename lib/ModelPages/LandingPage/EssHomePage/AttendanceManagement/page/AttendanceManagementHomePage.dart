import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/controller/AttendanceController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetAttendanceHome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/WidgetAttendanceAppaBar.dart';

class AttendanceManagementHomePage extends StatelessWidget {
  AttendanceManagementHomePage({super.key});
  final AttendanceController c = Get.put(AttendanceController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AttendanceAppBar(),
      body: WidgetAttendanceHome(),
    );
  }
}
