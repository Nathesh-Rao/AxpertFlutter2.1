import 'dart:convert';
import 'dart:developer';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Models/CardModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Models/CardOptionModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Models/MenuFolderModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuMorePage/Controllers/MenuMorePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuMorePage/Models/MenuItemModel.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/models/ESSRecentActivityModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_icons_named/material_icons_named.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../../../Constants/CommonMethods.dart';
import '../../../../Constants/MyColors.dart';
import '../../../../Constants/const.dart';
import '../../../../Utils/ServerConnections/ExecuteApi.dart';
import '../../../../Utils/ServerConnections/ServerConnections.dart';
import '../models/ESSAnnouncementModel.dart';

class EssController extends GetxController {
  final MenuMorePageController menuMorePageController =
      Get.put(MenuMorePageController());
  AppStorage appStorage = AppStorage();
  ServerConnections serverConnections = ServerConnections();
  @override
  void onInit() {
    scrollController.addListener(_scrollListener);

    super.onInit();
  }

  var body, header;
  var userName = 'Demo'.obs; //update with user name

  EssController() {
    body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    userName.value =
        appStorage.retrieveValue(AppStorage.USER_NAME) ?? userName.value;
    getCardDetails();
    getESSRecentActivity();
    getESSAnnouncement();
    getPunchINData();
  }

  generateIcon(model) {
    var iconName = model.icon;
    if (iconName.contains("material-icons")) {
      iconName = iconName.replaceAll("|material-icons", "");
      return materialIcons[iconName];
    } else {
      switch (model.type.trim().toUpperCase()[0]) {
        case "T":
          return Icons.assignment;
        case "I":
          return Icons.view_list;
        case "W":
        case "H":
          return Icons.code;
        default:
          return Icons.access_time;
      }
    }
  }

//-----Appbar control---------
  final ScrollController scrollController = ScrollController();

  var appBarColor = Colors.transparent.obs;

