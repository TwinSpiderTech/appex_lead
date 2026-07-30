import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:ts_fieldforce/utils/auth_service.dart';
import 'package:ts_fieldforce/utils/urls.dart';
import 'package:ts_fieldforce/view/auth/login.dart';
import 'package:ts_fieldforce/view/auth/subdomain.dart';
import 'package:ts_fieldforce/view/dashboard.dart';

class SplashService {
  isLogin() async {
    Timer(const Duration(seconds: 3), () async {
      bool subAvailable = await AuthService.isSubdomainAvailable();
      if (subAvailable) {
        String? sub = await AuthService.getSubdomain();
        if (sub != null && sub.isNotEmpty) {
          Urls.currentSubdomain = sub;
        }
        
        if (await AuthService.isUserLoggedIn()) {
          Get.offAll(const Dashboard());
        } else {
          log("Session Not Found!");
          Get.offAll(const LoginScreen());
        }
      } else {
        log("Subdomain Not Configured!");
        Get.offAll(const SubdomainScreen());
      }
    });
  }
}
