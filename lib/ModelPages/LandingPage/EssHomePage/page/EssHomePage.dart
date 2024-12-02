import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssAnnouncement.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssAttendanceCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssHomeCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssKPICards.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssOtherServiceCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetHeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/WidgetEssAppBar.dart';
import '../widgets/WidgetEssRecentActivity.dart';

class EssHomePage extends StatelessWidget {
  EssHomePage({super.key});
  final EssController controller = Get.put(EssController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: WidgetEssAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: controller.scrollController,
              padding: EdgeInsets.zero,
              children: [
                WidgetHeaderWidget(),
                WidgetEssAttendanceCard(),
                _heightBox(),
                WidgetEssHomecard(),
                _heightBox(),
                WidgetEssKPICards(),
                _heightBox(),
                WidgetEssOtherServiceCard(),
                _heightBox(),
                WidgetRecentActivity(),
                WidgetEssAnnouncement(),
                _heightBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heightBox({double height = 15}) => SizedBox(height: height);
}
