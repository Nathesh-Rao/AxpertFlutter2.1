import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/HomePage/page/HomePage.dart';
import 'package:axpertflutter/ModelPages/ProjectListing/Model/ProjectModel.dart';
import 'package:axpertflutter/ModelPages/ProjectListing/Page/ProjectListingPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  var _animationController;
  AppStorage appStorage = AppStorage();
  ProjectModel? projectModel;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _animationController.repeat();
    Future.delayed(Duration(milliseconds: 1550), () {
      _animationController.stop();
      var cached = appStorage.retrieveValue(AppStorage.cached);
      try {
        if (cached == null)
          Get.offAndToNamed(Routes.ProjectListingPage);
        else {
          var jsonProject = appStorage.retrieveValue(cached);
          projectModel = ProjectModel.fromJson(jsonProject);
          Const.PROJECT_NAME = projectModel!.projectname;
          Const.PROJECT_URL = projectModel!.web_url;
          Const.ARM_URL = projectModel!.arm_url;
          Get.offAndToNamed(Routes.Login);
        }
      } catch (e) {
        Get.offAndToNamed(Routes.ProjectListingPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              builder: (context, child) => Transform.rotate(
                angle: _animationController.value * 6.3,
                child: child,
              ),
              animation: _animationController,
              child: Container(
                height: 150,
                width: 150,
                child: Image.asset(
                  'assets/images/agilelabslogo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20, bottom: 20),
              child: Text("Version: "),
            ),
          )
        ],
      ),
    );
  }
}
/*
AnimatedSplashScreen(
      duration: 2000,
      splash: Image.asset(
        'assets/images/agilelabslogo.png',
        height: 200,
        width: 200,
      ),
      splashTransition: SplashTransition.rotationTransition,
      nextScreen: ProjectListingPage(),
      // nextRoute: Routes.SplashScreen,
    )
* */
