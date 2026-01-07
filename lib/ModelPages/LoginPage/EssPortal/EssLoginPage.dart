import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../Constants/MyColors.dart';
import '../../../Constants/Routes.dart';
import '../../../Constants/Const.dart';
import '../Controller/LoginController.dart';

class EssLoginPage extends StatelessWidget {
  const EssLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    var containerHeight = MediaQuery.of(context).size.height * 0.66;
    var loginContainerHeight = MediaQuery.of(context).size.height * 0.67;
    LoginController loginController = Get.find();

    //----------------social login button widget for future-----------------------------
    //
    // _iconWidget({required IconData icon, Color? color}) {
    //   return InkWell(
    //     onTap: () {},
    //     child: Container(
    //       width: 60,
    //       height: 40,
    //       decoration: BoxDecoration(
    //           color: MyColors.white3, borderRadius: BorderRadius.circular(10)),
    //       child: Center(
    //         child: Icon(
    //           icon,
    //           color: color,
    //           size: 17,
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Obx(
      () => Stack(
        children: [
          Container(
            height: containerHeight,
            decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/images/essbg.png"), fit: BoxFit.cover),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Hero(
                    tag: 'axpertImage',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: (AppBar().preferredSize.height + 35)),
                        Image.asset(
                          'assets/images/axpert_03.png',
                          // 'assets/images/buzzily-logo.png',
                          height: MediaQuery.of(context).size.height * 0.10,
                          // width: MediaQuery.of(context).size.width * 0.38,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(height: 5),
                        Text('Welcome to Axpert',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white))),
                        SizedBox(height: 5),
                        Text(
                          globalVariableController.PROJECT_NAME.value.toString().toUpperCase(),
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: Container(
                  height: loginContainerHeight,
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        controller: loginController.userNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.1), borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.1), borderRadius: BorderRadius.circular(10)),
                          errorText: loginController.errMessage(loginController.errUserName),
                          labelText: "Username",
                          hintText: "Enter Username",
                          labelStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: MyColors.text1)),
                          hintStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: MyColors.text1)),
                          fillColor: MyColors.blue12,
                          filled: true,
                          // border: OutlineInputBorder(
                          //   borderSide: BorderSide(width: 1),
                          //   borderRadius: BorderRadius.circular(10),
                          // )
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: loginController.userPasswordController,
                        obscureText: loginController.showPassword.value,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.1), borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 0.1), borderRadius: BorderRadius.circular(10)),
                          errorText: loginController.errMessage(loginController.errPassword),
                          labelText: "Password",
                          hintText: "Enter Password",
                          labelStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: MyColors.text1)),
                          hintStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: MyColors.text1)),
                          fillColor: MyColors.blue12,
                          filled: true,
                          suffixIcon: IconButton(
                              onPressed: () {
                                loginController.showPassword.toggle();
                              },
                              icon: loginController.showPassword.value
                                  ? Icon(
                                      Icons.visibility,
                                      color: MyColors.blue2,
                                    )
                                  : Icon(
                                      Icons.visibility_off,
                                      color: MyColors.blue2,
                                    )),
                          // border: OutlineInputBorder(
                          //   borderSide: BorderSide(width: 1),
                          //   borderRadius: BorderRadius.circular(10),
                          // )

                          // border: OutlineInputBorder(
                          //   borderSide: BorderSide(width: 1),
                          //   borderRadius: BorderRadius.circular(10),
                          // )
                        ),
                      ),
                      SizedBox(height: 15),
                      DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButtonFormField(
                            value: loginController.ddSelectedValue.value,
                            items: loginController.dropdownMenuItem(),
                            onChanged: (value) => loginController.dropDownItemChanged(value),
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.group),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                loginController.rememberMe.toggle();
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      value: loginController.rememberMe.value,
                                      onChanged: (value) => {loginController.rememberMe.toggle()},
                                      checkColor: Colors.white,
                                      fillColor: WidgetStateProperty.all(MyColors.blue10),
                                      // fillColor: WidgetStateProperty.resolveWith(
                                      //     loginController.getColor),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "Remember Me",
                                    style: TextStyle(
                                        color: HexColor("#3E4153"),
                                        fontWeight: FontWeight.w600,
                                        fontSize: MediaQuery.of(context).size.height * 0.014),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(Routes.ForgetPassword);
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: HexColor("#3E4153"),
                                    fontWeight: FontWeight.w600,
                                    fontSize: MediaQuery.of(context).size.height * 0.014),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      InkWell(
                        onTap: () async {
                          loginController.loginButtonClicked();
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: MyColors.blue10,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: MyColors.blue11, // Shadow color
                                offset: Offset(0, 10), // x, y offset of the shadow (0 for no horizontal shift)
                                blurRadius: 20, // Blur effect radius
                                spreadRadius: 0, // Optional, to adjust the spread of the shadow
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: MyColors.white1)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      Visibility(
                        visible: loginController.googleSignInVisible.value,
                        child: InkWell(
                          onTap: () {
                            loginController.googleSignInClicked();
                          },
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: MyColors.white1,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45, // Shadow color
                                  offset: Offset(0, 0),
                                  blurRadius: 3,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    SimpleIcons.google,
                                    color: SimpleIconColors.google,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Sign In with Google",
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: MyColors.text1)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      Visibility(
                        visible: loginController.newUserSigninVisible.value,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.SignUp);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("New user?  ",
                                    style: GoogleFonts.poppins(
                                        textStyle:
                                            TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: HexColor("#3E4153")))),
                                Text(
                                  "Sign up",
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: MyColors.blue10)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Visibility(
                        visible: loginController.willBio_userAuthenticate.value,
                        child: GestureDetector(
                          onTap: () {
                            loginController.displayAuthenticationDialog();
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Login with touch ID",
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: MediaQuery.of(context).size.height * 0.014,
                                        color: MyColors.blue10)),
                              ),
                              SizedBox(height: 10),
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: MyColors.white3,
                                child: Icon(
                                  Icons.fingerprint_rounded,
                                  size: 45,
                                  color: MyColors.blue10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Spacer(),
                          FutureBuilder(
                              future: loginController.getVersionName(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    "Version:${snapshot.data}${Const.APP_RELEASE_DATE}",
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                            color: MyColors.buzzilyblack,
                                            fontWeight: FontWeight.w700,
                                            fontSize: MediaQuery.of(context).size.height * 0.012)),
                                  );
                                } else {
                                  return Text("");
                                }
                              }),
                        ],
                      )
                      //-------------------------------------------------------
                      //Social login buttons for future connections for future
                      //-------------------------------------------------------

                      // Text(
                      //   "Or continue with",
                      //   style: GoogleFonts.poppins(
                      //       textStyle: TextStyle(
                      //           fontWeight: FontWeight.w600,
                      //           fontSize:
                      //               MediaQuery.of(context).size.height * 0.014,
                      //           color: MyColors.blue10)),
                      // ),
                      // SizedBox(height: 10),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     _iconWidget(
                      //         icon: SimpleIcons.google,
                      //         color: SimpleIconColors.google),
                      //     SizedBox(width: 10),
                      //     _iconWidget(
                      //         icon: SimpleIcons.facebook,
                      //         color: SimpleIconColors.facebook),
                      //     SizedBox(width: 10),
                      //     _iconWidget(
                      //         icon: SimpleIcons.apple,
                      //         color: SimpleIconColors.apple),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
