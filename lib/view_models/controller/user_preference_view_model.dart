// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreference extends GetxController {
  // Login Status
  Future<bool> setLoggedIn(bool status) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('loggedIn', status);
    return true;
  }

  Future<bool> getIsLoggedIn() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final isLoggedIn = sp.getBool('loggedIn');
    return isLoggedIn ?? false;
  }

  Future<bool> resetLoggedIn() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
    print('SharedPreferences cleared');
    return true;
  }

  // Auth Token
  Future<bool> setAuthToken(String token) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('authToken', token);
    return true;
  }

  Future<String?> getAuthToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final authToken = sp.getString('authToken');
    print(authToken);
    return authToken;
  }

  // Auth Token
  Future<bool> setUsername(String username) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('username', username);
    return true;
  }

  Future<bool> setUserID(String userid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('id', userid);
    return true;
  }

  Future<String?> getUsername() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final username = sp.getString('username');
    return username;
  }

  Future<String?> getUserID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final userid = sp.getString('id');
    return userid;
  }
}
