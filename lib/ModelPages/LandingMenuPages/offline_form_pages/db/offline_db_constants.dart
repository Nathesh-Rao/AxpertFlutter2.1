class OfflineDBConstants {
  OfflineDBConstants._();

  // COMMON
  static const String OFFLINE_PAGES_URL =
      "https://raw.githubusercontent.com/amrith4agile/offline_sample_pages/refs/heads/main/offline_pages.json";
  static const String CREATE_QUERY = 'CREATE TABLE IF NOT EXISTS ';

  static const int STATUS_PENDING = 0;
  static const int STATUS_SUCCESS = 1;
  static const int STATUS_ERROR = 2;

  // TABLE NAMES
  static const String TABLE_OFFLINE_PAGES = 'offline_pages';
  static const String TABLE_DATASOURCES = 'offline_datasources';
  static const String TABLE_DATASOURCE_DATA = 'offline_datasource_data';
  static const String TABLE_PENDING_REQUESTS = 'offline_pending_requests';

  // COMMON COLUMNS
  static const String COL_ID = 'id';
  static const String COL_CREATED_AT = 'created_at';

  // OFFLINE PAGES
  static const String COL_TRANS_ID = 'trans_id';
  static const String COL_PAGE_JSON = 'page_json';
  static const String COL_FETCHED_AT = 'fetched_at';

  // DATASOURCES (SINGLE ROW)
  static const String COL_DATASOURCE_NAMES = 'datasource_names';

  // DATASOURCE DATA
  static const String COL_DATASOURCE_NAME = 'datasource_name';
  static const String COL_RESPONSE_JSON = 'response_json';

  // PENDING REQUESTS
  static const String COL_REQUEST_JSON = 'request_json';
  static const String COL_STATUS = 'status';

  // CREATE TABLE QUERIES
  static final String CREATE_OFFLINE_PAGES_TABLE = CREATE_QUERY +
      TABLE_OFFLINE_PAGES +
      '''
      (
        $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_TRANS_ID TEXT,
        $COL_PAGE_JSON TEXT,
        $COL_FETCHED_AT TEXT
      );
    ''';

  static final String CREATE_DATASOURCES_TABLE = CREATE_QUERY +
      TABLE_DATASOURCES +
      '''
      (
        $COL_ID INTEGER PRIMARY KEY,
        $COL_DATASOURCE_NAMES TEXT
      );
    ''';

  static final String CREATE_DATASOURCE_DATA_TABLE = CREATE_QUERY +
      TABLE_DATASOURCE_DATA +
      '''
      (
        $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_DATASOURCE_NAME TEXT UNIQUE,
        $COL_RESPONSE_JSON TEXT
      );
    ''';

  static final String CREATE_PENDING_REQUESTS_TABLE = CREATE_QUERY +
      TABLE_PENDING_REQUESTS +
      '''
      (
        $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_REQUEST_JSON TEXT,
        $COL_STATUS INTEGER,
        $COL_CREATED_AT TEXT
      );
    ''';

// ================= USER TABLE =================
  static const String TABLE_OFFLINE_USER = 'offline_user';

// COLUMNS
  static const String COL_USER_ID =
      'user_id'; // from server if available, else username or session
  static const String COL_USERNAME = 'username';
  static const String COL_DISPLAY_NAME = 'display_name';
  static const String COL_SESSION_ID = 'session_id';
  static const String COL_RAW_JSON = 'raw_json'; // full result JSON
  static const String COL_LAST_LOGIN_AT = 'last_login_at';
  static const String COL_PROJECT_NAME = 'project_name';

// // CREATE TABLE
//   static final String CREATE_OFFLINE_USER_TABLE = CREATE_QUERY +
//       TABLE_OFFLINE_USER +
//       '''
//     (
//       $COL_ID INTEGER PRIMARY KEY,      -- always 1 row
//       $COL_USER_ID TEXT,
//       $COL_USERNAME TEXT,
//       $COL_DISPLAY_NAME TEXT,
//       $COL_SESSION_ID TEXT,
//       $COL_RAW_JSON TEXT,
//       $COL_LAST_LOGIN_AT TEXT
//     );
//   ''';

  static final String CREATE_OFFLINE_USER_TABLE = CREATE_QUERY +
      TABLE_OFFLINE_USER +
      '''
    (
      $COL_ID INTEGER PRIMARY KEY,     
      $COL_USER_ID TEXT,
      $COL_USERNAME TEXT,
      $COL_DISPLAY_NAME TEXT,
      $COL_SESSION_ID TEXT,
      $COL_PROJECT_NAME TEXT,
      $COL_RAW_JSON TEXT,
      $COL_LAST_LOGIN_AT TEXT
    );
  ''';
}
