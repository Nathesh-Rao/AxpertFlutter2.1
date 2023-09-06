import 'package:get_storage/get_storage.dart';

class AppStorage {
  static String projectList = "ProjectList";
  static String cached = "Cached";
  static String token = "Token";
  static String sessionId = "SessionID";
  static String userID = "userID";
  static String userPass = "userPass";
  static String userName = "UserName";
  var box;

  AppStorage() {
    box = GetStorage();
  }
  storeValue(String key, var value) {
    box.write(key, value);
  }

  dynamic retrieveValue(String key) {
    return box.read(key);
  }

  remove(String key) {
    box.remove(key);
  }
}
