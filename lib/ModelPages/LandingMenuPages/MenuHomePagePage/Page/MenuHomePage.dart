import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageConroller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Widgets/WidgetCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetSlidingNotification.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuHomePage extends StatelessWidget {
  MenuHomePage({super.key});
  MenuHomePageController menuHomePageController = Get.put(MenuHomePageController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WidgetSlidingNotificationPanel(),
        Expanded(
          child: Obx(() => Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: menuHomePageController.isLoading.value
                    ? Text("")
                    : GridView.builder(
                        padding: EdgeInsets.only(left: 10),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
                        itemCount: menuHomePageController.listOfCards.length,
                        itemBuilder: (context, index) {
                          return Container(
                              height: 600,
                              margin: EdgeInsets.only(top: 10, right: 20, bottom: 10),
                              child: WidgetCard(menuHomePageController.listOfCards[index]));
                        },
                      ),
              )),
        ),
      ],
    );
  }
}
