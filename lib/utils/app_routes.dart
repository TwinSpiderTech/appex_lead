import 'package:appex_lead/view/app_settings.dart';
import 'package:appex_lead/view/auth/login.dart';
import 'package:appex_lead/view/complaints/complaint_screen.dart';
import 'package:appex_lead/view/dashboard.dart';
import 'package:appex_lead/view/form/drafts_screen.dart';
import 'package:appex_lead/view/form/lead_details_screen.dart';
import 'package:appex_lead/view/form/forms.dart';
import 'package:appex_lead/view/internet/no_internet_screen.dart';

import 'package:appex_lead/view/notifications/notificaion_screen.dart';
import 'package:appex_lead/view/notifications/notification_details.dart';

import 'package:appex_lead/view/shared_prefs_screen.dart';
import 'package:appex_lead/view/splash_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static const splash = '/';
  static const dashboard = '/dashboard';
  static const login = '/login';

  static const appSetting = '/setting';
  static const notificationScreen = '/notifications';
  static const localStorage = '/local_storage';
  static const notification_detail_screen = '/notification_detail';
  static const profile = '/profile';
  static const formsList = '/forms_list';
  static const drafts = '/drafts';
  static const leadShow = '/lead_show';

  static const noInternet = '/no-internet';

  static final routes = [
    GetPage(name: splash, page: () => SplashScreen()),

    GetPage(name: noInternet, page: () => NoInternetScreen()),

    GetPage(name: dashboard, page: () => Dashboard()),

    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: notificationScreen, page: () => NotificationScreen()),

    GetPage(
      name: notification_detail_screen,
      page: () => NotificaionDetailScreen(),
    ),
    GetPage(name: localStorage, page: () => SharePrefScreen()),
    GetPage(name: formsList, page: () => AvailableForms()),
    GetPage(name: drafts, page: () => DraftsScreen()),
    GetPage(
      name: leadShow,
      page: () => LeadDetailsScreen(
        apiData: Get.arguments['leadData'] ?? {},
        title: Get.arguments['title'] ?? "Lead Details",
      ),
    ),
    GetPage(name: appSetting, page: () => AppSettings()),
  ];
}
