class Const {
  static String DEVICE_ID = "";
  static String PROJECT_URL = "https://app.buzzily.com/Run";
  static String PROJECT_NAME = "axpertqa11";
  static String ARM_URL = "";
  static String GUID = "";
  static String FIREBASE_TOKEN = "";
  static const String CLOUD_PROJECT = "axpmobileclient";
  static const String CLOUD_URL = "";
  static final String SEED_V = "1983";
  static String DUMMY_USER = "admin";
  static const String DUMMYUSER_PWD = "a5ca360e803b868680e2b6f7805fcb9e";

  static final String URL_JSON_OBJECTGETCHOICE = "asbmenurest.dll/datasnap/rest/Tasbmenurest/getchoices";
  static final String SET_HYBRID_INFO = "/Webservice.asmx/SetHybridInfo";
  static final String SET_HYBRID_NOTIFICATION_INFO = "/Webservice.asmx/SetHybridNotifiInfo";
  static final String LOGOUT_LINK = "webservice.asmx/SignOut";
  static String getSQLforClientID(String clientID) =>
      "select * from tblclientMST where " + "clientid = '" + clientID + "'";
  static String getFullARMUrl(String Entrypoint) =>
      ARM_URL.endsWith("/") ? ARM_URL + Entrypoint : ARM_URL + "/" + Entrypoint;
  static String getAppBody() => "{\"Appname\":\"" + PROJECT_NAME + "\"}";

  // static String getSQLforClientID(String clientID) =>
  //     "select projectname, scripts_uri,dbtype, expirydate, notify_uri,web_url,arm_url from tblclientMST   where " +
  //         "clientid = '" + clientID + "'";
}
