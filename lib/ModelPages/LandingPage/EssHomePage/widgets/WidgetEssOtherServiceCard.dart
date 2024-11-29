import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssOtherServiceCard extends StatelessWidget {
  const WidgetEssOtherServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
        textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.30,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Other services",
                  style: style,
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: Column(
                  children: [
                    Row(
                      children: [],
                    ),
                    Row(
                      children: [],
                    ),
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
