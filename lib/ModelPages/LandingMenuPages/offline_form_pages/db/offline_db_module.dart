import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/data_source_model.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_page_model.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:axpertflutter/Utils/ServerConnections/ExecuteApi.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'offline_datasources.dart';
import 'offline_db_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

enum SubmitStatus { success, savedOffline, apiFailure }

class OfflineDbModule {
  OfflineDbModule._();
  // static ServerConnections serverConnections = ServerConnections();
  static Database? _db;

  // INIT

  static var autoSync = false;

  static Future<bool> toggleAutoSync() async {
    var appstrg = AppStorage();

    bool current = await appstrg.retrieveValue(AppStorage.AUTO_SYNC) ?? false;

    bool newValue = !current;

    await appstrg.storeValue(AppStorage.AUTO_SYNC, newValue);

    autoSync = newValue;

    return newValue;
  }

  static Future<void> init() async {
    autoSync = await AppStorage().retrieveValue(AppStorage.AUTO_SYNC) ?? false;
    final dbPath = join(await getDatabasesPath(), 'offline_forms.db');

    _db = await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, _) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        const tag = "[OFFLINE_DB_UPGRADE_002]";
        LogService.writeLog(
            message: "$tag[START] Upgrading DB $oldVersion → $newVersion");

        await db.execute(
            "DROP TABLE IF EXISTS ${OfflineDBConstants.TABLE_OFFLINE_PAGES}");
        await db.execute(
            "DROP TABLE IF EXISTS ${OfflineDBConstants.TABLE_DATASOURCES}");
        await db.execute(
            "DROP TABLE IF EXISTS ${OfflineDBConstants.TABLE_DATASOURCE_DATA}");
        await db.execute(
            "DROP TABLE IF EXISTS ${OfflineDBConstants.TABLE_PENDING_REQUESTS}");
        await db.execute(
            "DROP TABLE IF EXISTS ${OfflineDBConstants.TABLE_OFFLINE_USER}");

        await _createTables(db);

