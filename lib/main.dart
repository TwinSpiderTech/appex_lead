import 'dart:convert';
import 'dart:developer';

import 'package:appex_lead/controller/notification_controller.dart';
import 'package:appex_lead/service/app_infor_service.dart';
import 'package:appex_lead/service/notificaion_services.dart';
import 'package:appex_lead/utils/app_routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:appex_lead/controller/theme/theme_controller.dart';
import 'package:appex_lead/service/api_service.dart';

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  await Firebase.initializeApp();

  log("Background message received: ${message.notification?.title}");

  await services.saveNotificationToLocal(message);

  final details = await services.notificationDetail();
  String title = (message.notification?.title?.isNotEmpty ?? false)
      ? message.notification?.title
      : message.data["title"] ?? '';
  String body = (message.notification?.body?.isNotEmpty ?? false)
      ? message.notification?.body
      : message.data["body"] ?? '';
  await services.flutterLocalNotification.show(
    DateTime.now().millisecondsSinceEpoch,
    title,
    body,
    details,
    payload: jsonEncode({
      "route": message.data["route"] ?? "",
      "content_type": message.data["content_type"] ?? "",
      "content_url": message.data["content_url"] ?? "",
      "extra_param": message.data["extra_param"] ?? "",
      "title": title,
      "body": body,
    }),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await services.initLocalNotificationOnStart();
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      services.handleNavigation(message);
    }
  });

  // Listen for notification taps when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    services.handleNavigation(message);
  });
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // await services.forgroundMessage();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  colorManager.loadThemeFromPreferences();
  AppInfo.init();

  runApp(const MyApp());
}

final ColorManager colorManager = Get.put(ColorManager());

NotificationService services = NotificationService();
final notificationController = Get.put(NotificationController());
final ApiServices api = ApiServices();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNonCriticalServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    EasyLoading.instance
      ..backgroundColor = colorManager.primaryColor
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      // ignore: deprecated_member_use
      ..radius = 30
      ..indicatorSize = 50.0
      ..toastPosition = EasyLoadingToastPosition.bottom
      ..animationStyle = EasyLoadingAnimationStyle.scale;
    return GetMaterialApp(
      defaultTransition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
      opaqueRoute: true,
      popGesture: true,
      debugShowCheckedModeBanner: false,
      title: 'Appex Trading',
      theme: ThemeData(
        dialogBackgroundColor: colorManager.bgDark,
        fontFamily: 'SF Pro',
        primaryColor: colorManager.primaryColor,
        scaffoldBackgroundColor: colorManager.bgDark,
        iconTheme: IconThemeData(color: colorManager.iconColor),
        appBarTheme: AppBarTheme(backgroundColor: colorManager.bgDark),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(colorManager.primaryColor),
            foregroundColor: WidgetStatePropertyAll(colorManager.whiteColor),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorManager.primaryColor,
          background: colorManager.bgDark,
        ),
      ),
      getPages: AppPages.routes,
      // home: SplashScreen(),
      initialRoute: '/',
      builder: EasyLoading.init(),
    );
  }
}

Future<void> _initializeNonCriticalServices() async {
  debugPrint("Initializing Firebase Notifications...");
  await services.requestNotification();
  await notificationController.setupDeviceToken();
  await services.firebaseInit();
  await services.setupInteractMessage();
  String token = await services.getDeviceToken();
  debugPrint("\n\n================ FCM TOKEN  ================");
  debugPrint(token);
  debugPrint("====================================================\n\n");
}
