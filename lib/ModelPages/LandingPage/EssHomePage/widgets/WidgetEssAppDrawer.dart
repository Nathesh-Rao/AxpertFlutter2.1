import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssAppDrawer extends StatelessWidget {
  WidgetEssAppDrawer({super.key});
  final EssController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Obx(
      () => Drawer(
        width: size.width * 0.7,
        // height: size.height,
        // color: Colors.white,
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: ListTile.divideTiles(
                  context: context, tiles: controller.getDrawerTileList())
              .toList(),
        ),
        // child: SingleChildScrollView(
        //   child: Column(
        //     children: [
        //       DrawerHeader(
        //         padding: EdgeInsets.zero,
        //         decoration: BoxDecoration(
        //           gradient: LinearGradient(
        //               begin: Alignment.topCenter,
        //               end: Alignment.bottomCenter,
        //               colors: [
        //                 Color(0xff3764FC),
        //                 Color(0xff9764DA),
        //               ]),
        //         ),
        //         child: _userInfoWidget(
        //             username: controller.userName.value,
        //             companyName: "Agile labs"),
        //       ),
        //       ListView(
        //         shrinkWrap: true,
        //         physics: NeverScrollableScrollPhysics(),
        //         children: ListTile.divideTiles(
        //                 context: context, tiles: controller.getDrawerTileList())
        //             .toList(),
        //       )
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
