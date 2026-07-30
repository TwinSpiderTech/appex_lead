import 'package:ts_fieldforce/view/app_settings.dart';
import 'package:ts_fieldforce/view/auth/login.dart';
import 'package:ts_fieldforce/view/complaints/complaint_screen.dart';
import 'package:ts_fieldforce/view/dashboard.dart';
import 'package:ts_fieldforce/view/form/drafts_screen.dart';
import 'package:ts_fieldforce/view/leads/lead_details_screen.dart';
import 'package:ts_fieldforce/view/form/forms.dart';
import 'package:ts_fieldforce/view/internet/no_internet_screen.dart';

import 'package:ts_fieldforce/view/notifications/notificaion_screen.dart';
import 'package:ts_fieldforce/view/notifications/notification_details.dart';

import 'package:ts_fieldforce/view/shared_prefs_screen.dart';
import 'package:ts_fieldforce/view/splash_screen.dart';
import 'package:ts_fieldforce/view/tracking/route_history.dart';
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

  static const noInternet = '/no-internet';
  static const trackingHistory = '/tracking-history';

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

    GetPage(name: appSetting, page: () => AppSettings()),
    GetPage(name: trackingHistory, page: () => const RouteHistoryScreen()),
  ];
}
