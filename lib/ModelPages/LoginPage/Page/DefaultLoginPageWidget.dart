import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import '../../../Constants/MyColors.dart';
import '../../../Constants/Routes.dart';
import '../../../Constants/Const.dart';
import '../Controller/LoginController.dart';

class DefaultLoginPageWidget extends StatelessWidget {
  const DefaultLoginPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //loginController.checkBiometricFlag();
    });
    return Obx(
      () => SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        // Align(
                        //   alignment: Alignment.topRight,
                        //   child: IconButton(
                        //     onPressed: () {
                        //       Get.toNamed(Routes.ProjectListingPage);
                        //     },
                        //     icon: Icon(Icons.settings),
                        //   ),
                        // ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SizedBox(height: 20),
                            Hero(
                              tag: 'axpertImage',
                              child: Center(
                                child: Image.asset(
                                  'assets/images/axpert_04.png',
                                  // 'assets/images/buzzily-logo.png',
                                  height: MediaQuery.of(context).size.height * 0.090,
                                  // width: MediaQuery.of(context).size.width * 0.38,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Login',
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black))),
                            SizedBox(height: 10),
                            Text('Enter Your Credentials',
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black))),
                          ],
                        ),
                        // Align(
                        //   alignment: Alignment.topRight,
                        //   child: Padding(
                        //     padding: EdgeInsets.only(right: 30),
                        //     child: Image.asset(
                        //       'assets/images/buzzily.png',
                        //       height: MediaQuery.of(context).size.height * 0.13,
                        //       width: MediaQuery.of(context).size.width * 0.24,
                        //       fit: BoxFit.fill,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      globalVariableController.PROJECT_NAME.value.toString().toUpperCase(),
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 10, color: Colors.black)),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: loginController.userNameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        errorText: loginController.errMessage(loginController.errUserName),
                        labelText: "Username",
                        hintText: "Enter Username",
                        prefixIcon: Icon(Icons.person),
                        // border: OutlineInputBorder(
                        //   borderSide: BorderSide(width: 1),
                        //   borderRadius: BorderRadius.circular(10),
                        // )
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: loginController.userPasswordController,
                      obscureText: loginController.showPassword.value,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        errorText: loginController.errMessage(loginController.errPassword),
                        labelText: "Password",
                        hintText: "Enter Password",
                        prefixIcon: Icon(Icons.lock),
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
                      ),
                    ),
                    // SizedBox(height: 10),
                    // DropdownButtonHideUnderline(
                    //   child: ButtonTheme(
                    //     alignedDropdown: true,
                    //     child: DropdownButtonFormField(
                    //       value: loginController.ddSelectedValue.value,
                    //       items: loginController.dropdownMenuItem(),
                    //       onChanged: (value) => loginController.dropDownItemChanged(value),
                    //       decoration: InputDecoration(prefixIcon: Icon(Icons.group)),
                    //       // border: OutlineInputBorder(
                    //       //   borderRadius: BorderRadius.circular(10),
                    //       // )
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            loginController.rememberMe.toggle();
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: loginController.rememberMe.value,
                                onChanged: (value) => {loginController.rememberMe.toggle()},
                                checkColor: Colors.white,
                                fillColor: WidgetStateProperty.resolveWith(loginController.getColor),
                              ),
                              Text("Remember Me")
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
                                fontSize: MediaQuery.of(context).size.height * 0.016),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: InkWell(
                        onTap: () async {
                          loginController.loginButtonClicked();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(color: MyColors.blue2, borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: MyColors.white1)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Visibility(
                      visible: loginController.googleSignInVisible.value,
                      child: Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              foregroundColor: MyColors.buzzilyblack,
                              backgroundColor: MyColors.white1,
                              minimumSize: Size(double.infinity, 48),
                            ),
                            icon: Icon(FontAwesomeIcons.google, color: MyColors.red),
                            label: Text('Sign In With Google',
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: HexColor("#3E4153")))),
                            onPressed: () {
                              loginController.googleSignInClicked();
                            }),
                      ),
                    ),
                    // SizedBox(height: 10),
                    // InkWell(
                    //   onTap: () {
                    //     Get.toNamed(Routes.SignUp);
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 70, right: 70),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text("New user?  ",
                    //             style: GoogleFonts.poppins(
                    //                 textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: HexColor("#3E4153")))),
                    //         Text(
                    //           "Sign up",
                    //           style: GoogleFonts.poppins(
                    //               textStyle: TextStyle(
                    //                   decoration: TextDecoration.underline,
                    //                   fontWeight: FontWeight.w600,
                    //                   fontSize: 12,
                    //                   color: HexColor("#4E9AF5"))),
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 20),
                    FittedBox(
                      child: Text(
                        "By using the software, you agree to the",
                        style: GoogleFonts.poppins(
                            textStyle:
                                TextStyle(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 1, color: Colors.black)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text("Privacy Policy",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: MyColors.blue2,
                                    letterSpacing: 1),
                              )),
                        ),
                        FittedBox(
                          child: Text(" and the ",
                              style: GoogleFonts.poppins(
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black, letterSpacing: 1),
                              )),
                        ),
                        FittedBox(
                          child: Text("Terms of Use",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: MyColors.blue2,
                                    letterSpacing: 1),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("Powered By",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black, letterSpacing: 1),
                        )),
                    Image.asset(
                      'assets/images/agilelabslogonew.png',
                      height: MediaQuery.of(context).size.height * 0.04,
                      // width: MediaQuery.of(context).size.width * 0.075,
                      fit: BoxFit.fill,
                    ),
                    Visibility(
                      // visible: true,
                      visible: loginController.isBiometricAvailable.value && loginController.willBio_userAuthenticate.value,
                      child: GestureDetector(
                        onTap: () {
                          loginController.displayAuthenticationDialog();
                          // showBiometricDialog();
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.all(20),
                          child: Icon(
                            Icons.fingerprint_outlined,
                            color: MyColors.blue2,
                            size: MediaQuery.of(context).size.height * 0.04,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 10),
                  child: FutureBuilder(
                      future: loginController.getVersionName(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            "v${snapshot.data}${Const.RELEASE_ID}",
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: MyColors.buzzilyblack,
                                    fontWeight: FontWeight.w700,
                                    fontSize: MediaQuery.of(context).size.height * 0.012)),
                          );
                        } else {
                          return Text("");
                        }
                      })),
            )
          ],
        ),
      ),
    );
  }

  // showBiometricDialog() async {
  //   try {
  //     LocalAuthentication auth = LocalAuthentication();
  //     return await auth.authenticate(
  //         localizedReason: "Please use your touch id to login",
  //         authMessages: const <AuthMessages>[
  //           AndroidAuthMessages(
  //             signInTitle: 'Biometric authentication required!',
  //             cancelButton: 'No thanks',
  //           ),
  //           IOSAuthMessages(
  //             cancelButton: 'No thanks',
  //           )
  //         ],
  //         options: AuthenticationOptions(biometricOnly: true, useErrorDialogs: true, stickyAuth: true));
  //   } catch (e) {
  //     print(e.toString());
  //     // if (e.toString().contains('NotAvailable') && e.toString().contains('Authentication failure'))
  //     //   showErrorSnack(title: "Oops!", message: "Only Biometric is allowed.");
  //   }
  //   return false;
  // }
}
