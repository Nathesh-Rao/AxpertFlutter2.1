import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/models/ESSRecentActivityModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_icons_named/material_icons_named.dart';

import '../../../../Constants/CommonMethods.dart';
import '../../../../Constants/MyColors.dart';
import '../../../../Constants/const.dart';
import '../../../../Utils/ServerConnections/ExecuteApi.dart';
import '../../../../Utils/ServerConnections/ServerConnections.dart';
import '../models/ESSAnnouncementModel.dart';

class EssController extends GetxController {
  AppStorage appStorage = AppStorage();
  ServerConnections serverConnections = ServerConnections();
  @override
  void onInit() {
    scrollController.addListener(_scrollListener);

    super.onInit();
  }

  EssController() {
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
    String address = '';
    // String address = await CommonMethods.getAddressFromLatLng(
    //     currentLocation);
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
    String address = '';
    // String address = await CommonMethods.getAddressFromLatLng(
    //     currentLocation!);
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
}
