import 'package:axpertflutter/ModelPages/AddConnection/page/AddNewConnections.dart';
import 'package:axpertflutter/ModelPages/HomePage_old/page/HomePage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Page/LandingPage.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Page/ForgetPassword.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Page/LoginPage.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Page/SignUp.dart';
import 'package:axpertflutter/ModelPages/ProjectListing/Page/ProjectListingPage.dart';
import 'package:axpertflutter/ModelPages/SpalshPage/page/SplashPageUI.dart';
import 'package:get/get.dart';

class Routes {
  static String SplashScreen = "/SplashScreen";
  static String HomePage = "/Home";
  static String AddNewConnection = "/AddConnection";
  static String InApplicationWebViewer = "/InApplicationWebViewer";
  static String ProjectListingPage = "/ProjectListingPage";
  static String Login = "/Login";
  static String SignUp = "/SignUp";
  static String ForgetPassword = "/ForgetPassword";
  static String LandingPage = "/LandingPage";
}

class RoutePages {
  static List<GetPage<dynamic>> pages = [
    GetPage(
      name: Routes.SplashScreen,
      page: () => SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HomePage,
      page: () => HomePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.AddNewConnection,
      page: () => AddNewConnection(),
      transition: Transition.rightToLeft,
    ),
    // GetPage(
    //   name: Routes.InApplicationWebViewer,
    //   page: () => InApplicationWebViewer(),
    //   transition: Transition.rightToLeft,
    // ),
    GetPage(
      name: Routes.ProjectListingPage,
      page: () => ProjectListingPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.Login,
      page: () => LoginPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SignUp,
      page: () => SignUpUser(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ForgetPassword,
      page: () => ForgetPassword(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.LandingPage,
      page: () => LandingPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
