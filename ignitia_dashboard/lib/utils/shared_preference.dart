import 'package:shared_preferences/shared_preferences.dart';

class SessionManager{
  static Future<void> clear() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }
  //fcm token
  static Future<String> getFCMToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String authToken;
    authToken = pref.getString("fcmToken") ?? "";
    return authToken;
  }
  static Future<void> setFCMToken(String fcmToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("fcmToken", fcmToken);
  }

  // quick access item list
  static Future<List<String>?> getQuickAccessTitleList() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? quickTitleList;
    quickTitleList = pref.getStringList("quickTitleList");
    return quickTitleList;
  }
  static Future<void> setQuickAccessTitleList(List<String> list) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("quickTitleList", list);
  }

  static Future<List<String>?> getQuickAccessIconList() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? quickIconList;
    quickIconList = pref.getStringList("quickIconList");
    return quickIconList;
  }
  static Future<void> setQuickAccessIconList(List<String> list) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("quickIconList", list);
  }

// access key
  static Future<String> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("token") ?? "";
  }
  static Future<void> setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
  }

  // user info
  static Future<int> getUserId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt("id") ?? 0;
  }
  static Future<void> setUserId(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("id", id);
  }

  static Future<String> getEmployeeId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("employee_id") ?? "";
  }
  static Future<void> setEmployeeId(String employeeId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("employee_id", employeeId);
  }

  static Future<String> getUserName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("name") ?? "";
  }
  static Future<void> setUserName(String userName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", userName);
  }

  static Future<String> getUserDesignation() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("designation") ?? "";
  }
  static Future<void> setUserDesignation(String designation) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("designation", designation);
  }

  //  web app address
  static Future<String> getUserEmail() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("email") ?? "";
  }
  static Future<void> setUserEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", email);
  }

  static Future<int> getUserTypeId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt("type_id") ?? 0;
  }
  static Future<void> setUserTypeId(int typeId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("type_id", typeId);
  }
  static Future<bool> isUserLoggedIn() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("isUserLoggedIn") ?? false;
  }
  static Future<void> setUserLoggedIn(bool isUserLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isUserLoggedIn", isUserLoggedIn);
  }

  static Future<String> getLastLoginTime() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("lastLoginTime") ?? "";
  }
  static Future<void> setLastLoginTime(String lastLoginTime) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("lastLoginTime", lastLoginTime);
  }

  static Future<String> getOfficeStartTime() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("officeStartTime") ?? "09:00";
  }
  static Future<void> setOfficeStartTime(String officeStartTime) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("officeStartTime", officeStartTime);
  }

  static Future<String> getOfficeEndTime() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("officeEndTime") ?? "18:00";
  }
  static Future<void> setOfficeEndTime(String officeEndTime) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("officeEndTime", officeEndTime);
  }

  static Future<String> getOfficeNetwork() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("officeNetwork") ?? "ssle_mobile";
  }
  static Future<void> setOfficeNetwork(String officeNetwork) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("officeNetwork", officeNetwork);
  }

  static Future<bool> getAllowAutoCheckIn() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("allowAutoCheckIn") ?? true;
  }
  static Future<void> setAllowAutoCheckIn(bool allowAutoCheckIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("allowAutoCheckIn", allowAutoCheckIn);
  }

  static Future<bool> getAlertForMissingCheckIn() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("alertForMissingCheckIn") ?? true;
  }
  static Future<void> setAlertForMissingCheckIn(bool alertForMissingCheckIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("alertForMissingCheckIn", alertForMissingCheckIn);
  }

  static Future<bool> getAlertForMissingCheckOut() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("alertForMissingCheckOut") ?? true;
  }
  static Future<void> setAlertForMissingCheckOut(bool alertForMissingCheckOut) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("alertForMissingCheckOut", alertForMissingCheckOut);
  }

  static Future<bool> getAlertForMissingOvertime() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("alertForMissingOvertime") ?? true;
  }
  static Future<void> setAlertForMissingOvertime(bool alertForMissingOvertime) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("alertForMissingOvertime", alertForMissingOvertime);
  }

  // attendance location restriction of the current user
  static Future<String> getAttendanceLocationType() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("attendanceLocationType") ?? "Office";
  }
  static Future<void> setAttendanceLocationType(String attendanceLocationType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("attendanceLocationType", attendanceLocationType);
  }

  static Future<double> getHomeLatitude() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getDouble("homeLatitude") ?? 0;
  }
  static Future<void> setHomeLatitude(double homeLatitude) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("homeLatitude", homeLatitude);
  }

  static Future<double> getHomeLongitude() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getDouble("homeLongitude") ?? 0;
  }
  static Future<void> setHomeLongitude(double homeLongitude) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("homeLongitude", homeLongitude);
  }

  static Future<double> getHomeRadiusMeters() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getDouble("homeRadiusMeters") ?? 300;
  }
  static Future<void> setHomeRadiusMeters(double homeRadiusMeters) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("homeRadiusMeters", homeRadiusMeters);
  }
}