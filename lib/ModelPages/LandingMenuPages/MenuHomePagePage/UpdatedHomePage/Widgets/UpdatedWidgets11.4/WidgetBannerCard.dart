import 'package:axpertflutter/Constants/Extensions.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/UpdatedHomePage/Models/BannerCardModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../Constants/MyColors.dart';

class WidgetBannerCard extends StatelessWidget {
  WidgetBannerCard({super.key});
  final MenuHomePageController menuHomePageController = Get.find();
  @override
  Widget build(BuildContext context) {
    CarouselSliderController bannerController = CarouselSliderController();

    return Obx(
      () {
        if (!menuHomePageController.bannerCardData.value.isEmpty) {
          return Visibility(
            visible: menuHomePageController.bannerCardData.isNotEmpty,
            child: Column(
              children: [
                SizedBox(
                  height: Get.height * 0.24,
                  child: CarouselSlider(
                    items: List.generate(menuHomePageController.bannerCardData[0].carddata.length,
                        (index) => _bannerCard(menuHomePageController.bannerCardData[0].carddata[index])),
                    carouselController: bannerController,
                    options: CarouselOptions(
                      height: double.maxFinite,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      onPageChanged: (index, reason) {
                        menuHomePageController.updateBannerIndex(index);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(menuHomePageController.bannerCardData[0].carddata.length, (index) {
                      var isSelected = index == menuHomePageController.bannerIndex.value;

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
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  _bannerCard(dynamic cardData) {
    var bannerData = BannerCard.fromJson(cardData);

    return Container(
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xff5c61f1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.bottomRight,
              child: Image.network(
                bannerData.image ?? '',
                width: Get.width / 3,
              )),
          // Image.asset(
          //   "assets/images/slider.png",
          //   // "assets/images/slider.png",
          //   width: Get.width / 3,
          // )
          Align(
              child: Opacity(
            opacity: 0.3,
            child: Image.asset(
              "assets/images/sliderBG.png",

              // fit: BoxFit.fill,
            ),
          )),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   "Daily Quotes",
                  //   style: GoogleFonts.urbanist(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.w700,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // SizedBox(height: 15),
                  Text(
                    bannerData.title ?? '',
                    style: GoogleFonts.urbanist(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: MyColors.white1,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: Get.width / 2,
                    child: Row(
                      children: [
                        Flexible(
                            child: Text(
                          bannerData.subtitle ?? '',
                          style: GoogleFonts.urbanist(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: MyColors.white3.withAlpha(190),
                          ),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Visibility(
                    visible: bannerData.time != null,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Text(
                          bannerData.time ?? '',
                          style: GoogleFonts.urbanist(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: MyColors.blue1,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
