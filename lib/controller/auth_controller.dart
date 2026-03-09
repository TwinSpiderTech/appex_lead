import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/auth_service.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/dashboard.dart';

class AuthController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailCont = TextEditingController(),
      passCont = TextEditingController();

  RxBool obscure = true.obs;
  RxBool isLoading = false.obs;

  authenticate({String? email, String? password}) async {
    try {
      if (formKey.currentState!.validate() || kDebugMode) {
        isLoading.value = true;
        var res = await api.authenticate(
          email ?? emailCont.text,
          password ?? passCont.text,
        );
        if (res != null && res['status'] == 200) {
          prettyPrint(res);
          var data = res['data'];
          String email = data['email'] ?? '';
          String token = data['token'] ?? '';
          if (token.isEmpty) {
            log('Token not found!');
            return;
          }
          if (email.isEmpty) {
            log('Token not found!');
            return;
          }

          await AuthService.updateSession(email: email, token: token);
          Get.offAll(() => Dashboard());
        }
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      log(e.toString());
    }
  }
}
