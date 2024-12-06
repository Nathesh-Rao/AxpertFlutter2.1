import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_icons_named/material_icons_named.dart';

import '../models/EssBannerModel.dart';

class WidgetEssMainBannerWidget extends StatelessWidget {
  const WidgetEssMainBannerWidget(
      {super.key, required this.bannerModel, required this.color});
  final EssBannerModel bannerModel;
  final Color color;
  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
        textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        // color: Color(0xff4E58EE),
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -100,
            top: -200,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white12,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 15,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      bannerModel.smallheading,
                      style: style.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      bannerModel.caption,
                      style: style.copyWith(fontSize: 40, color: Colors.white),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(
                        generateIcon(bannerModel.action1Icon),
                        color: color,
                        size: 20,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(
                        generateIcon(bannerModel.action2Icon),
                        color: color,
                        size: 20,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(
                        generateIcon(bannerModel.action3Icon),
                        color: color,
                        size: 20,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text("more details",
                    style: style.copyWith(color: Colors.white38)),
              ),
            ),
          )
        ],
      ),
    );
  }

  generateIcon(iconName) {
    if (iconName.contains("material-icons")) {
      iconName = iconName.replaceAll("|material-icons", "");
      return materialIcons[iconName];
    } else {
      switch (iconName.trim().toUpperCase()[0]) {
        case "T":
          return Icons.assignment;
        case "I":
          return Icons.view_list;
        case "W":
        case "H":
          return Icons.code;
        default:
          return Icons.access_time;
      }
    }
  }
}
