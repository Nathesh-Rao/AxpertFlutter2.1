import 'dart:convert';

import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/Utils/ServerConnections/EncryptionRules.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';

class ExecuteApi {
  static const String SECRETKEY_HomePage = "1965065173127450";
  static const String API_GET_ENCRYPTED_SECRET_KEY =
      "api/v1/ARMGetEncryptedSecret";
  static const String API_ARM_EXECUTE = "api/v1/ARMExecuteAPI";
  static const String API_ARM_EXECUTE_PUBLISHED =
      "api/v1/ARMExecutePublishedAPI";
  static const String API_SECRETKEY_GET_PUNCHIN_DATA = "5246994904522510";
  static const String API_SECRETKEY_GET_DO_PUNCHIN = "1408279244140740";
  static const String API_SECRETKEY_GET_DO_PUNCHOUT = "1408279244140740";

  static const String API_PrivateKey_DashBoard = "9511835779821320";
  static const String API_PublicKey_DashBoard = "AXPKEY000000010002";
  static const String API_PrivateKey_Attendance = "9876583824480530";
  static const String API_PublicKey_Attendance = "AXPKEY000000010018";
  static const String API_PublicKey_ESS_RecentActivity =
      "AXM_API_ESS_GET_RECENTACTIVITY";
  static const String API_PublicKey_ESS_Announcement =
      "AXM_API_ESS_GET_ANNOUNCEMENT";
  static const String API_PublicKey_ESS_Banners = "AXM_API_ESS_GET_BANNERS";
  //----recent-activity

  // var body;
  var url = Const.getFullARMUrl(API_ARM_EXECUTE_PUBLISHED);

  CallFetchData_ExecuteAPI({body = '', isBearer = false, header = ''}) async {
    var resp = await ServerConnections().postToServer(
        url: url,
        header: header,
        body: body,
        isBearer: isBearer,
        show_errorSnackbar: false);
    return resp;
  }

  CallSaveData_ExecuteAPI({body = '', isBearer = false, header = ''}) async {
    var resp = await ServerConnections().postToServer(
        url: url,
        header: header,
        body: body,
        isBearer: isBearer,
        show_errorSnackbar: false);
    resp;
  }
}
