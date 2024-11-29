import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssAttendanceCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssHomeCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssKPICards.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssOtherServiceCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetHeaderWidget.dart';
import 'package:flutter/material.dart';

import '../widgets/WidgetEssAppBar.dart';

class EssHomePage extends StatelessWidget {
  const EssHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: WidgetEssAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heightBox({double height = 15}) => SizedBox(height: height);
}
