import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Widgets/WidgetStatusScrollbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class WidgetPendingListItemDetails extends StatelessWidget {
  WidgetPendingListItemDetails({super.key});
  PendingListController pendingListController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: double.maxFinite,
                // color: Colors.red,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    controller: pendingListController.scrollController,
                    itemBuilder: (context, index) {
                      return WidgetStatusScrollBar(pendingListController.StatusList[index]);
                    },
                    separatorBuilder: (context, index) {
                      return Center(
                          child: Text(
                        " > ",
                        style: TextStyle(color: HexColor("848D9C").withOpacity(0.4)),
                      ));
                    },
                    itemCount: pendingListController.StatusList.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
