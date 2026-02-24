import 'dart:developer';

import 'package:get/get.dart';
import 'package:appex_lead/view/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String tokenKey = 'session_token';
  static const String subdomainKey = 'subdomain';
  static const String emailKey = 'user_email';

  static Future<void> removeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailKey);
  }

  static Future<void> updateSession({
    String? email,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    if (email != null && email.isNotEmpty) {
      await prefs.setString(emailKey, email);
    }
    log("Seesion token updated!");
  }

  static Future<bool> isUserLoggedIn() async {
    var t = await getSessionToken();
    return (t != null && t.isNotEmpty);
  }

  // static Future<String?> getSubdomain() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(subdomainKey);
  // }

  static Future<void> updateSubdomain(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(subdomainKey, value);
    log("Subdomain updated!");
  }

  // static Future<bool> isSubdomainAvailable() async {
  //   var s = await getSubdomain();
  //   return (s != null && s.isNotEmpty);
  // }

  static Future<void> logout() async {
    await removeKey(emailKey);
    await removeKey(tokenKey);
    Get.offAll(() => LoginScreen(), transition: Transition.leftToRight);
  }
}
