import 'package:axpertflutter/ModelPages/LandingPage/Controller/MenuHomePageConroller.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetCard.dart';
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: MediaQuery.of(context).size.height * .15,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100),
            child: Obx(() => Stack(
                  children: [
                    CarouselSlider(
                      items: menuHomePageController.list,
                      carouselController: menuHomePageController.carouselController,
                      options: CarouselOptions(
                        height: double.maxFinite,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                        onPageChanged: (index, reason) {
                          menuHomePageController.carouselIndex.value = index;
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: menuHomePageController.list.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => menuHomePageController.carouselController.animateToPage(entry.key),
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                                      .withOpacity(
                                          menuHomePageController.carouselIndex.value == entry.key ? 0.9 : 0.1)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: menuHomePageController.isLoading.value
                ? Text("")
                : GridView.builder(
                    padding: EdgeInsets.only(left: 10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemCount: menuHomePageController.listOfCards.length,
                    itemBuilder: (context, index) {
                      return Container(
                          height: 600,
                          margin: EdgeInsets.only(top: 10, right: 20, bottom: 10),
                          child: WidgetCard(menuHomePageController.listOfCards[index]));
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
