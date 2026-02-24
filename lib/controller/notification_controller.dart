import 'package:appex_lead/service/api_service.dart';
import 'package:appex_lead/service/notificaion_services.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  NotificationService services = NotificationService();

  Future setupDeviceToken() async {
    String token = await services.getDeviceToken();

    await udpateDeviceToken(token: token);
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await udpateDeviceToken(token: newToken);
    });
    print("Device Token  Updated to User Profile");
  }

  udpateDeviceToken({String? token}) async {
    await ApiServices().updateDeviceToken(token ?? '');
    if (!kDebugMode) {
      await services.subscribeToTopic('all_users');
    }
    await setDataToPrefs(key: deviceToken, value: token, type: 'string');
  }
}
