import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/AttendanceController.dart';

class WidgetAttendanceTopBar extends StatelessWidget {
  WidgetAttendanceTopBar({super.key});
  final AttendanceController attendanceController = Get.find<AttendanceController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: Color(0xffD9D9D9).withAlpha(108), borderRadius: BorderRadius.circular(50)),
      child: Obx(
        () => Stack(
          children: [
            Row(
              children: List.generate(attendanceController.topBarMap.length,
                  (index) => _topBarItem(label: attendanceController.topBarMap[index], index: index)),
            ),
            AnimatedAlign(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
              alignment: _getAlignment(),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                height: 35,
                width: MediaQuery.of(context).size.width / 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    attendanceController.topBarMap[attendanceController.currentTopBarIndex.value]!,
                    style: GoogleFonts.poppins(
                      color: Color(0xff8A65DE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _topBarItem({required String? label, required int index}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          attendanceController.updatePageIndexFromTopBar(index);
        },
        child: Center(
            child: Text(
          label ?? '',
          style: GoogleFonts.poppins(
            color: Colors.white.withAlpha(200),
            fontWeight: FontWeight.w600,
          ),
        )),
      ),
    );
  }

  AlignmentGeometry _getAlignment() {
    switch (attendanceController.currentTopBarIndex.value) {
      case 0:
        return Alignment.centerLeft;
      case 1:
        return Alignment.center;
      case 2:
        return Alignment.centerRight;

      default:
        return Alignment.centerLeft;
    }
  }
}
