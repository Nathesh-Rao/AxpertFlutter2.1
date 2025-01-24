import 'dart:developer';

import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetEssHomecard extends StatelessWidget {
  WidgetEssHomecard({super.key});
  final EssController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: controller.bannerWidgets.length > 0,
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.18,
                child: CarouselSlider(
                  items: controller.bannerWidgets,
                  carouselController: controller.essBannerController,
                  options: CarouselOptions(
                    // initialPage: landingPageController.carouselBannerIndex.value,
                    height: double.maxFinite,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    enlargeCenterPage: true,
                    viewportFraction: 1,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    onPageChanged: (index, reason) {
                      controller.updateBannerIndex(index: index);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(controller.bannerWidgets.length, (index) {
                    var isSelected = index == controller.bannerCurrentIndex.value;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: isSelected ? 10 : 8,
                      width: isSelected ? 10 : 8,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
