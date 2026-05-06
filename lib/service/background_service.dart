import 'dart:async';
import 'dart:ui';
import 'package:appex_lead/service/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TrackingService {
  static const String channelId = 'tracking_foreground_service';
  static const int notificationId = 888;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'Route Tracking',
      description: 'This channel is used for route tracking notifications.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: channelId,
        initialNotificationTitle: 'Route Tracking Active',
        initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    final db = DbHelper();
    int? currentRouteId;

    // Check if there is an active route to resume, or start a new one
    final activeRoutes = await db.getActiveRoutes();
    if (activeRoutes.isNotEmpty) {
      currentRouteId = activeRoutes.first['id'] as int;
    } else {
      currentRouteId = await db.startNewRoute();
    }

    // Start listening to location
    StreamSubscription<Position>? positionStream;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15, // Update every 15 meters
      ),
    ).listen((Position position) async {
      // Save point to DB
      await db.insertPoint({
        'route_id': currentRouteId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'speed': position.speed,
        'accuracy': position.accuracy,
      });

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "Route Tracking Active",
            content: "Last Point: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
          );
        }
      }

      // Broadcast to UI if app is open
      service.invoke('update', {
        "latitude": position.latitude,
        "longitude": position.longitude,
      });
    });

    service.on('stopTracking').listen((event) async {
      positionStream?.cancel();
      if (currentRouteId != null) {
        await db.endRoute(currentRouteId!);
      }
      service.stopSelf();
    });
  }
}
