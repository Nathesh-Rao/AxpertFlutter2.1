class OfflineDBConstants {
  OfflineDBConstants._();

  // COMMON
  static const String OFFLINE_PAGES_URL =
      "https://raw.githubusercontent.com/amrith4agile/offline_sample_pages/refs/heads/main/offline_pages.json";
  static const String CREATE_QUERY = 'CREATE TABLE IF NOT EXISTS ';

  static const int STATUS_PENDING = 0;
  static const int STATUS_SUCCESS = 1;
  static const int STATUS_ERROR = 2;

  // ================= TABLE NAMES =================

  static const String TABLE_OFFLINE_PAGES = 'offline_pages';
  static const String TABLE_DATASOURCES = 'offline_datasources';
  static const String TABLE_DATASOURCE_DATA = 'offline_datasource_data';
  static const String TABLE_PENDING_REQUESTS = 'offline_pending_requests';
  static const String TABLE_OFFLINE_USER = 'offline_user';

  // ================= COMMON COLUMNS =================

  static const String COL_ID = 'id';
  static const String COL_CREATED_AT = 'created_at';

  static const String COL_USERNAME = 'username';
  static const String COL_PROJECT_NAME = 'project_name';

  static const String COL_TRANS_ID = 'trans_id';

  // ================= OFFLINE PAGES =================

  static const String COL_PAGE_JSON = 'page_json';
  static const String COL_FETCHED_AT = 'fetched_at';

  // ================= DATASOURCES =================

  static const String COL_DATASOURCE_NAMES = 'datasource_names';

  // ================= DATASOURCE DATA =================

  static const String COL_DATASOURCE_NAME = 'datasource_name';
  static const String COL_RESPONSE_JSON = 'response_json';

  // ================= PENDING REQUESTS =================

  static const String COL_REQUEST_JSON = 'request_json';
  static const String COL_STATUS = 'status';

  // ================= USER TABLE =================

  static const String COL_DISPLAY_NAME = 'display_name';
  static const String COL_SESSION_ID = 'session_id';
  static const String COL_RAW_JSON = 'raw_json';
  static const String COL_LAST_LOGIN_AT = 'last_login_at';
  static const String COL_PASSWORD_HASH = 'password_hash';

  // ================= CREATE TABLE QUERIES =================

  // -------- OFFLINE PAGES --------
  static final String CREATE_OFFLINE_PAGES_TABLE = CREATE_QUERY +
      TABLE_OFFLINE_PAGES +
      '''
      (
        $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_USERNAME TEXT,
        $COL_PROJECT_NAME TEXT,
        $COL_TRANS_ID TEXT,
        $COL_PAGE_JSON TEXT,
        $COL_FETCHED_AT TEXT
      );
    ''';

  // -------- DATASOURCE NAMES (PER USER+PROJECT) --------
  static final String CREATE_DATASOURCES_TABLE = CREATE_QUERY +
      TABLE_DATASOURCES +
      '''
      (
        $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_USERNAME TEXT,
        $COL_PROJECT_NAME TEXT,
        $COL_DATASOURCE_NAMES TEXT
      );
    ''';

  // -------- DATASOURCE DATA (PER USER+PROJECT+FORM) --------
  static final String CREATE_DATASOURCE_DATA_TABLE = CREATE_QUERY +
      TABLE_DATASOURCE_DATA +
      '''
      (
        $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_USERNAME TEXT,
        $COL_PROJECT_NAME TEXT,
        $COL_TRANS_ID TEXT,
        $COL_DATASOURCE_NAME TEXT,
        $COL_RESPONSE_JSON TEXT
      );
    ''';

  // -------- PENDING REQUESTS --------
  static final String CREATE_PENDING_REQUESTS_TABLE = CREATE_QUERY +
      TABLE_PENDING_REQUESTS +
      '''
      (
        $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_USERNAME TEXT,
        $COL_PROJECT_NAME TEXT,
        $COL_REQUEST_JSON TEXT,
        $COL_STATUS INTEGER,
        $COL_CREATED_AT TEXT
      );
    ''';

  // -------- OFFLINE USER --------
  static final String CREATE_OFFLINE_USER_TABLE = CREATE_QUERY +
      TABLE_OFFLINE_USER +
      '''
    (
      $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      $COL_PROJECT_NAME TEXT,
      $COL_USERNAME TEXT,
      $COL_PASSWORD_HASH TEXT,
      $COL_DISPLAY_NAME TEXT,
      $COL_SESSION_ID TEXT,
      $COL_RAW_JSON TEXT,
      $COL_LAST_LOGIN_AT TEXT
    );
  ''';
}
