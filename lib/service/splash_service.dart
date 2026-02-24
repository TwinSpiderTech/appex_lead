// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:appex_lead/utils/auth_service.dart';
import 'package:appex_lead/view/auth/login.dart';
import 'package:appex_lead/view/dashboard.dart';

class SplashService {
  isLogin() async {
    Timer(const Duration(seconds: 3), () async {
      if (await AuthService.isUserLoggedIn()) {
        Get.offAll(const Dashboard());
      } else {
        log("Session Not Found!");
        Get.offAll(const LoginScreen());
      }
    });
  }
}