        LogService.writeLog(message: "$tag[SUCCESS] DB recreated");
      },
    );
  }

  static Database get _database {
    if (_db == null) {
      throw Exception('OfflineDbModule not initialized');
    }
    return _db!;
  }

  static Future<void> _createTables(Database db) async {
    await db.execute(OfflineDBConstants.CREATE_OFFLINE_PAGES_TABLE);
    await db.execute(OfflineDBConstants.CREATE_DATASOURCES_TABLE);
    await db.execute(OfflineDBConstants.CREATE_DATASOURCE_DATA_TABLE);
    await db.execute(OfflineDBConstants.CREATE_PENDING_REQUESTS_TABLE);
    await db.execute(OfflineDBConstants.CREATE_OFFLINE_USER_TABLE);
  }

  static Future<void> handlePostLogin({
    required bool isInternetAvailable,
  }) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await _handlePostLoginInternal(
      isInternetAvailable: isInternetAvailable,
      username: scope['username']!,
      projectName: scope['projectName']!,
    );
  }

  static Future<void> _handlePostLoginInternal({
    required bool isInternetAvailable,
    required String username,
    required String projectName,
  }) async {
    const tag = "[OFFLINE_HANDLE_POST_LOGIN_001]";

    LogService.writeLog(
      message:
          "$tag[START] user=$username project=$projectName internet=$isInternetAvailable",
    );

    // // 1. Sync THIS user's pending queue

    if (autoSync) {
      await _syncPendingBeforeLogin(
        username: username,
        projectName: projectName,
        isInternetAvailable: isInternetAvailable,
      );
    }

    // 2. Fetch offline pages ONLY for this user+project
    final pages = await fetchAndStoreOfflinePages();

    if (pages.isEmpty) {
      LogService.writeLog(message: "$tag[INFO] No offline pages received");
      return;
    }

    await fetchAndStoreAllDatasourcesForAllForms(pages);

    LogService.writeLog(
      message: "$tag[SUCCESS] Offline bootstrap done. pages=${pages.length}",
    );
  }

  static Future<void> fetchAndStoreAllDatasourcesForAllForms(
    List<Map<String, dynamic>> pages,
  ) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    final username = scope['username']!;
    final projectName = scope['projectName']!;

    final sessionId = AppStorage().retrieveValue(AppStorage.SESSIONID) ?? "";

    for (final page in pages) {
      final transId = page['transid']?.toString();
      if (transId == null || transId.isEmpty) continue;

      final Set<String> dsSet = {};

      final fields = page['fields'] as List<dynamic>? ?? [];
      for (final f in fields) {
        final ds = f['datasource'];
        if (ds != null && ds.toString().trim().isNotEmpty) {
          dsSet.add(ds.toString().trim());
        }
      }

      // Fetch datasources for THIS transId
      for (final ds in dsSet) {
        // Check cache (scoped by transId)
        final exists = await _database.query(
          OfflineDBConstants.TABLE_DATASOURCE_DATA,
          where: '''
          ${OfflineDBConstants.COL_USERNAME} = ? AND
          ${OfflineDBConstants.COL_PROJECT_NAME} = ? AND
          ${OfflineDBConstants.COL_TRANS_ID} = ? AND
          ${OfflineDBConstants.COL_DATASOURCE_NAME} = ?
        ''',
          whereArgs: [username, projectName, transId, ds],
          limit: 1,
        );

        if (exists.isNotEmpty) continue;

        final res = await OfflineDatasources.fetchDatasource(
          datasourceName: ds,
          sessionId: sessionId,
          username: username,
          appName: projectName,
          sqlParams: {"username": username},
        );

        debugPrint("fetchDatasource: $ds  => res => $res");
        if (res == null || res.isEmpty) continue;

        await _database.insert(
          OfflineDBConstants.TABLE_DATASOURCE_DATA,
          {
            OfflineDBConstants.COL_USERNAME: username,
            OfflineDBConstants.COL_PROJECT_NAME: projectName,
            OfflineDBConstants.COL_TRANS_ID: transId,
            OfflineDBConstants.COL_DATASOURCE_NAME: ds,
            OfflineDBConstants.COL_RESPONSE_JSON: res,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAndStoreOfflinePages() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return [];

    return _fetchAndStoreOfflinePagesInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
    );
  }

  static Future<List<Map<String, dynamic>>> _fetchAndStoreOfflinePagesInternal({
    required String username,
    required String projectName,
  }) async {
    const String tag = "[OFFLINE_PAGES_FETCH_001]";

    try {
      LogService.writeLog(
          message: "$tag[START] Fetching offline pages from JSON file");

      final res = await http.get(
        Uri.parse(OfflineDBConstants.OFFLINE_PAGES_URL),
      );

      if (res.statusCode != 200) {
        LogService.writeLog(
          message: "$tag[FAILED] HTTP ${res.statusCode} while fetching JSON",
        );
        return [];
      }

      final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
      final pages = decoded.map((e) => e as Map<String, dynamic>).toList();

      if (pages.isEmpty) {
        LogService.writeLog(message: "$tag[INFO] JSON has 0 pages");
        return [];
      }

      await _database.delete(
        OfflineDBConstants.TABLE_OFFLINE_PAGES,
        where:
            '${OfflineDBConstants.COL_USERNAME} = ? AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?',
        whereArgs: [username, projectName],
      );

      final batch = _database.batch();

      for (final page in pages) {
        batch.insert(
          OfflineDBConstants.TABLE_OFFLINE_PAGES,
          {
            OfflineDBConstants.COL_USERNAME: username,
            OfflineDBConstants.COL_PROJECT_NAME: projectName,
            OfflineDBConstants.COL_TRANS_ID: page['transid'],
            OfflineDBConstants.COL_PAGE_JSON: jsonEncode(page),
            OfflineDBConstants.COL_FETCHED_AT: DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);

      final dsString = _extractDatasourceString(pages);

      await _saveDatasourceString(
        username: username,
        projectName: projectName,
        value: dsString,
      );

      LogService.writeLog(
        message:
            "$tag[SUCCESS] Replaced pages with ${pages.length} records for $username / $projectName",
      );

      return pages;
    } catch (e, st) {
      LogService.writeLog(
        message: "$tag[FAILED] Exception while fetching pages => $e",
      );
      LogService.writeLog(
        message: "$tag[STACK] $st",
      );
      return [];
    }
  }

  static Future<int> getOfflinePagesCount() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return 0;

    return _getOfflinePagesCountInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
    );
  }

  static Future<int> _getOfflinePagesCountInternal({
    required String username,
    required String projectName,
  }) async {
    final res = await _database.rawQuery(
      '''
    SELECT COUNT(*) as cnt 
    FROM ${OfflineDBConstants.TABLE_OFFLINE_PAGES}
    WHERE ${OfflineDBConstants.COL_USERNAME} = ?
      AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
    ''',
      [username, projectName],
    );

    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getOfflinePages() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return [];

    return _getOfflinePagesInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
    );
  }

  static Future<List<Map<String, dynamic>>> _getOfflinePagesInternal({
    required String username,
    required String projectName,
  }) async {
    final result = await _database.query(
      OfflineDBConstants.TABLE_OFFLINE_PAGES,
      where: '''
      ${OfflineDBConstants.COL_USERNAME} = ? AND
      ${OfflineDBConstants.COL_PROJECT_NAME} = ?
    ''',
      whereArgs: [username, projectName],
      orderBy: OfflineDBConstants.COL_FETCHED_AT + ' DESC',
    );

    return result
        .map(
          (e) => jsonDecode(e[OfflineDBConstants.COL_PAGE_JSON] as String)
              as Map<String, dynamic>,
        )
        .toList();
  }

  // DATASOURCE STRING
  static String _extractDatasourceString(List<Map<String, dynamic>> pages) {
    final Set<String> set = {};

    for (final page in pages) {
      final fields = page['fields'] as List<dynamic>? ?? [];
      for (final f in fields) {
        final ds = f['datasource'];
        if (ds != null && ds.toString().trim().isNotEmpty) {
          set.add(ds.toString().trim());
        }
      }
    }

    return set.join(',');
  }

  static Future<void> _saveDatasourceString({
    required String username,
    required String projectName,
    required String value,
  }) async {
    await _database.insert(
      OfflineDBConstants.TABLE_DATASOURCES,
      {
        OfflineDBConstants.COL_USERNAME: username,
        OfflineDBConstants.COL_PROJECT_NAME: projectName,
        OfflineDBConstants.COL_DATASOURCE_NAMES: value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<String>> _getDatasourceList({
    required String username,
    required String projectName,
  }) async {
    final result = await _database.query(
      OfflineDBConstants.TABLE_DATASOURCES,
      where: '''
      ${OfflineDBConstants.COL_USERNAME} = ? AND
      ${OfflineDBConstants.COL_PROJECT_NAME} = ?
    ''',
      whereArgs: [username, projectName],
      limit: 1,
    );

    if (result.isEmpty) return [];

    final raw =
        result.first[OfflineDBConstants.COL_DATASOURCE_NAMES] as String? ?? '';

    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static Future<void> fetchAndStoreAllDatasources({
    required String transId,
  }) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await _fetchAndStoreAllDatasourcesInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
      transId: transId,
    );
  }

  static Future<void> _fetchAndStoreAllDatasourcesInternal({
    required String username,
    required String projectName,
    required String transId,
  }) async {
    final datasources = await _getDatasourceList(
      username: username,
      projectName: projectName,
    );

    for (final ds in datasources) {
      // Check if already cached for this user+project+form+ds
      final exists = await _database.query(
        OfflineDBConstants.TABLE_DATASOURCE_DATA,
        where: '''
        ${OfflineDBConstants.COL_USERNAME} = ? AND
        ${OfflineDBConstants.COL_PROJECT_NAME} = ? AND
        ${OfflineDBConstants.COL_TRANS_ID} = ? AND
        ${OfflineDBConstants.COL_DATASOURCE_NAME} = ?
      ''',
        whereArgs: [username, projectName, transId, ds],
        limit: 1,
      );

      if (exists.isNotEmpty) continue;

      final scope = await _getLastOfflineUserScope();
      if (scope == null) continue;

      final session = AppStorage().retrieveValue(AppStorage.SESSIONID) ?? "";

      final res = await OfflineDatasources.fetchDatasource(
        datasourceName: ds,
        sessionId: session,
        username: scope['username']!,
        appName: scope['projectName']!,
        sqlParams: {
          "username": scope['username']!,
        },
      );
      debugPrint("DATA_SOURCE res=> $res");
      if (res == null || res.isEmpty) continue;

      await _database.insert(
        OfflineDBConstants.TABLE_DATASOURCE_DATA,
        {
          OfflineDBConstants.COL_USERNAME: username,
          OfflineDBConstants.COL_PROJECT_NAME: projectName,
          OfflineDBConstants.COL_TRANS_ID: transId,
          OfflineDBConstants.COL_DATASOURCE_NAME: ds,
          OfflineDBConstants.COL_RESPONSE_JSON: res,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getDatasourceOptions({
    required String transId,
    required String datasource,
  }) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return [];

    return _getDatasourceOptionsInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
      transId: transId,
      datasource: datasource,
    );
  }

  // static Future<List<Map<String, dynamic>>> _getDatasourceOptionsInternal({
  //   required String username,
  //   required String projectName,
  //   required String transId,
  //   required String datasource,
  // }) async {
  //   final result = await _database.query(
  //     OfflineDBConstants.TABLE_DATASOURCE_DATA,
  //     where: '''
  //     ${OfflineDBConstants.COL_USERNAME} = ? AND
  //     ${OfflineDBConstants.COL_PROJECT_NAME} = ? AND
  //     ${OfflineDBConstants.COL_TRANS_ID} = ? AND
  //     ${OfflineDBConstants.COL_DATASOURCE_NAME} = ?
  //   ''',
  //     whereArgs: [username, projectName, transId, datasource],
  //     limit: 1,
  //   );

  //   if (result.isEmpty) return [];

  //   final decoded = jsonDecode(
  //       result.first[OfflineDBConstants.COL_RESPONSE_JSON] as String);
  //   debugPrint("fetchDatasource : getDatasourceOptions => $decoded");
  //   return decoded["result"]['data'] ?? [];
  // }

  static Future<List<Map<String, dynamic>>> _getDatasourceOptionsInternal({
    required String username,
    required String projectName,
    required String transId,
    required String datasource,
  }) async {
    final result = await _database.query(
      OfflineDBConstants.TABLE_DATASOURCE_DATA,
      where: '''
      ${OfflineDBConstants.COL_USERNAME} = ? AND
      ${OfflineDBConstants.COL_PROJECT_NAME} = ? AND
      ${OfflineDBConstants.COL_TRANS_ID} = ? AND
      ${OfflineDBConstants.COL_DATASOURCE_NAME} = ?
    ''',
      whereArgs: [username, projectName, transId, datasource],
      limit: 1,
    );

    if (result.isEmpty) return [];

    try {
      final jsonStr =
          result.first[OfflineDBConstants.COL_RESPONSE_JSON] as String;
      final decoded = jsonDecode(jsonStr);

      debugPrint("fetchDatasource : getDatasourceOptions => $decoded");

      // 1. Extract the List
      List<dynamic> rawList = [];
      if (decoded is Map<String, dynamic> && decoded.containsKey('result')) {
        rawList = decoded['result']['data'] ?? [];
      } else if (decoded is List) {
        rawList = decoded;
      }

      // 2. CONVERT List<dynamic> -> List<Map<String, dynamic>> (THE FIX)
      return rawList.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      LogService.writeLog(message: "[DS_PARSE_ERROR] $datasource: $e");
      return [];
    }
  }

  // MAP OPTIONS INTO FIELD MODELS
  static Future<List<OfflineFormPageModel>> mapDatasourceOptionsIntoPages({
    required List<OfflineFormPageModel> pages,
  }) async {
    for (final page in pages) {
      // await fetchAndStoreAllDatasources(
      //   transId: page.transId,
      // );

      for (final field in page.fields) {
        if (field.datasource == null || field.datasource!.isEmpty) continue;

        final options = await getDatasourceOptions(
          transId: page.transId,
          datasource: field.datasource!,
        );

        debugPrint(
            "fetchDatasource: mapDatasourceOptionsIntoPages : options => ${options.toString()}");
        // 👇 KEEP RAW OBJECTS
        // field.options = options
        //     .map((e) => DataSourceItem.fromJson(e as Map<String, dynamic>))
        //     .toList();

        field.options = options;
      }
    }

    return pages;
  }

  // =================================================
  // SMART SUBMIT
  // =================================================
  static Future<SubmitStatus> submitFormSmart(
      {required Map<String, dynamic> submitBody,
      required bool isInternetAvailable,
      required bool forceOffline}) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null)
      return SubmitStatus.apiFailure; // Or handles error differently

    return _submitFormSmartInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
      submitBody: submitBody,
      isInternetAvailable: isInternetAvailable,
      force_offline: forceOffline,
    );
  }

  static Future<SubmitStatus> _submitFormSmartInternal({
    required String username,
    required String projectName,
    required Map<String, dynamic> submitBody,
    required bool isInternetAvailable,
    required bool force_offline,
  }) async {
    if (isInternetAvailable && !force_offline) {
      try {
        final ServerConnections serverConnections = ServerConnections();

        final String url =
            Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);
        final Map<String, dynamic> uploadPayload =
            await _convertPayloadPathsToBase64(submitBody);
        final dynamic responseStr = await serverConnections.postToServer(
          url: url,
          body: jsonEncode(uploadPayload),
          isBearer: true,
        );
        log(jsonEncode(submitBody), name: "SUBMIT_RESPONSE_BODY");
        log(responseStr, name: "SUBMIT_RESPONSE_RES");

        if (responseStr != null && responseStr.isNotEmpty) {
          final decoded = jsonDecode(responseStr);

          if (decoded is Map<String, dynamic>) {
            if (decoded['success'] == true) {
              await _deletePayloadFiles(submitBody);
              return SubmitStatus.success;
            } else {
              final msg = decoded['message'] ?? "Unknown Error";
              LogService.writeLog(
                  message: "[API_FAIL] Server returned false: $msg");
              return SubmitStatus.apiFailure;
            }
          }
        }
      } catch (e) {
        LogService.writeLog(message: "[API_EXCEPTION] $e");
      }

      return SubmitStatus.apiFailure;
    }

    await _database.insert(
      OfflineDBConstants.TABLE_PENDING_REQUESTS,
      {
        OfflineDBConstants.COL_USERNAME: username,
        OfflineDBConstants.COL_PROJECT_NAME: projectName,
        OfflineDBConstants.COL_REQUEST_JSON:
            jsonEncode(submitBody), // Saving Paths
        OfflineDBConstants.COL_STATUS: OfflineDBConstants.STATUS_PENDING,
        OfflineDBConstants.COL_CREATED_AT: DateTime.now().toIso8601String(),
      },
    );

    return SubmitStatus.savedOffline;
  }

  // static Future<String> processPendingQueue(
  //     {required bool isInternetAvailable}) async {
  //   if (!isInternetAvailable) return "No internet connection";

  //   final scope = await _getLastOfflineUserScope();
  //   if (scope == null) return "No user session found";

  //   final username = scope['username']!;
  //   final projectName = scope['projectName']!;

  //   final String currentSessionId =
  //       AppStorage().retrieveValue(AppStorage.SESSIONID) ?? "";
  //   if (currentSessionId.isEmpty) return "No active session to sync";

  //   final rows = await _database.query(
  //     OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //     where: '''
  //     ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})
  //     AND ${OfflineDBConstants.COL_USERNAME} = ?
  //     AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
  //   ''',
  //     whereArgs: [username, projectName],
  //     orderBy: OfflineDBConstants.COL_CREATED_AT,
  //   );

  //   if (rows.isEmpty) return "Queue is empty";

  //   int successCount = 0;
  //   int failCount = 0;

  //   final ServerConnections serverConnections = ServerConnections();
  //   final String url =
  //       Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);

  //   for (final row in rows) {
  //     final id = row[OfflineDBConstants.COL_ID] as int;
  //     final bodyStr = row[OfflineDBConstants.COL_REQUEST_JSON] as String;

  //     try {
  //       final Map<String, dynamic> payload = jsonDecode(bodyStr);

  //       payload['ARMSessionId'] = currentSessionId;

  //       final dynamic res = await serverConnections.postToServer(
  //         url: url,
  //         body: jsonEncode(payload),
  //         isBearer: true,
  //       );

  //       bool isSuccess = false;
  //       if (res != null && res.isNotEmpty) {
  //         try {
  //           final decoded = jsonDecode(res);
  //           if (decoded is Map<String, dynamic> && decoded['success'] == true) {
  //             isSuccess = true;
  //           } else {
  //             LogService.writeLog(
  //                 message: "[QUEUE_FAIL] ID: $id - Msg: ${decoded['message']}");
  //           }
  //         } catch (_) {}
  //       }

  //       await _database.update(
  //         OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //         {
  //           OfflineDBConstants.COL_STATUS: isSuccess
  //               ? OfflineDBConstants.STATUS_SUCCESS
  //               : OfflineDBConstants.STATUS_ERROR,
  //         },
  //         where: '${OfflineDBConstants.COL_ID} = ?',
  //         whereArgs: [id],
  //       );

  //       if (isSuccess)
  //         successCount++;
  //       else
  //         failCount++;
  //     } catch (e) {
  //       failCount++;
  //       LogService.writeLog(message: "[QUEUE_PROCESS_ERROR] ID: $id - $e");
  //     }
  //   }

  //   return "Processed: $successCount success, $failCount failed";
  // }

  // static Future<String> processPendingQueue(
  //     {required bool isInternetAvailable}) async {
  //   if (!isInternetAvailable) return "No internet connection";

  //   final scope = await _getLastOfflineUserScope();
  //   if (scope == null) return "No user session found";

  //   final username = scope['username']!;
  //   final projectName = scope['projectName']!;

  //   final String currentSessionId =
  //       AppStorage().retrieveValue(AppStorage.SESSIONID) ?? "";
  //   if (currentSessionId.isEmpty) return "No active session to sync";

  //   // --- FIX START: Fetch ONLY IDs first ---
  //   final idRows = await _database.query(
  //     OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //     columns: [OfflineDBConstants.COL_ID], // <--- Only fetch ID
  //     where: '''
  //     ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})
  //     AND ${OfflineDBConstants.COL_USERNAME} = ?
  //     AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
  //   ''',
  //     whereArgs: [username, projectName],
  //     orderBy: OfflineDBConstants.COL_CREATED_AT,
  //   );

  //   if (idRows.isEmpty) return "Queue is empty";
  //   // --- FIX END ---

  //   int successCount = 0;
  //   int failCount = 0;

  //   final ServerConnections serverConnections = ServerConnections();
  //   final String url =
  //       Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);

  //   // Loop through IDs one by one
  //   for (final row in idRows) {
  //     final id = row[OfflineDBConstants.COL_ID] as int;

  //     try {
  //       // --- FETCH HEAVY DATA INDIVIDUALLY ---
  //       // We fetch the JSON only for this specific ID.
  //       // This ensures the CursorWindow only holds ONE heavy row at a time.
  //       final List<Map<String, Object?>> heavyRow = await _database.query(
  //         OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //         columns: [OfflineDBConstants.COL_REQUEST_JSON],
  //         where: '${OfflineDBConstants.COL_ID} = ?',
  //         whereArgs: [id],
  //       );

  //       if (heavyRow.isEmpty) continue; // Should not happen, but safe check

  //       final bodyStr =
  //           heavyRow.first[OfflineDBConstants.COL_REQUEST_JSON] as String;

  //       // ----------------------------------------
  //       // ... Rest of your existing upload logic ...
  //       final Map<String, dynamic> payload = jsonDecode(bodyStr);

  //       payload['ARMSessionId'] = currentSessionId;

  //       final dynamic res = await serverConnections.postToServer(
  //         url: url,
  //         body: jsonEncode(payload),
  //         isBearer: true,
  //       );

  //       bool isSuccess = false;
  //       if (res != null && res.isNotEmpty) {
  //         try {
  //           final decoded = jsonDecode(res);
  //           if (decoded is Map<String, dynamic> && decoded['success'] == true) {
  //             isSuccess = true;
  //           } else {
  //             LogService.writeLog(
  //                 message: "[QUEUE_FAIL] ID: $id - Msg: ${decoded['message']}");
  //           }
  //         } catch (_) {}
  //       }

  //       // Update status
  //       await _database.update(
  //         OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //         {
  //           OfflineDBConstants.COL_STATUS: isSuccess
  //               ? OfflineDBConstants.STATUS_SUCCESS
  //               : OfflineDBConstants.STATUS_ERROR,

  //         },
  //         where: '${OfflineDBConstants.COL_ID} = ?',
  //         whereArgs: [id],
  //       );

  //       if (isSuccess)
  //         successCount++;
  //       else
  //         failCount++;
  //     } catch (e) {
  //       failCount++;
  //       LogService.writeLog(message: "[QUEUE_PROCESS_ERROR] ID: $id - $e");
  //     }
  //   }

  //   return "Processed: $successCount success, $failCount failed";
  // }

  static Future<String> processPendingQueue({
    required bool isInternetAvailable,
    Function(int current, int total)? onProgress, // Optional UI callback
  }) async {
    log("STARTED", name: "SUBMIT_RESPONSE");
    if (!isInternetAvailable) return "No internet connection";

    final scope = await _getLastOfflineUserScope();
    if (scope == null) return "No user session found";

    final username = scope['username']!;
    final projectName = scope['projectName']!;

    final String currentSessionId =
        AppStorage().retrieveValue(AppStorage.SESSIONID) ?? "";
    if (currentSessionId.isEmpty) return "No active session to sync";

    // 1. Fetch ONLY IDs first (Lightweight)
    final idRows = await _database.query(
      OfflineDBConstants.TABLE_PENDING_REQUESTS,
      columns: [OfflineDBConstants.COL_ID],
      where: '''
      ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})
      AND ${OfflineDBConstants.COL_USERNAME} = ?
      AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
    ''',
      whereArgs: [username, projectName],
      orderBy: OfflineDBConstants.COL_CREATED_AT,
    );

    if (idRows.isEmpty) return "Queue is empty";

    int successCount = 0;
    int failCount = 0;
    int total = idRows.length;

    final ServerConnections serverConnections = ServerConnections();
    final String url =
        Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);

    // 2. Loop through IDs
    for (int i = 0; i < total; i++) {
      final row = idRows[i];
      final id = row[OfflineDBConstants.COL_ID] as int;

      // Update UI Progress
      if (onProgress != null) onProgress(i + 1, total);

      try {
        // 3. SAFE READ: Use _readLargeString (Chunking)
        // This handles both new small JSONs and old massive JSONs safely.
        final bodyStr = await _readLargeString(
          table: OfflineDBConstants.TABLE_PENDING_REQUESTS,
          column: OfflineDBConstants.COL_REQUEST_JSON,
          where: '${OfflineDBConstants.COL_ID} = ?',
          whereArgs: [id],
        );

        if (bodyStr == null || bodyStr.isEmpty) {
          LogService.writeLog(message: "[QUEUE_SKIP] ID: $id - Empty body");
          continue;
        }

        // 4. Decode & Prep
        final Map<String, dynamic> originalPayload = jsonDecode(bodyStr);
        originalPayload['ARMSessionId'] = currentSessionId;

        log(originalPayload.toString(), name: "SUBMIT_RESPONSE_BEFORE");
        // 5. CONVERT PATHS -> BASE64 (The Magic Step)
        // This reads local files and creates a temporary upload-ready map

        final stopwatch1 = Stopwatch()..start();
        final Map<String, dynamic> uploadPayload =
            await _convertPayloadPathsToBase64(originalPayload);
        stopwatch1.stop();
        LogService.writeLog(
          message:
              "[B64_SPEED] ID: _convertPayloadPathsToBase64 - Took: ${stopwatch1.elapsed.inSeconds} s :: ${stopwatch1.elapsedMilliseconds} ms",
        );
        // log(jsonEncode(uploadPayload), name: "SUBMIT_RESPONSE_BODY");
        // debugPrint(
        //     "SUBMIT_RESPONSE_BODY ${jsonEncode(uploadPayload).toString()}");
        // log(jsonEncode(uploadPayload), name: "[PAYLOAD_SPEED]");
        // savePayloadForPostman(uploadPayload,
        //     "${originalPayload['publickey']}${DateTime.now().millisecond}");
        final stopwatch = Stopwatch()..start();
        final dynamic res = await serverConnections.postToServer(
          url: url,
          body: jsonEncode(uploadPayload),
          isBearer: true,
        );
        log(res, name: "SUBMIT_RESPONSE_RES");
        stopwatch.stop();
        LogService.writeLog(
          message:
              "[API_SPEED] ID: $id - Took: ${stopwatch.elapsed.inSeconds} s :: ${stopwatch.elapsedMilliseconds} ms",
        );
        // 7. CHECK SUCCESS
        bool isSuccess = false;
        String? errorMsg;

        if (res != null && res.isNotEmpty) {
          try {
            final decoded = jsonDecode(res);
            if (decoded is Map<String, dynamic> && decoded['success'] == true) {
              isSuccess = true;
            } else {
              errorMsg = decoded['message'] ?? "Unknown Server Error";
            }
          } catch (e) {
            errorMsg = "Parse Error: $e";
          }
        } else {
          errorMsg = "Empty Response";
        }

        if (isSuccess) {
          // 8. CLEANUP: Delete local files to free space
          await _deletePayloadFiles(originalPayload);
          successCount++;
        } else {
          failCount++;
          LogService.writeLog(message: "[QUEUE_FAIL] ID: $id - $errorMsg");
        }

        // 9. UPDATE STATUS
        await _database.update(
          OfflineDBConstants.TABLE_PENDING_REQUESTS,
          {
            OfflineDBConstants.COL_STATUS: isSuccess
                ? OfflineDBConstants.STATUS_SUCCESS
                : OfflineDBConstants.STATUS_ERROR,
          },
          where: '${OfflineDBConstants.COL_ID} = ?',
          whereArgs: [id],
        );
      } catch (e) {
        failCount++;
        log(e.toString(), name: "SUBMIT_RESPONSE_ERR");

        LogService.writeLog(message: "[QUEUE_PROCESS_ERROR] ID: $id - $e");
      }
    }

    return "Processed: $successCount success, $failCount failed";
  }

  static Future<Map<String, dynamic>> _convertPayloadPathsToBase64(
      Map<String, dynamic> originalBody) async {
    Map<String, dynamic> payload = jsonDecode(jsonEncode(originalBody));

    await _recursivePathProcessor(payload, _convertAction);

    return payload;
  }

  static Future<void> savePayloadForPostman(
      Map<String, dynamic> payload, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${name}_payload.json');

    await file.writeAsString(jsonEncode(payload));

    print("✅ FILE SAVED AT SPEED: ${file.path}");
    Get.snackbar("Saved", "File ready for extraction");
  }

  static Future<dynamic> _convertAction(dynamic value) async {
    if (value is String && value.startsWith('/')) {
      final file = File(value);
      if (await file.exists()) {
        // final bytes = await compressFile(file);
        // if (bytes != null) {
        //   var b64 = base64Encode(bytes);

        //   return b64;
        // }

        var b64 = await fileToBase64Correct(file);

        return b64;
      } else {
        return "";
      }
    }
  }

  static Future<String> fileToBase64Correct(File file) async {
    final output = StringBuffer();

    final encoder = Base64Encoder();
    final stream = file.openRead().transform(encoder);

    await for (final chunk in stream) {
      output.write(chunk);
    }

    return output.toString();
  }

  static Future<String> compressAndBase64Large(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 60,
      minWidth: 1280,
      minHeight: 1280,
    );

    if (compressedFile == null) {
      throw Exception('Compression failed');
    }

    final result = await streamFileToBase64(compressedFile);
    await File(targetPath).delete();
    return result;
  }

  static Future<String> streamFileToBase64(XFile file) async {
    final inputStream = file.openRead();
    final base64Sink = StringBuffer();

    await for (var chunk in inputStream) {
      base64Sink.write(base64.encode(chunk));
    }

    return base64Sink.toString();
  }

  static Future<String> compressImageToBase64(File imageFile) async {
    final Uint8List? compressedBytes =
        await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      quality: 65,
      minWidth: 1280,
      minHeight: 1280,
      format: CompressFormat.jpeg,
    );

    if (compressedBytes == null) {
      throw Exception("Compression failed");
    }

    return base64Encode(compressedBytes);
  }

  // static Future<String> compressAndConvertToBase64(File file) async {
  //   final dir = await getTemporaryDirectory();
  //   final targetPath = '${dir.path}/compressed.jpg';
  //   final compressedFile = await FlutterImageCompress.compressAndGetFile(
  //     file.absolute.path,
  //     targetPath,
  //     quality: 70, // 0–100
  //     minWidth: 1080, // resize
  //     minHeight: 1080,
  //     format: CompressFormat.jpeg,
  //   );

  //   // _deleteAction(targetPath);
  //   return base64Encode(await compressedFile!.readAsBytes());
  // }

  static Future<Uint8List?> compressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 70,
    );
    print(file.lengthSync());
    print(result?.length);
    return result;
  }

  static Future<void> _deletePayloadFiles(Map<String, dynamic> body) async {
    await _recursivePathProcessor(body, _deleteAction);
  }

  static Future<void> _recursivePathProcessor(
    dynamic data,
    Future<dynamic> Function(dynamic) action,
  ) async {
    if (data is Map<String, dynamic>) {
      for (var key in data.keys) {
        if (key == 'fileasbase64') {
          var value = data[key];

          if (value is String) {
            data[key] = await action(value);
          } else if (value is List) {
            for (int i = 0; i < value.length; i++) {
              value[i] = await action(value[i]);
            }
          }
        } else {
          await _recursivePathProcessor(data[key], action);
        }
      }
    } else if (data is List) {
      for (var item in data) {
        await _recursivePathProcessor(item, action);
      }
    }
  }

  // Helper action: Delete File
  static Future<dynamic> _deleteAction(dynamic value) async {
    if (value is String && value.startsWith('/')) {
      final file = File(value);
      try {
        if (await file.exists()) {
          await file.delete();
          print("Deleted local image: $value");
        }
      } catch (e) {
        print("Error deleting file: $e");
      }
    }
    return value;
  }

  static Future<String?> _readLargeString({
    required String table,
    required String column,
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final lengthResult = await _database.rawQuery(
      'SELECT length($column) as len FROM $table WHERE $where',
      whereArgs,
    );

    if (lengthResult.isEmpty) return null;
    int totalLength = (lengthResult.first['len'] as int?) ?? 0;

    if (totalLength == 0) return "";

    const int chunkSize = 1000000;
    StringBuffer finalString = StringBuffer();

    for (int offset = 1; offset <= totalLength; offset += chunkSize) {
      final chunkResult = await _database.rawQuery(
        'SELECT substr($column, ?, ?) as chunk FROM $table WHERE $where',
        [offset, chunkSize, ...whereArgs],
      );

      if (chunkResult.isNotEmpty) {
        finalString.write(chunkResult.first['chunk'] as String);
      }
    }

    return finalString.toString();
  }

  static Future<void> _syncPendingBeforeLogin({
    required String username,
    required String projectName,
    required bool isInternetAvailable,
  }) async {
    if (!isInternetAvailable) return;

    final String currentSessionId =
        AppStorage().retrieveValue(AppStorage.SESSIONID) ?? "";
    if (currentSessionId.isEmpty) {
      LogService.writeLog(
          message: "[SYNC_SKIP] No active session ID found for sync");
      return;
    }

    final rows = await _database.query(
      OfflineDBConstants.TABLE_PENDING_REQUESTS,
      where: '''
      ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})
      AND ${OfflineDBConstants.COL_USERNAME} = ?
      AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
    ''',
      whereArgs: [username, projectName],
      orderBy: OfflineDBConstants.COL_CREATED_AT,
    );

    if (rows.isEmpty) return;

    final ServerConnections serverConnections = ServerConnections();
    final String url =
        Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);

    for (final row in rows) {
      final id = row[OfflineDBConstants.COL_ID] as int;
      try {
        final Map<String, dynamic> payload =
            jsonDecode(row[OfflineDBConstants.COL_REQUEST_JSON] as String);

        // 2. OVERRIDE with Fresh Session ID
        payload['ARMSessionId'] = currentSessionId;

        final res = await serverConnections.postToServer(
          url: url,
          body: jsonEncode(payload),
          isBearer: true,
        );

        bool isSuccess = false;
        if (res != null && res.isNotEmpty) {
          try {
            final decoded = jsonDecode(res);
            if (decoded is Map<String, dynamic> && decoded['success'] == true) {
              isSuccess = true;
            }
          } catch (_) {}
        }

        await _database.update(
          OfflineDBConstants.TABLE_PENDING_REQUESTS,
          {
            OfflineDBConstants.COL_STATUS: isSuccess
                ? OfflineDBConstants.STATUS_SUCCESS
                : OfflineDBConstants.STATUS_ERROR,
          },
          where: '${OfflineDBConstants.COL_ID} = ?',
          whereArgs: [id],
        );
      } catch (e) {
        LogService.writeLog(message: "[SYNC_LOGIN_ERR] $e");
      }
    }
  }

  // static Future<String> processPendingQueue(
  //     {required bool isInternetAvailable}) async {
  //   if (!isInternetAvailable) return "No internet connection";

  //   final scope = await _getLastOfflineUserScope();
  //   if (scope == null) return "No user session found";

  //   final username = scope['username']!;
  //   final projectName = scope['projectName']!;

  //   final rows = await _database.query(
  //     OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //     where: '''
  //     ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})
  //     AND ${OfflineDBConstants.COL_USERNAME} = ?
  //     AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
  //   ''',
  //     whereArgs: [username, projectName],
  //     orderBy: OfflineDBConstants.COL_CREATED_AT,
  //   );

  //   if (rows.isEmpty) return "Queue is empty";

  //   int successCount = 0;
  //   int failCount = 0;

  //   final ServerConnections serverConnections = ServerConnections();
  //   final String url =
  //       Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);

  //   for (final row in rows) {
  //     final id = row[OfflineDBConstants.COL_ID] as int;
  //     final bodyStr = row[OfflineDBConstants.COL_REQUEST_JSON] as String;

  //     try {
  //       final payload = jsonDecode(bodyStr);

  //       final String res = await serverConnections.postToServer(
  //         url: url,
  //         body: jsonEncode(payload),
  //         isBearer: true,
  //       );

  //       log(res.toString(), name: "processPendingQueue Response");

  //       bool isSuccess = false;

  //       // 3. New Parsing Logic
  //       if (res.isNotEmpty) {
  //         try {
  //           final decoded = jsonDecode(res);
  //           if (decoded is Map<String, dynamic> && decoded['success'] == true) {
  //             isSuccess = true;
  //           } else {
  //             LogService.writeLog(
  //                 message:
  //                     "[QUEUE_FAIL] ID: $id - Server Msg: ${decoded['message']}");
  //           }
  //         } catch (e) {
  //           LogService.writeLog(message: "[QUEUE_PARSE_ERR] ID: $id - $e");
  //         }
  //       }

  //       // 4. Update DB Status
  //       await _database.update(
  //         OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //         {
  //           OfflineDBConstants.COL_STATUS: isSuccess
  //               ? OfflineDBConstants.STATUS_SUCCESS
  //               : OfflineDBConstants.STATUS_ERROR,
  //         },
  //         where: '${OfflineDBConstants.COL_ID} = ?',
  //         whereArgs: [id],
  //       );

  //       if (isSuccess)
  //         successCount++;
  //       else
  //         failCount++;
  //     } catch (e) {
  //       failCount++;
  //       LogService.writeLog(message: "[QUEUE_PROCESS_ERROR] ID: $id - $e");
  //     }
  //   }

  //   return "Processed: $successCount success, $failCount failed";
  // }

  // static Future<void> _syncPendingBeforeLogin({
  //   required String username,
  //   required String projectName,
  //   required bool isInternetAvailable,
  // }) async {
  //   if (!isInternetAvailable) return;

  //   final rows = await _database.query(
  //     OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //     where: '''
  //     ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})
  //     AND ${OfflineDBConstants.COL_USERNAME} = ?
  //     AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
  //   ''',
  //     whereArgs: [username, projectName],
  //     orderBy: OfflineDBConstants.COL_CREATED_AT,
  //   );

  //   if (rows.isEmpty) return;

  //   // 1. Setup Connection
  //   final ServerConnections serverConnections = ServerConnections();
  //   final String url =
  //       Const.getFullARMUrl(ExecuteApi.API_ARM_EXECUTE_PUBLISHED);

  //   for (final row in rows) {
  //     final id = row[OfflineDBConstants.COL_ID] as int;
  //     try {
  //       final payload =
  //           jsonDecode(row[OfflineDBConstants.COL_REQUEST_JSON] as String);

  //       final res = await serverConnections.postToServer(
  //         url: url,
  //         body: jsonEncode(payload),
  //         isBearer: true,
  //       );

  //       bool isSuccess = false;

  //       // 2. Check Success
  //       if (res != null && res.isNotEmpty) {
  //         try {
  //           final decoded = jsonDecode(res);
  //           if (decoded is Map<String, dynamic> && decoded['success'] == true) {
  //             isSuccess = true;
  //           }
  //         } catch (_) {}
  //       }

  //       await _database.update(
  //         OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //         {
  //           OfflineDBConstants.COL_STATUS: isSuccess
  //               ? OfflineDBConstants.STATUS_SUCCESS
  //               : OfflineDBConstants.STATUS_ERROR,
  //         },
  //         where: '${OfflineDBConstants.COL_ID} = ?',
  //         whereArgs: [id],
  //       );
  //     } catch (e) {
  //       // Log error but continue
  //       LogService.writeLog(message: "[SYNC_LOGIN_ERR] $e");
  //     }
  //   }
  // }

  // =================================================
  // SYNC ALL DATA (BUTTON)
  // =================================================

  static Future<void> syncAllData({
    required bool isInternetAvailable,
  }) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await _syncAllDataInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
      isInternetAvailable: isInternetAvailable,
    );
  }

  static Future<void> _syncAllDataInternal({
    required String username,
    required String projectName,
    required bool isInternetAvailable,
  }) async {
    if (!isInternetAvailable) return;

    await _syncPendingBeforeLogin(
      username: username,
      projectName: projectName,
      isInternetAvailable: true,
    );

    await _database.delete(
      OfflineDBConstants.TABLE_OFFLINE_PAGES,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );

    await _database.delete(
      OfflineDBConstants.TABLE_DATASOURCES,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );

    await _database.delete(
      OfflineDBConstants.TABLE_DATASOURCE_DATA,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );

    final pages = await fetchAndStoreOfflinePages();

    if (pages.isNotEmpty) {
      // datasources will be fetched lazily per form
    }
  }

  // =================================================
  // CLEAR METHODS
  // =================================================
  static Future<void> clearPendingRequests({
    required String username,
    required String projectName,
  }) async {
    await _database.delete(
      OfflineDBConstants.TABLE_PENDING_REQUESTS,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );
  }

  static Future<void> clearOfflineCache({
    required String username,
    required String projectName,
  }) async {
    await _database.delete(
      OfflineDBConstants.TABLE_OFFLINE_PAGES,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );

    await _database.delete(
      OfflineDBConstants.TABLE_DATASOURCES,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );

    await _database.delete(
      OfflineDBConstants.TABLE_DATASOURCE_DATA,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );
  }

  static Future<void> clearAllData({
    required String username,
    required String projectName,
  }) async {
    await clearOfflineCache(username: username, projectName: projectName);
    await clearPendingRequests(username: username, projectName: projectName);
  }

  static Future<int> getPendingCount() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return 0;

    return _getPendingCountInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
    );
  }

  static Future<int> _getPendingCountInternal({
    required String username,
    required String projectName,
  }) async {
    final result = await _database.rawQuery(
      '''
    SELECT COUNT(*) as cnt 
    FROM ${OfflineDBConstants.TABLE_PENDING_REQUESTS} 
    WHERE ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})
    AND ${OfflineDBConstants.COL_USERNAME} = ?
    AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
    ''',
      [username, projectName],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> refetchAll({
    required bool isOnline,
  }) async {
    await syncAllData(
      isInternetAvailable: isOnline,
    );
  }

  static Future<void> refetchOnlyForms({
    required String username,
    required String projectName,
  }) async {
    await _database.delete(
      OfflineDBConstants.TABLE_OFFLINE_PAGES,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );

    await fetchAndStoreOfflinePages();
  }

  static Future<void> refetchOnlyDatasources({
    required String username,
    required String projectName,
  }) async {
    await _database.delete(
      OfflineDBConstants.TABLE_DATASOURCE_DATA,
      where: 'username = ? AND project_name = ?',
      whereArgs: [username, projectName],
    );
  }

  // static Future<void> _deleteTable(String table) async {
  //   await _database.delete(table);
  // }

  static Future<void> clearOfflinePages() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await _database.delete(
      OfflineDBConstants.TABLE_OFFLINE_PAGES,
      where: 'username = ? AND project_name = ?',
      whereArgs: [scope['username'], scope['projectName']],
    );
  }

  static Future<void> clearDatasources() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await _database.delete(
      OfflineDBConstants.TABLE_DATASOURCES,
      where: 'username = ? AND project_name = ?',
      whereArgs: [scope['username'], scope['projectName']],
    );

    await _database.delete(
      OfflineDBConstants.TABLE_DATASOURCE_DATA,
      where: 'username = ? AND project_name = ?',
      whereArgs: [scope['username'], scope['projectName']],
    );
  }

  static Future<void> clearPendingQueue() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await clearPendingRequests(
      username: scope['username']!,
      projectName: scope['projectName']!,
    );
  }

  static Future<void> clearAllExceptUser() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await clearOfflineCache(
      username: scope['username']!,
      projectName: scope['projectName']!,
    );

    await clearPendingRequests(
      username: scope['username']!,
      projectName: scope['projectName']!,
    );
  }

  static Future<void> syncAll({
    required bool isInternetAvailable,
  }) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await syncAllData(
      isInternetAvailable: isInternetAvailable,
    );
  }

  static Future<void> refetchAllData({
    required bool isOnline,
  }) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await refetchAll(
      isOnline: isOnline,
    );
  }

  static Future<void> clearOnlyForms() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await _database.delete(
      OfflineDBConstants.TABLE_OFFLINE_PAGES,
      where: 'username = ? AND project_name = ?',
      whereArgs: [scope['username'], scope['projectName']],
    );
  }

  static Future<void> clearOnlyDatasources() async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null) return;

    await _database.delete(
      OfflineDBConstants.TABLE_DATASOURCE_DATA,
      where: 'username = ? AND project_name = ?',
      whereArgs: [scope['username'], scope['projectName']],
    );
  }

  static Future<bool> hasOfflineUser({
    required String projectName,
    required String username,
  }) async {
    final res = await _database.query(
      OfflineDBConstants.TABLE_OFFLINE_USER,
      where:
          '${OfflineDBConstants.COL_PROJECT_NAME} = ? AND ${OfflineDBConstants.COL_USERNAME} = ?',
      whereArgs: [projectName, username],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  static Future<bool> validateOfflineLogin({
    required String projectName,
    required String username,
    required String passwordHash,
  }) async {
    final res = await _database.query(
      OfflineDBConstants.TABLE_OFFLINE_USER,
      where: '''
      ${OfflineDBConstants.COL_PROJECT_NAME} = ? AND
      ${OfflineDBConstants.COL_USERNAME} = ? AND
      ${OfflineDBConstants.COL_PASSWORD_HASH} = ?
    ''',
      whereArgs: [projectName, username, passwordHash],
      limit: 1,
    );

    return res.isNotEmpty;
  }

  static Future<void> saveUser({
    required String projectName,
    required String username,
    required String passwordHash,
    required Map<String, dynamic> loginResult,
  }) async {
    const tag = "[OFFLINE_USER_SAVE_002]";

    try {
      final result = loginResult['result'] ?? loginResult;

      final data = {
        OfflineDBConstants.COL_PROJECT_NAME: projectName,
        OfflineDBConstants.COL_USERNAME: username,
        OfflineDBConstants.COL_PASSWORD_HASH: passwordHash,
        OfflineDBConstants.COL_DISPLAY_NAME:
            result['nickname']?.toString() ?? username,
        OfflineDBConstants.COL_SESSION_ID:
            result['ARMSessionId']?.toString() ?? '',
        OfflineDBConstants.COL_RAW_JSON: jsonEncode(result),
        OfflineDBConstants.COL_LAST_LOGIN_AT: DateTime.now().toIso8601String(),
      };

      await _database.insert(
        OfflineDBConstants.TABLE_OFFLINE_USER,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      LogService.writeLog(
          message: "$tag[SUCCESS] User saved for offline login");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
    }
  }

  static Future<Map<String, String>?> _getLastOfflineUserScope() async {
    final res = await _database.query(
      OfflineDBConstants.TABLE_OFFLINE_USER,
      orderBy: OfflineDBConstants.COL_LAST_LOGIN_AT + ' DESC',
      limit: 1,
    );

    if (res.isEmpty) return null;

    return {
      'username': res.first[OfflineDBConstants.COL_USERNAME] as String,
      'projectName': res.first[OfflineDBConstants.COL_PROJECT_NAME] as String,
    };
  }

  // static Future<String> processPendingQueue(
  //     {required bool isInternetAvailable}) async {
  //   if (!isInternetAvailable) return "No internet connection";

  //   final scope = await _getLastOfflineUserScope();
  //   if (scope == null) return "No user session found";

  //   final username = scope['username']!;
  //   final projectName = scope['projectName']!;

  //   final rows = await _database.query(
  //     OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //     where: '''
  //     ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})
  //     AND ${OfflineDBConstants.COL_USERNAME} = ?
  //     AND ${OfflineDBConstants.COL_PROJECT_NAME} = ?
  //   ''',
  //     whereArgs: [username, projectName],
  //     orderBy: OfflineDBConstants.COL_CREATED_AT,
  //   );

  //   if (rows.isEmpty) return "Queue is empty";

  //   int successCount = 0;
  //   int failCount = 0;

  //   for (final row in rows) {
  //     final id = row[OfflineDBConstants.COL_ID] as int;
  //     final bodyStr = row[OfflineDBConstants.COL_REQUEST_JSON] as String;

  //     try {
  //       final payload = jsonDecode(bodyStr);

  //       final res = await OfflineDatasources.post(
  //         endpoint: OfflineDatasources.API_SUBMIT_OFFLINE_FORM,
  //         body: payload,
  //       );
  //       log(res.toString(), name: "processPendingQueue");
  //       bool isSuccess = false;
  //       if (res != null && res.isNotEmpty) {
  //         isSuccess = true;
  //       }

  //       // Update DB Status
  //       await _database.update(
  //         OfflineDBConstants.TABLE_PENDING_REQUESTS,
  //         {
  //           OfflineDBConstants.COL_STATUS: isSuccess
  //               ? OfflineDBConstants.STATUS_SUCCESS
  //               : OfflineDBConstants.STATUS_ERROR,
  //         },
  //         where: '${OfflineDBConstants.COL_ID} = ?',
  //         whereArgs: [id],
  //       );

  //       if (isSuccess)
  //         successCount++;
  //       else
  //         failCount++;
  //     } catch (e) {
  //       failCount++;
  //       LogService.writeLog(message: "[QUEUE_PROCESS_ERROR] ID: $id - $e");
  //     }
  //   }

  //   return "Processed: $successCount success, $failCount failed";
  // }

  static Future<void> refreshAllDatasourcesFromDownloadedPages() async {
    final pages = await getOfflinePages();

    if (pages.isEmpty) return;

    for (final p in pages) {
      final transId = p['transid'];
      if (transId != null) {
        await fetchAndStoreAllDatasources(transId: transId);
      }
    }
  }
}
