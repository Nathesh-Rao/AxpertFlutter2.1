import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetProfileBottomSheet extends StatelessWidget {
  const WidgetProfileBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      clipBehavior: Clip.hardEdge,
      height: MediaQuery.of(context).size.height / 1.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: ListView(
        // physics: BouncingScrollPhysics(),
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 5,
            decoration: BoxDecoration(
              color: Color(0xff5BB3F0),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          SizedBox(height: 10),
          Container(
            // height: MediaQuery.of(context).size.height / 3.5,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Container(
                  height: 40,
                  padding: EdgeInsets.only(left: 15),
                  // margin: EdgeInsets.only(bottom: 10),
                  color: Color(0xffD9D9D9),
                  child: Center(
                    child: Row(
                      children: [
                        Text(
                          "Your Team",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...List.generate(3, (index) => _teamUserInfoWidget()),
              ],
            ),
          )
        ],
      ),
    );
  }

  _teamUserInfoWidget() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withAlpha(56),
            radius: 25,
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(56),
              radius: 23,
              child: CircleAvatar(
                // backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/images/profilesample.jpg"),
                radius: 28,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kimberly Vixion",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              Text(
                "Flutter developer",
                style: GoogleFonts.poppins(
                  color: Colors.black.withAlpha(150),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
