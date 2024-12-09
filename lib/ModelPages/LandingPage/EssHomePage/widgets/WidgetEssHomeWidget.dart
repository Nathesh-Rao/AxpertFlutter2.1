import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'WidgetEssAnnouncement.dart';
import 'WidgetEssAttendanceCard.dart';
import 'WidgetEssHomeCard.dart';
import 'WidgetEssKPICards.dart';
import 'WidgetEssMenuFolderWidget.dart';
import 'WidgetEssOtherServiceCard.dart';
import 'WidgetEssRecentActivity.dart';
import 'WidgetHeaderWidget.dart';

class EssHomeWidget extends StatelessWidget {
  EssHomeWidget({super.key});
  final EssController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: controller.scrollController,
            padding: EdgeInsets.zero,
            children: [
              WidgetHeaderWidget(),
              WidgetEssAttendanceCard(),
              WidgetEssHomecard(),
              WidgetEssKPICards(),
              WidgetEssOtherServiceCard(),
              WidgetRecentActivity(),
              WidgetEssAnnouncement(),
              WidgetEssMenuFolders(),
              _heightBox(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heightBox({double height = 20}) => SizedBox(height: height);
}
