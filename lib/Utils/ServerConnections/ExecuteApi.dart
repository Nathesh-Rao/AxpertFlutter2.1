import 'dart:convert';

import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/Utils/ServerConnections/EncryptionRules.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';

class ExecuteApi {
  static const String SECRETKEY_HomePage = "1965065173127450";
  static const String API_GET_ENCRYPTED_SECRET_KEY =
      "api/v1/ARMGetEncryptedSecret";
  static const String API_ARM_EXECUTE = "api/v1/ARMExecuteAPI";
  //SUBMIT API
  static const String API_ARM_EXECUTE_PUBLISHED =
      "api/v1/ARMExecutePublishedAPI";
  static const String API_SECRETKEY_GET_PUNCHIN_DATA = "5246994904522510";
  static const String API_SECRETKEY_GET_DO_PUNCHIN = "1408279244140740";
  static const String API_SECRETKEY_GET_DO_PUNCHOUT = "1408279244140740";

  static const String API_PRIVATEKEY_DASHBOARD = "9511835779821320";
  static const String API_PUBLICKEY_DASHBOARD = "AXPKEY000000010002";
  static const String API_PRIVATEKEY_ATTENDANCE = "9876583824480530";
  static const String API_PUBLICKEY_ATTENDANCE = "AXPKEY000000010018";
  static const String API_PUBLICKEY_ESS_RECENTACTIVITY =
      "AXM_API_ESS_GET_RECENTACTIVITY";
  static const String API_PUBLICKEY_ESS_ANNOUNCEMENT =
      "AXM_API_ESS_GET_ANNOUNCEMENT";
  static const String API_PUBLICKEY_ESS_BANNERS = "AXM_API_ESS_GET_BANNERS";
  //----Attendance
  static const String API_PUBLICKEY_ATTENDANCE_TEAMMEMBERS =
      "AXM_API_GETTEAMMEMBERS";
  static const String API_PUBLICKEY_ATTENDANCE_GEODETAILS =
      "AXM_API_GETATTENDANCE_GEODETAILS";
  static const String API_PUBLICKEY_ATTENDANCE_ATTENDANCEDETAILS =
      "AXM_API_GETATTENDANCE_DETAIL";
  static const String API_PUBLICKEY_ATTENDANCE_ATTENDANCEREPORT =
      "AXM_API_GETATTENDANCE_REPORT";
  static const String API_PUBLICKEY_ATTENDANCE_LEAVEDETAILS =
      "AXM_API_GETLEAVEDETAILS";

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
