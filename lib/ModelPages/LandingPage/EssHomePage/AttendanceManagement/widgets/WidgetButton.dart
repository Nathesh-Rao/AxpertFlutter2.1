import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({super.key, required this.label, required this.onTap});
  final String label;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: MyColors.blue10,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: MyColors.blue11, // Shadow color
              offset: Offset(0,
                  10), // x, y offset of the shadow (0 for no horizontal shift)
              blurRadius: 20, // Blur effect radius
              spreadRadius: 0, // Optional, to adjust the spread of the shadow
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: MyColors.white1)),
          ),
        ),
      ),
    );
  }
}
