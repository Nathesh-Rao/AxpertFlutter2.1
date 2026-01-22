import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/data_source_model.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_page_model.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'offline_datasources.dart';
import 'offline_db_constants.dart';

enum SubmitStatus { success, savedOffline, apiFailure }

class OfflineDbModule {
  OfflineDbModule._();

  static Database? _db;

  // INIT
  static Future<void> init() async {
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
    await _syncPendingBeforeLogin(
      username: username,
      projectName: projectName,
      isInternetAvailable: isInternetAvailable,
    );

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
  static Future<SubmitStatus> submitFormSmart({
    required Map<String, dynamic> submitBody,
    required bool isInternetAvailable,
  }) async {
    final scope = await _getLastOfflineUserScope();
    if (scope == null)
      return SubmitStatus.apiFailure; // Or handles error differently

    return _submitFormSmartInternal(
      username: scope['username']!,
      projectName: scope['projectName']!,
      submitBody: submitBody,
      isInternetAvailable: isInternetAvailable,
    );
  }

  static Future<SubmitStatus> _submitFormSmartInternal({
    required String username,
    required String projectName,
    required Map<String, dynamic> submitBody,
    required bool isInternetAvailable,
  }) async {
    if (isInternetAvailable) {
      final String? res = await OfflineDatasources.post(
        endpoint: OfflineDatasources.API_SUBMIT_OFFLINE_FORM,
        body: submitBody,
      );

      log(submitBody.toString(), name: "submitBody OFFLINE");
      log(res.toString(), name: "submit res OFFLINE");
      if (res != null && res.isNotEmpty) {
        try {
          final decoded = jsonDecode(res);

          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('result')) {
            final resultList = decoded['result'] as List<dynamic>;

            if (resultList.isNotEmpty) {
              final firstResult = resultList[0] as Map<String, dynamic>;

              if (firstResult.containsKey('message')) {
                final messageList = firstResult['message'] as List<dynamic>;

                if (messageList.isNotEmpty) {
                  final msgObj = messageList[0] as Map<String, dynamic>;

                  if (msgObj.containsKey('msg') ||
                      msgObj.containsKey('recordid')) {
                    return SubmitStatus.success;
                  }
                }
              }
            }
          }
        } catch (e) {
          LogService.writeLog(
              message:
                  "[API_PARSE_ERROR] Could not parse success response: $e");
        }

        return SubmitStatus.apiFailure;
      }

      return SubmitStatus.apiFailure;
    }

    await _database.insert(
      OfflineDBConstants.TABLE_PENDING_REQUESTS,
      {
        OfflineDBConstants.COL_USERNAME: username,
        OfflineDBConstants.COL_PROJECT_NAME: projectName,
        OfflineDBConstants.COL_REQUEST_JSON: jsonEncode(submitBody),
        OfflineDBConstants.COL_STATUS: OfflineDBConstants.STATUS_PENDING,
        OfflineDBConstants.COL_CREATED_AT: DateTime.now().toIso8601String(),
      },
    );

    return SubmitStatus.savedOffline;
  }

  // =================================================
  // PENDING SYNC (STATUS BASED)
  // =================================================
  static Future<void> _syncPendingBeforeLogin({
    required String username,
    required String projectName,
    required bool isInternetAvailable,
  }) async {
    if (!isInternetAvailable) return;

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

    for (final row in rows) {
      final id = row[OfflineDBConstants.COL_ID] as int;
      final payload =
          jsonDecode(row[OfflineDBConstants.COL_REQUEST_JSON] as String);

      final res = await OfflineDatasources.post(
        endpoint: OfflineDatasources.API_SUBMIT_OFFLINE_FORM,
        body: payload,
      );

      await _database.update(
        OfflineDBConstants.TABLE_PENDING_REQUESTS,
        {
          OfflineDBConstants.COL_STATUS: res != null
              ? OfflineDBConstants.STATUS_SUCCESS
              : OfflineDBConstants.STATUS_ERROR,
        },
        where: '${OfflineDBConstants.COL_ID} = ?',
        whereArgs: [id],
      );
    }
  }

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

  static Future<String> processPendingQueue(
      {required bool isInternetAvailable}) async {
    if (!isInternetAvailable) return "No internet connection";

    final scope = await _getLastOfflineUserScope();
    if (scope == null) return "No user session found";

    final username = scope['username']!;
    final projectName = scope['projectName']!;

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

    if (rows.isEmpty) return "Queue is empty";

    int successCount = 0;
    int failCount = 0;

    for (final row in rows) {
      final id = row[OfflineDBConstants.COL_ID] as int;
      final bodyStr = row[OfflineDBConstants.COL_REQUEST_JSON] as String;

      try {
        final payload = jsonDecode(bodyStr);

        final res = await OfflineDatasources.post(
          endpoint: OfflineDatasources.API_SUBMIT_OFFLINE_FORM,
          body: payload,
        );
        log(res.toString(), name: "processPendingQueue");
        bool isSuccess = false;
        if (res != null && res.isNotEmpty) {
          isSuccess = true;
        }

        // Update DB Status
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

        if (isSuccess)
          successCount++;
        else
          failCount++;
      } catch (e) {
        failCount++;
        LogService.writeLog(message: "[QUEUE_PROCESS_ERROR] ID: $id - $e");
      }
    }

    return "Processed: $successCount success, $failCount failed";
  }

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
