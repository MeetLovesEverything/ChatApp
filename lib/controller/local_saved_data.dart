import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSavedData{
  static SharedPreferences? preferences;

  static Future<void> init() async{
    preferences = await SharedPreferences.getInstance();
  }

  static Future saveUserId(String id) async
  {
    await preferences!.setString("userId", id);
  }

  static Future<String> getUserId() async
  {
    return preferences!.getString("userId") ?? "";
  }

  static Future saveUserName(String name) async
  {
    await preferences!.setString("name", name);
  }

  static Future<String> getUserName() async
  {
    return preferences!.getString("name") ?? "";
  }

  static Future saveUserPhone(String phone) async
  {
    await preferences!.setString("phone", phone);
  }

  static Future<String> getUserPhone() async
  {
    return preferences!.getString("phone") ?? "";
  }

  static Future saveUserProfile(String profile) async
  {
    await preferences!.setString("profile", profile);
  }

  static Future<String> getUserProfile() async
  {
    return preferences!.getString("profile") ?? "";
  }

  static clearALlData() async{
    final bool data = await preferences!.clear();
    print("Cleared all data from local data : $data");
  }
}
