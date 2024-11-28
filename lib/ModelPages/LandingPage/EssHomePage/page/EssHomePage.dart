import 'dart:developer';

import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/UpdatedHomePage/Widgets/WidgetPlayGround.dart';
import 'package:flutter/material.dart';

import '../widgets/WidgetEssAppBar.dart';

class EssHomePage extends StatelessWidget {
  const EssHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: WidgetEssAppBar(),
      body: Column(
        children: [
          Container(
            height: height * 0.32,
            width: width,
            decoration: BoxDecoration(
              // color: Colors.amber,
              // image: DecorationImage(
              //   image: AssetImage("assets/images/esshomebg.png"),
              //   fit: BoxFit.cover,
              // )
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff3764FC),
                    Color(0xff9764DA),
                  ]),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -35,
                  top: -60,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withAlpha(15),
                    radius: height * 0.16,
                  ),
                ),
                Positioned(
                  right: 5,
                  bottom: 60,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withAlpha(15),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                WidgetPlayGround(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InwardCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    log("Width:${size.width} height:${size.height}");

    Path path = Path();
    path.lineTo(0, 0); // Start from the top-left corner
    path.lineTo(0, size.height); // Go to the bottom-left corner

    // Create the outward curve on the bottom-left
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height - 40, // Control point (pulls the curve upward)
      size.width * 0.1, size.height - 35, // End point
    );

    path.lineTo(
        size.width * 0.9, size.height - 35); // Straight line to the right

    // Create the outward curve on the bottom-right
    path.quadraticBezierTo(
      size.width * 0.95,
      size.height - 40, // Control point (pulls the curve upward)
      size.width, size.height, // End point
    );

    path.lineTo(size.width, 0); // Go to the top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
