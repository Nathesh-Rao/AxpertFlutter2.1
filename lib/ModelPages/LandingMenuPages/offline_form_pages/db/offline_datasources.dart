import 'dart:convert';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/Utils/ServerConnections/ExecuteApi.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OfflineDatasources {
  static final http.Client _client = http.Client();

  // API ENDPOINTS
  static const String API_FETCH_OFFLINE_PAGES = '/api/offline/pages';
  // static const String API_SUBMIT_OFFLINE_FORM_REST =
  //     'https://agileqa.agilecloud.biz/qaaxpert11.4basescripts/ASBTStructRest.dll/datasnap/rest/TASBTstruct/savedata';

// static const String API_SUBMIT_OFFLINE_FORM = ExecuteApi.API_ARM_EXECUTE_PUBLISHED;
  static String API_FETCH_DATASOURCE(String name) {
    return '/api/datasource/$name';
  }

  static String baseUrl = '';

  // COMMON HEADERS
  static Map<String, String> _jsonHeader({String? bearerToken}) {
    if (bearerToken != null && bearerToken.isNotEmpty) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  // GET CALL
  static Future<String?> get({
    required String endpoint,
    String? bearerToken,
  }) async {
    try {
      final uri = Uri.parse(baseUrl + endpoint);
      final response = await _client.get(
        uri,
        headers: _jsonHeader(bearerToken: bearerToken),
      );

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // POST CALL
  static Future<String?> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    try {
      final uri = Uri.parse(baseUrl + endpoint);
      final response = await _client.post(
        uri,
        headers: _jsonHeader(bearerToken: bearerToken),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> fetchDatasource({
    required String datasourceName,
    required String sessionId,
    required String username,
    required String appName,
    Map<String, dynamic>? sqlParams,
  }) async {
    final url =
        Const.getFullARMUrl(ServerConnections.API_GET_HOMEPAGE_CARDSDATASOURCE);

    final body = {
      "ARMSessionId": sessionId,
      "username": username,
      "appname": appName,
      "datasource": datasourceName,
      "sqlParams": sqlParams ?? {},
    };
    debugPrint("DATA_SOURCE body=> $body");

    return await ServerConnections().postToServer(
      url: url,
      isBearer: true,
      body: jsonEncode(body),
    );
  }
}
