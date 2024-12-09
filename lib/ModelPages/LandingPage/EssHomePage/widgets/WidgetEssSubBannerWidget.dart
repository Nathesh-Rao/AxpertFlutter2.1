import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Models/BannerModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssSubBannerWidget extends StatelessWidget {
  const WidgetEssSubBannerWidget({super.key, required this.subBannerModel});
  final BannerModel subBannerModel;
  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
        textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ));
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(subBannerModel.image!),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 15),
          Text(
            subBannerModel.title.toString(),
            style: style,
          ),
          SizedBox(height: 15),
          Expanded(
              child: Text(
            subBannerModel.description.toString(),
            style: style.copyWith(
              fontSize: 11,
            ),
          )),
        ],
      ),
    );
  }
}
