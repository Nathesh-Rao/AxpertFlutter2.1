import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetNotification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  NotificationPage({super.key});
  final LandingPageController landingPageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.white,
        foregroundColor: MyColors.blue2,
      ),
      body: SafeArea(
        child: Obx(() => Padding(padding: EdgeInsets.only(bottom: 10), child: reBuild())),
      ),
    );
  }

  reBuild() {
    if (landingPageController.notificationPageRefresh.value == true) {
      landingPageController.notificationPageRefresh.value = false;
      landingPageController.getNotificationList();
      return ListView.builder(
        itemBuilder: (context, index) {
          return drawNotificationItem(landingPageController.list[index], index);
        },
        itemCount: landingPageController.list.length,
      );
    } else
      return ListView.builder(
        itemBuilder: (context, index) {
          return drawNotificationItem(landingPageController.list[index], index);
        },
        itemCount: landingPageController.list.length,
      );
  }

  drawNotificationItem(WidgetNotification item, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
      child: Dismissible(
        key: ValueKey(index),
        background: Container(
          padding: EdgeInsets.only(left: 20),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Delete",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        confirmDismiss: (direction) {
          return landingPageController.deleteNotification(index);
        },
        secondaryBackground: Container(
          padding: EdgeInsets.only(right: 20),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Delete",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 3,
          child: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Expanded(child: item),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade900,
                    ),
                    onPressed: () {
                      landingPageController.deleteNotification(index);
                    },
                  ),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 8.0),
                  //     child: IconButton(
                  //       icon: Icon(
                  //         Icons.delete,
                  //         color: Colors.red.shade900,
                  //       ),
                  //       onPressed: () {},
                  //     ),
                  //   ),
                  // )
                ],
              )),
        ),
      ),
    );
  }
}
