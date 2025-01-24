import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/controller/AttendanceController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetTabAttendance.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetTabInOutHub.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetTabLeavesHub.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WidgetAttendanceHome extends StatelessWidget {
  WidgetAttendanceHome({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.find();
    List<Widget> homePages = [
      WidgetTabInOutHub(),
      WidgetTabAttendance(),
      WidgetTabLeavesHub(),
    ];
    return PageView.builder(
        controller: controller.pageController,
        onPageChanged: controller.updatePageIndexFromPageBuilder,
        itemCount: homePages.length,
        itemBuilder: (context, index) => homePages[index]);

    // return WidgetTabAttendance();
  }
}
