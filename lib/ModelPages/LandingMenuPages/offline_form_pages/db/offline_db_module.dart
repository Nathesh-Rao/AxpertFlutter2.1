import 'dart:convert';

import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_page_model.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'offline_datasources.dart';
import 'offline_db_constants.dart';

class OfflineDbModule {
  OfflineDbModule._();

  static Database? _db;

  // INIT
  static Future<void> init() async {
    final dbPath = join(await getDatabasesPath(), 'offline_forms.db');

    _db = await openDatabase(
      dbPath,
      version: 2, // 🔥 bumped
      onCreate: (db, _) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        const tag = "[OFFLINE_DB_UPGRADE_002]";
        LogService.writeLog(
            message: "$tag[START] Upgrading DB $oldVersion → $newVersion");

        // ⚠️ DEV PHASE: FULL RESET
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

  // LOGIN FLOW
  static Future<void> handlePostLogin({
    required bool isInternetAvailable,
  }) async {
    await _syncPendingBeforeLogin(isInternetAvailable: isInternetAvailable);

    final pages = await fetchAndStoreOfflinePages();
    if (pages.isEmpty) return;

    await fetchAndStoreAllDatasources();
  }

  // static Future<List<Map<String, dynamic>>> fetchAndStoreOfflinePages({
  //   required bool isInternetAvailable,
  // }) async {
  //   const String tag = "[OFFLINE_PAGES_FETCH_001]";

  //   // 🛑 If no internet, do NOT try anything
  //   if (!isInternetAvailable) {
  //     LogService.writeLog(
  //       message:
  //           "$tag[SKIPPED] No internet. Skipping fetch. Keeping existing data.",
  //     );

  //     return [];
  //   }

  //   try {
  //     LogService.writeLog(
  //       message: "$tag[START] Fetching offline pages from JSON file",
  //     );

  //     final res = await http.get(
  //       Uri.parse(OfflineDBConstants.OFFLINE_PAGES_URL),
  //     );

  //     if (res.statusCode != 200) {
  //       LogService.writeLog(
  //         message: "$tag[FAILED] HTTP ${res.statusCode} while fetching JSON",
  //       );
  //       return [];
  //     }

  //     final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  //     final pages = decoded.map((e) => e as Map<String, dynamic>).toList();

  //     if (pages.isEmpty) {
  //       LogService.writeLog(message: "$tag[INFO] JSON has 0 pages");
  //       return [];
  //     }

  //     await _database.delete(OfflineDBConstants.TABLE_OFFLINE_PAGES);

  //     final batch = _database.batch();

  //     for (final page in pages) {
  //       batch.insert(
  //         OfflineDBConstants.TABLE_OFFLINE_PAGES,
  //         {
  //           OfflineDBConstants.COL_TRANS_ID: page['transid'],
  //           OfflineDBConstants.COL_PAGE_JSON: jsonEncode(page),
  //           OfflineDBConstants.COL_FETCHED_AT: DateTime.now().toIso8601String(),
  //         },
  //         conflictAlgorithm: ConflictAlgorithm.replace,
  //       );
  //     }

  //     await batch.commit(noResult: true);

  //     final dsString = _extractDatasourceString(pages);
  //     await _saveDatasourceString(dsString);

  //     LogService.writeLog(
  //       message: "$tag[SUCCESS] Replaced pages with ${pages.length} records",
  //     );

  //     return pages;
  //   } catch (e, st) {
  //     LogService.writeLog(
  //       message: "$tag[FAILED] Exception while fetching pages => $e",
  //     );
  //     LogService.writeLog(
  //       message: "$tag[STACK] $st",
  //     );

  //     return [];
  //   }
  // }

  static Future<List<Map<String, dynamic>>> fetchAndStoreOfflinePages() async {
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

      // ✅ IMPORTANT: Clear old pages first
      await _database.delete(OfflineDBConstants.TABLE_OFFLINE_PAGES);

      final batch = _database.batch();

      for (final page in pages) {
        batch.insert(
          OfflineDBConstants.TABLE_OFFLINE_PAGES,
          {
            OfflineDBConstants.COL_TRANS_ID: page['transid'],
            OfflineDBConstants.COL_PAGE_JSON: jsonEncode(page),
            OfflineDBConstants.COL_FETCHED_AT: DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);

      final dsString = _extractDatasourceString(pages);
      await _saveDatasourceString(dsString);

      LogService.writeLog(
        message: "$tag[SUCCESS] Replaced pages with ${pages.length} records",
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
    final res = await _database.rawQuery(
      "SELECT COUNT(*) as cnt FROM ${OfflineDBConstants.TABLE_OFFLINE_PAGES}",
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getOfflinePages() async {
    final result =
        await _database.query(OfflineDBConstants.TABLE_OFFLINE_PAGES);

    return result
        .map((e) => jsonDecode(e[OfflineDBConstants.COL_PAGE_JSON] as String)
            as Map<String, dynamic>)
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

  static Future<void> _saveDatasourceString(String value) async {
    await _database.insert(
      OfflineDBConstants.TABLE_DATASOURCES,
      {
        OfflineDBConstants.COL_ID: 1,
        OfflineDBConstants.COL_DATASOURCE_NAMES: value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<String>> _getDatasourceList() async {
    final result = await _database.query(
      OfflineDBConstants.TABLE_DATASOURCES,
      where: '${OfflineDBConstants.COL_ID} = ?',
      whereArgs: [1],
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

  // DATASOURCE DATA (CACHE FIRST)
  static Future<void> fetchAndStoreAllDatasources() async {
    final datasources = await _getDatasourceList();

    for (final ds in datasources) {
      final exists = await _database.query(
        OfflineDBConstants.TABLE_DATASOURCE_DATA,
        where: '${OfflineDBConstants.COL_DATASOURCE_NAME} = ?',
        whereArgs: [ds],
        limit: 1,
      );

      if (exists.isNotEmpty) continue;

      final res = await OfflineDatasources.get(
        endpoint: OfflineDatasources.API_FETCH_DATASOURCE(ds),
      );

      if (res == null || res.isEmpty) continue;

      await _database.insert(
        OfflineDBConstants.TABLE_DATASOURCE_DATA,
        {
          OfflineDBConstants.COL_DATASOURCE_NAME: ds,
          OfflineDBConstants.COL_RESPONSE_JSON: res,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<dynamic>> getDatasourceOptions(String datasource) async {
    final result = await _database.query(
      OfflineDBConstants.TABLE_DATASOURCE_DATA,
      where: '${OfflineDBConstants.COL_DATASOURCE_NAME} = ?',
      whereArgs: [datasource],
      limit: 1,
    );

    if (result.isEmpty) return [];

    final decoded = jsonDecode(
        result.first[OfflineDBConstants.COL_RESPONSE_JSON] as String);

    return decoded['data'] ?? [];
  }

  // MAP OPTIONS INTO FIELD MODELS
  static Future<List<OfflineFormPageModel>> mapDatasourceOptionsIntoPages(
      List<OfflineFormPageModel> pages) async {
    for (final page in pages) {
      for (final field in page.fields) {
        if (field.datasource == null || field.datasource!.isEmpty) continue;

        await fetchAndStoreAllDatasources();
        final options = await getDatasourceOptions(field.datasource!);

        field.options = options.map((e) => e.toString()).toList();
      }
    }
    return pages;
  }

  // =================================================
  // SMART SUBMIT
  // =================================================

  static Future<bool> submitFormSmart({
    required Map<String, dynamic> submitBody,
    required bool isInternetAvailable,
  }) async {
    if (isInternetAvailable) {
      final res = await OfflineDatasources.post(
        endpoint: OfflineDatasources.API_SUBMIT_OFFLINE_FORM,
        body: submitBody,
      );

      if (res != null && res.isNotEmpty) return true;
    }

    await _database.insert(
      OfflineDBConstants.TABLE_PENDING_REQUESTS,
      {
        OfflineDBConstants.COL_REQUEST_JSON: jsonEncode(submitBody),
        OfflineDBConstants.COL_STATUS: OfflineDBConstants.STATUS_PENDING,
        OfflineDBConstants.COL_CREATED_AT: DateTime.now().toIso8601String(),
      },
    );

    return false;
  }

  // =================================================
  // PENDING SYNC (STATUS BASED)
  // =================================================

  static Future<void> _syncPendingBeforeLogin({
    required bool isInternetAvailable,
  }) async {
    if (!isInternetAvailable) return;

    final rows = await _database.query(
      OfflineDBConstants.TABLE_PENDING_REQUESTS,
      where:
          '${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})',
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
    if (!isInternetAvailable) return;

    await _syncPendingBeforeLogin(isInternetAvailable: true);

    await _database.delete(OfflineDBConstants.TABLE_OFFLINE_PAGES);
    await _database.delete(OfflineDBConstants.TABLE_DATASOURCES);
    await _database.delete(OfflineDBConstants.TABLE_DATASOURCE_DATA);

    final pages = await fetchAndStoreOfflinePages();
    if (pages.isNotEmpty) {
      await fetchAndStoreAllDatasources();
    }
  }

  // =================================================
  // CLEAR METHODS
  // =================================================

  static Future<void> clearPendingRequests() async {
    await _database.delete(OfflineDBConstants.TABLE_PENDING_REQUESTS);
  }

  static Future<void> clearOfflineCache() async {
    await _database.delete(OfflineDBConstants.TABLE_OFFLINE_PAGES);
    await _database.delete(OfflineDBConstants.TABLE_DATASOURCES);
    await _database.delete(OfflineDBConstants.TABLE_DATASOURCE_DATA);
  }

  static Future<void> clearAllData() async {
    await clearOfflineCache();
    await clearPendingRequests();
  }

  static Future<int> getPendingCount() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${OfflineDBConstants.TABLE_PENDING_REQUESTS} WHERE ${OfflineDBConstants.COL_STATUS} IN (${OfflineDBConstants.STATUS_PENDING}, ${OfflineDBConstants.STATUS_ERROR})',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> refetchAll({required bool isOnline}) async {
    await syncAllData(isInternetAvailable: isOnline);
  }

  static Future<void> refetchOnlyForms() async {
    await _database.delete(OfflineDBConstants.TABLE_OFFLINE_PAGES);
    await fetchAndStoreOfflinePages();
  }

  static Future<void> refetchOnlyDatasources() async {
    await _database.delete(OfflineDBConstants.TABLE_DATASOURCE_DATA);
    await fetchAndStoreAllDatasources();
  }

  static Future<void> deleteTable(String table) async {
    await _database.delete(table);
  }

  static Future<void> clearOfflinePages() async {
    await _database.delete(OfflineDBConstants.TABLE_OFFLINE_PAGES);
  }

  static Future<void> clearDatasources() async {
    await _database.delete(OfflineDBConstants.TABLE_DATASOURCES);
    await _database.delete(OfflineDBConstants.TABLE_DATASOURCE_DATA);
  }

  static Future<void> clearPendingQueue() async {
    await clearPendingRequests();
  }

  static Future<void> clearAllExceptUser() async {
    await clearOfflineCache();
    await clearPendingRequests();
  }

  static Future<void> syncAll({
    required bool isInternetAvailable,
  }) async {
    await syncAllData(isInternetAvailable: isInternetAvailable);
  }

  static Future<void> refetchAllData({
    required bool isOnline,
  }) async {
    await refetchAll(isOnline: isOnline);
  }

  static Future<void> clearOnlyForms() async {
    await clearOfflinePages();
  }

  static Future<void> clearOnlyDatasources() async {
    await clearDatasources();
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
}
