import 'dart:ffi';
import 'dart:io';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class DemoValidityPage extends StatelessWidget {
  const DemoValidityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/lotties/error.json",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Demo Period Ended",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Thank you for trying our app! Your demo period has officially ended. We hope you had a great experience exploring its features. If you wish to regain access, please reach out to our team. For now, the app is no longer accessible. We appreciate your understanding and support.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: MyColors.text1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(color: MyColors.white3, borderRadius: BorderRadius.circular(25)),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                exit(0);
              },
              child: Center(
                child: Text(
                  "Close App",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: MyColors.red,
                  ),
                ),
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