  var appbarGradient = LinearGradient(colors: [
    Colors.transparent,
    Colors.transparent,
  ]);
  void _scrollListener() {
    double offset = scrollController.offset;
    appBarColor.value = offset > 0
        ? Color(0xff9764DA).withOpacity((offset / 200).clamp(0, 1))
        : Colors.transparent;

    appbarGradient = LinearGradient(colors: [
      Color(0xff3764FC).withOpacity((offset / 200).clamp(0, 1)),
      Color(0xff9764DA).withOpacity((offset / 200).clamp(0, 1)),
    ]);
  }
//----------------------------

//------Recent Activity----------
//---vars-----
  RxList<EssRecentActivityModel> listOfESSRecentActivity =
      <EssRecentActivityModel>[].obs;
  RxList<Widget> listOfRecentActivityHomeScreenWidgets = <Widget>[].obs;
//----- calls-------
  void getESSRecentActivity() async {
    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "publickey": ExecuteApi.API_PublicKey_ESS_RecentActivity,
      "Project": Const.PROJECT_NAME,
      "getsqldata": {"trace": "true"}
    };
    var resp = await ExecuteApi().CallFetchData_ExecuteAPI(
      body: jsonEncode(body),
      isBearer: true,
    );
    // log(resp.toString());
    if (resp != "") {
      // log(resp.toString());
      var jsonResp = jsonDecode(resp);
      if (jsonResp["success"].toString() == "true") {
        var listItems = jsonResp["axm_ess_recentactivity"]["rows"];
        listOfESSRecentActivity.clear();
        for (var item in listItems) {
          EssRecentActivityModel recentActivityModel =
              EssRecentActivityModel.fromJson(item);
          listOfESSRecentActivity.add(recentActivityModel);
        }
        _getRecentActivityHomeScreenWidgets();
      }
    }
  }

  _getRecentActivityHomeScreenWidgets() {
    listOfRecentActivityHomeScreenWidgets.clear();

    for (var item in listOfESSRecentActivity) {
      if (listOfRecentActivityHomeScreenWidgets.length >= 5) {
        break;
      }
      if (item.isactive.toLowerCase() == "true") {
        listOfRecentActivityHomeScreenWidgets.add(_activityItem(item));
      }
    }
  }

  _activityItem(EssRecentActivityModel model) {
    var color = MyColors.getRandomColor();

    return ListTile(
      onTap: () {},
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(35),
        foregroundColor: color,
        child: Icon(generateIcon(model)),
      ),
      title: Text(
        model.caption,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        model.subheading,
        style: GoogleFonts.poppins(
          fontSize: 13,
        ),
      ),
      trailing: Text(
        model.info1,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  //------------------------------

  //---Announcement-------

  RxList<EssAnnouncementModel> listOfEssAnnouncementModels =
      <EssAnnouncementModel>[].obs;
  RxList<Widget> listOfAnnouncementHomeScreenWidgets = <Widget>[].obs;

//----- calls-------
  void getESSAnnouncement() async {
    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "publickey": ExecuteApi.API_PublicKey_ESS_Announcement,
      "Project": Const.PROJECT_NAME,
      "getsqldata": {"trace": "true"}
    };
    var resp = await ExecuteApi().CallFetchData_ExecuteAPI(
      body: jsonEncode(body),
      isBearer: true,
    );
    // log(resp.toString());
    if (resp != "") {
      var jsonResp = jsonDecode(resp);

      if (jsonResp["success"].toString() == "true") {
        var listItems = jsonResp["axm_ess_announcement"]["rows"];
        listOfESSRecentActivity.clear();
        for (var item in listItems) {
          EssAnnouncementModel announcementModel =
              EssAnnouncementModel.fromJson(item);
          listOfEssAnnouncementModels.add(announcementModel);
        }
        _getEssAnnouncementWidgets();
      }
    }
  }

  _getEssAnnouncementWidgets() {
    listOfAnnouncementHomeScreenWidgets.clear();
    for (var item in listOfEssAnnouncementModels) {
      if (listOfAnnouncementHomeScreenWidgets.length >= 3) {
        break;
      }
      listOfAnnouncementHomeScreenWidgets.add(_announcementItem(item));
    }
  }

  _announcementItem(EssAnnouncementModel model) {
    var color = MyColors.getRandomColor();
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _userInfoWidget(model: model),
                SizedBox(
                  height: 10,
                ),
                Text(
                  model.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {},
                    child: Center(
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: color,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                            model.announcementlink,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: color,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userInfoWidget({
    required EssAnnouncementModel model,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            // backgroundColor: Colors.white,
            // backgroundImage: AssetImage("assets/images/profilesample.jpg"),
            backgroundImage: CachedNetworkImageProvider(model.imageurl),
            radius: 25,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.caption,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Color(0xffA7A7A7),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    model.subheading,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffA7A7A7),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  //-----Attendance----------
  var recordId = '';
  var punchInResp = '';
  // getCardDataSources() async {
  //   if (actionData.length > 1) {
  //     return actionData;
  //   } else {
  //     // var dataSourceUrl = baseUrl + GlobalConfiguration().get("HomeCardDataResponse").toString();
  //     var dataSourceUrl = Const.getFullARMUrl(
  //         ServerConnections.API_GET_HOMEPAGE_CARDSDATASOURCE);
  //     var dataSourceBody = body;
  //     dataSourceBody["sqlParams"] = {
  //       "param": "value",
  //       "username": appStorage.retrieveValue(AppStorage.USER_NAME)
  //     };

  //     actionData.clear();
  //     for (var items in setOfDatasource) {
  //       if (items.toString() != "") {
  //         dataSourceBody["datasource"] = items;
  //         // setOfDatasource.remove(items);
  //         var dsResp = await serverConnections.postToServer(
  //             url: dataSourceUrl,
  //             isBearer: true,
  //             body: jsonEncode(dataSourceBody));
  //         if (dsResp != "") {
  //           var jsonDSResp = jsonDecode(dsResp);
  //           // print(jsonDSResp);
  //           if (jsonDSResp['result']['success'].toString() == "true") {
  //             var dsDataList = jsonDSResp['result']['data'];
  //             for (var item in dsDataList) {
  //               var list = [];
  //               list = actionData[item['cardname']] != null
  //                   ? actionData[item['cardname']]
  //                   : [];
  //               CardOptionModel cardOptionModel =
  //                   CardOptionModel.fromJson(item);

  //               if (list.indexOf(cardOptionModel) < 0)
  //                 list.add(cardOptionModel);
  //               actionData[item['cardname']] = list;
  //             }
  //           }
  //         }
  //       }
  //     }
  //   }
  // }
  getPunchINData() async {
    LoadingScreen.show();

    var url = Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);
    var body = {
      "publickey": "AXPKEY000000010003",
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "username": appStorage.retrieveValue(AppStorage.USER_NAME),
      "Project": appStorage.retrieveValue(AppStorage.PROJECT_NAME),
      "getsqldata": {
        "username": appStorage.retrieveValue(AppStorage.USER_NAME),
        "trace": "false"
      },
      "sqlparams": {}
    };
    var resp = await serverConnections.postToServer(
        url: url, body: jsonEncode(body), isBearer: true);

    log("Resp:|Get Punch IN data| ${resp}");
    punchInResp = resp;
    print("ExecuteApi Resp: ${resp}");
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['success'].toString() == "true") {
        var rows = jsonResp['punchin_out_status']['rows'];
        if (rows.length == 0) {
          // isShowPunchIn.value = true;
          // isShowPunchOut.value = false;
        } else {
          var firstRowVal = rows[0];
          // isShowPunchIn.value = false;
          // isShowPunchOut.value = true;
          recordId = firstRowVal['recordid'] ?? '';
        }
      } else {
        // isShowPunchIn.value = true;
      }
    }

    LoadingScreen.dismiss();
  }

  onClick_PunchIn() async {
    // print(punchInResp);
    LoadingScreen.show();
    // var secretEncryptedKey =
    //     await getEncryptedSecretKey(ExecuteApi.API_SECRETKEY_GET_DO_PUNCHIN);
    Position? currentLocation = await CommonMethods.getCurrentLocation();
    var latitude = currentLocation?.latitude ?? "";
    var longitude = currentLocation?.longitude ?? "";
    // String address = '';
    String address = await CommonMethods.getAddressFromLatLng(currentLocation!);
    ////currentLocation != null ? await CommonMethods.getAddressFromLatLng(currentLocation) : "";
    log("address: ${address.toString()}");
    var url = Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);
    var body = {
      "publickey": "AXPKEY000000010002",
      "project": appStorage.retrieveValue(AppStorage.PROJECT_NAME),
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "submitdata": {
        "username": appStorage.retrieveValue(AppStorage.USER_NAME),
        "trace": "false",
        "dataarray": {
          "data": {
            "mode": "new",
            "recordid": "0",
            "dc1": {
              "row1": {
                "latitude": latitude,
                "longitude": longitude,
                "status": "IN",
                "inloc": address
              }
            }
          }
        }
      }
    };
    // print("punch_IN_Body: ${jsonEncode(body)}");
    var resp = await serverConnections.postToServer(
        url: url, body: jsonEncode(body), isBearer: true);

    //print("PunchIN_resp: $resp");
    print(resp);
    log("Resp:|Punch IN| ${resp.toString()}");
    if (resp.toString() == '') return;
    var jsonResp = jsonDecode(resp);
    LoadingScreen.dismiss();

    if (jsonResp['success'].toString() == "true") {
      // var result = jsonResp['result'].toString();
      Get.snackbar("Punch-In success", "",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3));
      // isShowPunchIn.value = false;
      // isShowPunchOut.value = true;
      // actionData.clear();
      // await getCardDataSources();
    } else {
      // var errMessage = jsonResp['message'].toString();
      Get.snackbar("Error", jsonResp['message'].toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3));
    }
  }

  onClick_PunchOut() async {
    LoadingScreen.show();

    Position? currentLocation = await CommonMethods.getCurrentLocation();
    var latitude = currentLocation?.latitude ?? "";
    var longitude = currentLocation?.longitude ?? "";
    // String address = '';
    String address = await CommonMethods.getAddressFromLatLng(currentLocation!);
    //currentLocation != null ? await CommonMethods.getAddressFromLatLng(currentLocation) : "";
    log("address: ${address.toString()}");

    var url = Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);
    var body = {
      "publickey": "AXPKEY000000010002",
      "project": appStorage.retrieveValue(AppStorage.PROJECT_NAME),
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "submitdata": {
        "username": appStorage.retrieveValue(AppStorage.USER_NAME),
        "trace": "false",
        "dataarray": {
          "data": {
            "mode": "edit",
            "recordid": recordId,
            "dc1": {
              "row1": {
                "olatitude": latitude,
                "olongitude": longitude,
                "status": "OUT",
                "outloc": address
              }
            }
          }
        }
      }
    };
    var resp = await serverConnections.postToServer(
        url: url, body: jsonEncode(body), isBearer: true);
    log("Resp:|Punch OUT| ${resp}");
    if (resp.toString() == '') return;

    print(resp);
    var jsonResp = jsonDecode(resp);

    if (jsonResp['success'].toString() == "true") {
      // var result = jsonResp['result'].toString();
      Get.snackbar("Punch-Out success", "",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3));
      // actionData.clear();
      // await getCardDataSources();
    } else {
      // var errMessage = jsonResp['message'].toString();
      Get.snackbar("Error", jsonResp['message'].toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3));
    }
    LoadingScreen.dismiss();
  }
  //-------Quick links----->

  var listOfOptionCards = [].obs;
  var list_menuFolderData = {}.obs;
  // var listOfGridCardItems = [].obs;
  var actionData = {};
  Set setOfDatasource = {};

  getCardDetails() async {
    // isLoading.value = true;
    LoadingScreen.show();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_HOMEPAGE_CARDS_v2);
    var resp = await serverConnections.postToServer(
        url: url, body: jsonEncode(body), isBearer: true);
    // print(resp);
    if (resp != "") {
      print("Home card ${resp}");
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['success'].toString() == "true") {
        listOfOptionCards.clear();
        var dataList = jsonResp['result']['menu option'];
        for (var item in dataList) {
          CardModel cardModel = CardModel.fromJson(item);
          listOfOptionCards.add(cardModel);
          setOfDatasource.add(item['datasource'].toString());
        }

        var menuFolderList = [];
        var data_menuFolder = jsonResp['result']['menu folder'];
        for (var item in data_menuFolder) {
          MenuFolderModel menuFolderModel = MenuFolderModel.fromJson(item);
          menuFolderList.add(menuFolderModel);
        }
        parseMenuFolderData(menuFolderList);
      } else {
        //error
      }
    }
    // if (listOfCards.length == 0) {
    //   print("Length:   0");
    //   Get.defaultDialog(
    //       title: "Alert!",
    //       middleText: "Session Timed Out",
    //       confirm: ElevatedButton(
    //           onPressed: () {
    //             Get.back();
    //           },
    //           child: Text("Ok")));
    // }
    await getCardDataSources();
    // listOfCards..sort((a, b) => a.caption.toString().toLowerCase().compareTo(b.caption.toString().toLowerCase()));
    // isLoading.value = false;
    LoadingScreen.dismiss();
    return listOfOptionCards;
  }

  getCardDataSources() async {
    if (actionData.length > 1) {
      return actionData;
    } else {
      // var dataSourceUrl = baseUrl + GlobalConfiguration().get("HomeCardDataResponse").toString();
      var dataSourceUrl = Const.getFullARMUrl(
          ServerConnections.API_GET_HOMEPAGE_CARDSDATASOURCE);
      var dataSourceBody = body;
      dataSourceBody["sqlParams"] = {
        "param": "value",
        "username": appStorage.retrieveValue(AppStorage.USER_NAME)
      };

      actionData.clear();
      for (var items in setOfDatasource) {
        if (items.toString() != "") {
          dataSourceBody["datasource"] = items;
          // setOfDatasource.remove(items);
          var dsResp = await serverConnections.postToServer(
              url: dataSourceUrl,
              isBearer: true,
              body: jsonEncode(dataSourceBody));
          if (dsResp != "") {
            var jsonDSResp = jsonDecode(dsResp);
            // print(jsonDSResp);
            if (jsonDSResp['result']['success'].toString() == "true") {
              var dsDataList = jsonDSResp['result']['data'];
              for (var item in dsDataList) {
                var list = [];
                list = actionData[item['cardname']] != null
                    ? actionData[item['cardname']]
                    : [];
                CardOptionModel cardOptionModel =
                    CardOptionModel.fromJson(item);

                if (list.indexOf(cardOptionModel) < 0)
                  list.add(cardOptionModel);
                actionData[item['cardname']] = list;
              }
            }
          }
        }
      }
    }
  }

  void parseMenuFolderData(List menuFolderList) {
    var map_folderList = {};
    for (var item in menuFolderList) {
      var folderName = item.groupfolder;
      List<MenuFolderModel> list = [];
      list = map_folderList[folderName] ?? [];
      list.add(item);
      map_folderList[folderName] = list;
    }
    list_menuFolderData.value = map_folderList;
    print("list_menuFolderData: ${list_menuFolderData.toString()}");
  }

  //-------Drawer-----------------
  indexChange(value) {
    MenuHomePageController menuHomePageController = Get.find();
    menuHomePageController.switchPage.value = false;
    // bottomIndex.value = value;
  }

  clearCacheData() async {
    var tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }

  signOut() async {
    var body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var url = Const.getFullARMUrl(ServerConnections.API_SIGNOUT);

    Get.defaultDialog(
        title: "Log out",
        middleText: "Are you sure you want to log out?",
        confirm: ElevatedButton(
            onPressed: () async {
              Get.back();
              LoadingScreen.show();
              try {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                clearCacheData();
              } catch (e) {}
              appStorage.storeValue(AppStorage.USER_NAME, "");
              await serverConnections.postToServer(
                  url: url, body: jsonEncode(body));
              LoadingScreen.dismiss();
              Get.offAllNamed(Routes.Login);
              // if (resp != "" && !resp.toString().contains("error")) {
              //   var jsonResp = jsonDecode(resp);
              //   if (jsonResp['result']['success'].toString() == "true") {
              //     appStorage.remove(AppStorage.SESSIONID);
              //     appStorage.remove(AppStorage.TOKEN);
              //
              //   } else {
              //     error(jsonResp['result']['message'].toString());
              //   }
              // } else {
              //   error("Some error occurred");
              // }
            },
            child: Text("Yes")),
        cancel: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.grey)),
            onPressed: () {
              Get.back();
            },
            child: Text("No")));
  }

  Widget _userInfoMenuWidget({
    required String username,
    required String companyName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 32,
              child: CircleAvatar(
                // backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/images/profilesample.jpg"),
                radius: 30,
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
                  username,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warehouse,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      companyName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  getDrawerTileList() {
    List<Widget> menuList = [];
    menuList.add(
      DrawerHeader(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff3764FC),
                Color(0xff9764DA),
              ]),
        ),
        child: _userInfoMenuWidget(
            username: userName.value, companyName: "Agile labs"),
      ),
    );
    var a =
        menuMorePageController.menu_finalList.map(build_innerListTile).toList();
    menuList.addAll(a);

    if (menuList.length == 1) {
      menuList.add(ListTile(
        tileColor: Colors.white,
        onTap: () {
          Get.back();
          indexChange(0);
        },
        leading: Icon(Icons.home_outlined),
        title: Text("Home"),
      ));
      menuList.add(ListTile(
        tileColor: Colors.white,
        onTap: () {
          Get.back();
          indexChange(1);
        },
        leading: Icon(Icons.view_list_outlined),
        title: Text("Active List"),
      ));
      menuList.add(ListTile(
        tileColor: Colors.white,
        onTap: () {
          Get.back();
          indexChange(2);
        },
        leading: Icon(Icons.speed_outlined),
        title: Text("Dashboard"),
      ));
      menuList.add(ListTile(
        tileColor: Colors.white,
        onTap: () {
          Get.back();
          indexChange(3);
        },
        leading: Icon(Icons.calendar_month_outlined),
        title: Text("Calendar"),
      ));
      menuList.add(ListTile(
        tileColor: Colors.white,
        onTap: () {
          Get.back();
          indexChange(4);
        },
        leading: Icon(Icons.dashboard_customize_outlined),
        title: Text("More"),
      ));
      menuList.add(ListTile(
        tileColor: Colors.white,
        onTap: () {
          Get.back();
          signOut();
        },
        leading: Icon(Icons.power_settings_new),
        title: Text("Logout"),
      ));
      menuList.add(SizedBox(
        height: MediaQuery.of(Get.context!).size.height - 540,
      ));
    }
    menuList.add(Container(
      color: Colors.white,
      height: 70,
      child: Center(
          child: Text(
        'App Version: ${Const.APP_VERSION}\n© agile-labs.com ${DateTime.now().year}',
        textAlign: TextAlign.center,
      )),
    ));

    return menuList;
  }

  Widget build_innerListTile(tile, {double leftPadding = 15}) {
    MenuItemNewmModel model_tile = tile;
    if (model_tile.childList.isEmpty) {
      return Visibility(
        visible: model_tile.visible.toUpperCase() == "T",
        child: InkWell(
          onTap: () {
            menuMorePageController.openItemClick(model_tile);
            Get.back();
          },
          child: ListTile(
            tileColor: Colors.white,
            leading: Icon(menuMorePageController.generateIcon(tile, 1)),
            contentPadding: EdgeInsets.only(left: leftPadding),
            title: Text(
              model_tile.caption,
            ),
          ),
        ),
      );
    } else {
      return Visibility(
        visible: model_tile.visible.toUpperCase() == "T",
        child: ExpansionTile(
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white70,
          leading: Icon(menuMorePageController.generateIcon(tile, 1)),
          tilePadding: EdgeInsets.only(left: leftPadding, right: 10),
          title: Text(tile.caption),
          children: ListTile.divideTiles(
                  context: Get.context,
                  tiles: model_tile.childList.map((tile) =>
                      build_innerListTile(tile, leftPadding: leftPadding + 15)))
              .toList(),
        ),
      );
    }
  }

  getDrawerInnerListTile(
      MenuMorePageController menuMorePageController, item, index) {
    List<Widget> innerTile = [];
    innerTile.add(Container(
      height: 1,
      color: Colors.white,
      // color: Colors.grey.withOpacity(0.1),
    ));
    for (MenuItemModel subMenu
        in menuMorePageController.finalHeadingWiseData[item] ?? [])
      innerTile.add(InkWell(
        onTap: () {
          menuMorePageController.openItemClick(subMenu);
          Get.back();
        },
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          // menuMorePageController.IconList[index++ % 8]
          child: ListTile(
              leading:
                  Icon(menuMorePageController.generateIcon(subMenu, index++)),
              title: Text(subMenu.caption.toString())),
        ),
      ));

    return ListTile.divideTiles(context: Get.context, tiles: innerTile);
    // return innerTile;
  }
}
