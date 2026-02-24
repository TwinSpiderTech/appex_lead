import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'package:appex_lead/model/notification_model.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

//
class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotification =
      FlutterLocalNotificationsPlugin();
  //Request permissions
  requestNotification() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted Permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provincial Permission');
      }
    } else {
      if (kDebugMode) {
        print('User denied Permission');
      }
    }
  }

  Future<void> initLocalNotificationOnStart() async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // Fixed channel ID
      'High Importance Notifications', // Channel name
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    // Register the channel with the system
    await flutterLocalNotification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    final androidInit = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosInit = const DarwinInitializationSettings();
    final settings = InitializationSettings(android: androidInit, iOS: iosInit);
    // run when app is open and notificiaon tapped
    await flutterLocalNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(details.payload!);
            if (data['route'] != null && data['route'].toString().isNotEmpty) {
              Get.offAllNamed(
                data['route'],
                // arguments: {
                //   "notification_id": data['notification_id'] ?? '',
                //   "title": data['title'] ?? "",
                //   "body": data['body'] ?? "",
                //   "contentType": data['content_type'] ?? "",
                //   "contentURL": data['content_url'] ?? "",
                //   "extra": data['extra_param'] ?? "",
                // },
              );
            }
          } catch (e) {
            debugPrint("Error parsing notification payload: $e");
          }
        }
      },
    );
  }

  //get token
  getDeviceToken() async {
    String? fcmToken = Platform.isAndroid
        ? await FirebaseMessaging.instance.getToken()
        : await getIosFcmToken();
    print('APNs Token: $fcmToken');

    if (kDebugMode) {
      print(fcmToken);
    }
    print("Device Token://$fcmToken\\");

    return fcmToken ?? '';
  }

  Future<String?> getIosFcmToken() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print("Permission not granted");
      return null;
    }

    String? apnsToken;
    for (int i = 0; i < 10; i++) {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) break;
      await Future.delayed(const Duration(seconds: 1));
    }

    if (apnsToken == null) {
      print("APNs token not set");
      return null;
    }

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }

  //get refreshed token
  isTokenRefreshed() {
    messaging.onTokenRefresh.listen((value) {
      String token = value;
    });
  }

  firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) async {
      print(message.data["title"].toString());
      print(message.data["body"].toString());
      // showMessage(message);
      if (Platform.isAndroid) {
        showMessage(message);
        // initLocalNotification(message);
        // on notificiaon reveice when app open
      }
      if (Platform.isIOS) {
        forgroundMessage();
      }
      await saveNotificationToLocal(message);
    });
    print("Notification initialization//////////////");
  }

  initLocalNotification(RemoteMessage message) {
    final androidInitialization = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosInitialization = const DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    flutterLocalNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Ensure payload exists
        if (details.payload == null || details.payload!.isEmpty) {
          debugPrint("No payload found");
          return;
        }

        // Decode JSON payload safely
        Map<String, dynamic> data = {};
        try {
          data = jsonDecode(details.payload!);
        } catch (e) {
          debugPrint("Payload decode error: $e");
        }

        debugPrint("Foreground notification tapped → $data");

        String route = data["route"] ?? "";
        String title = data["title"] ?? "";
        String body = data["body"] ?? "";
        String contentType = data["content_type"] ?? "";
        String contentURL = data["content_url"] ?? "";
        String extra = data["extra_param"] ?? "";

        if (route.isNotEmpty) {
          Get.offAllNamed(route, arguments: message);
        }
      },
    );
  }

  notificationDetail() async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Highly important channel',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id,
          channel.name,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          sound: channel.sound,
        );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    return notificationDetails;
  }

  showMessage(RemoteMessage message) async {
    String title = (message.notification?.title?.isNotEmpty ?? false)
        ? message.notification?.title
        : message.data["title"] ?? '';
    String body = (message.notification?.body?.isNotEmpty ?? false)
        ? message.notification?.body
        : message.data["body"] ?? '';
    final payload = jsonEncode({
      "route": message.data["route"] ?? "",
      "content_type": message.data["content_type"] ?? "",
      "content_url": message.data["content_url"] ?? "",
      "extra_param": message.data["extra_param"] ?? "",
      "title": title,
      "body": body,
    });

    flutterLocalNotification.show(
      0,
      title,
      body,
      await notificationDetail(),
      payload: payload,
    );
  }

  sendNotification() async {
    flutterLocalNotification.show(
      0,
      "message.notification!.title.toString()",
      "message.notification!.body.toString()",
      await notificationDetail(),
    );
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint("Subscribed to topic: $topic");
  }

  Future<void> saveNotificationToLocal(RemoteMessage message) async {
    String title = (message.notification?.title?.isNotEmpty ?? false)
        ? message.notification?.title
        : message.data["title"] ?? '';
    String body = (message.notification?.body?.isNotEmpty ?? false)
        ? message.notification?.body
        : message.data["body"] ?? '';
    print('====>. Title: $title .<=====');
    print('====>.  Body: $body .<=====');

    // Always return a list from prefs
    final List<dynamic> rawList = await getDecodedListFromPrefs(
      key: localNotificationsKey,
    );

    // Convert dynamic list → List<Map<String, dynamic>>
    List<Map<String, dynamic>> savedList = rawList
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    String notificationId = message.data['notification_id'] ?? '';

    if ((notificationId.isNotEmpty &&
            savedList.any((e) => e['notification_id'] == notificationId)) ||
        title.isEmpty) {
      return;
    } else {
      // Create notification
      NotificationModel notification = NotificationModel(
        id: notificationId,
        title: title,
        description: body,
        contentType: message.data["content_type"] ?? "",
        contentURL: message.data["content_url"] ?? "",
        route: message.data["route"] ?? "",
        time: DateTime.now().toIso8601String(),
        type: message.data["type"],
      );
      prettyPrint(notification.toMap());

      savedList.add(notification.toMap());

      // Save back
      await setDataToPrefsEncoded(key: localNotificationsKey, value: savedList);

      debugPrint("NOTIFICATION SAVED LOCALLY");
    }
  }

  // Fetch Saved Notifications
  Future<List<NotificationModel?>> getSavedNotifications() async {
    List<Map<String, dynamic>> notificaionList =
        List<Map<String, dynamic>>.from(
          await getDecodedListFromPrefs(key: localNotificationsKey),
        );
    List<NotificationModel> notifications = notificaionList
        .map((e) => NotificationModel.fromMap(e))
        .toList();
    return notifications;
  }

  setupInteractMessage() async {
    RemoteMessage? initialMsg = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMsg != null) {
      debugPrint("APP OPENED FROM TERMINATED NOTIFICATION");
      handleNavigation(initialMsg);
    }
  }

  // NAVIGATION HANDLER
  void handleNavigation(RemoteMessage message, {bool saveData = false}) async {
    if (saveData && message.data.isNotEmpty) {
      await saveNotificationToLocal(message);
    }
    String? route = message.data["route"];

    print("Notificaion Payload => ${message} <=");

    if (route != null && route.isNotEmpty) {
      Get.offAllNamed(route, arguments: message);
    }
  }
}
