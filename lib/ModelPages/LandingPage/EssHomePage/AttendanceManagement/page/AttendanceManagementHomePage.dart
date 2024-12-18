import 'package:flutter/material.dart';

import '../../widgets/WidgetEssAttendanceCard.dart';

class AttendanceManagementHomePage extends StatelessWidget {
  const AttendanceManagementHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Spacer(),
          WidgetEssAttendanceCard(),
        ],
      ),
    );
  }
}
