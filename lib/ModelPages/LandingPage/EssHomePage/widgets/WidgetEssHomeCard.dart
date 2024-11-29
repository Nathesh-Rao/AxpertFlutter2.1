import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssHomecard extends StatelessWidget {
  const WidgetEssHomecard({super.key});

  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
        textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ));
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * .18,
      decoration: BoxDecoration(
          color: Color(0xff4E58EE), borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Positioned(
            left: -100,
            top: -200,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white10,
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
                      "Jan month salary credited",
                      style: style.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "20,000.00",
                      style: style.copyWith(fontSize: 40, color: Colors.white),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.visibility_off,
                      color: Colors.white38,
                    )
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(
                        Icons.ac_unit,
                        color: Color(0xff3764FC),
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
                        Icons.ac_unit,
                        color: Color(0xff3764FC),
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
                        Icons.ac_unit,
                        color: Color(0xff3764FC),
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
}
