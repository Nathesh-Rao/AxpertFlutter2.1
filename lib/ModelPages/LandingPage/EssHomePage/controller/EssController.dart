import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/models/ESSRecentActivityModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_icons_named/material_icons_named.dart';

import '../../../../Constants/MyColors.dart';
import '../../../../Constants/const.dart';
import '../../../../Utils/ServerConnections/ExecuteApi.dart';
import '../models/ESSAnnouncementModel.dart';

class EssController extends GetxController {
  AppStorage appStorage = AppStorage();
  @override
  void onInit() {
    scrollController.addListener(_scrollListener);

    super.onInit();
  }

  EssController() {
    getESSRecentActivity();
    getESSAnnouncement();
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
      log(resp.toString());
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
    log(resp.toString());
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
}
