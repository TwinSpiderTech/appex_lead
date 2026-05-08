import 'dart:async';
import 'dart:ui';
import 'package:appex_lead/service/db_helper.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
class RouteController extends GetxController {
  final DbHelper _db = DbHelper();

  var isTracking = false.obs;
  var currentRouteId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _checkServiceStatus();
    _setupServiceListeners();
  }

  void _setupServiceListeners() {
    final service = FlutterBackgroundService();
    
    service.on('started').listen((event) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_tracking_manual_enabled', true);
      isTracking.value = true;
    });

    service.on('stopped').listen((event) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_tracking_manual_enabled', false);
      isTracking.value = false;
    });
  }

  Future<void> _checkServiceStatus() async {
    final service = FlutterBackgroundService();
    final prefs = await SharedPreferences.getInstance();
    bool shouldBeTracking = prefs.getBool('is_tracking_manual_enabled') ?? false;
    bool running = await service.isRunning();
    
    if (shouldBeTracking && !running) {
      // User wants tracking, but service is not running (likely app was killed or device restarted)
      print("RouteController: Auto-restarting tracking service...");
      await service.startService();
      isTracking.value = true;
    } else if (!shouldBeTracking && running) {
      // Service is running but shouldn't be (unlikely, but for safety)
      service.invoke('stopTracking');
      isTracking.value = false;
    } else if (!shouldBeTracking && !running) {
      // Nothing should be running, clean up any "active" routes left in DB
      final activeRoutes = await _db.getActiveRoutes();
      for (var route in activeRoutes) {
        await _db.endRoute(route['id'] as int);
      }
      isTracking.value = false;
    } else {
      // Status is correct (Running and should be running)
      isTracking.value = true;
    }
  }

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tracking_channel',
      'Route Tracking',
      description: 'Records your movement in the background.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onServiceStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'tracking_channel',
        initialNotificationTitle: 'Tracking Active',
        initialNotificationContent: 'Recording your route...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onServiceStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onServiceStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    
    final db = DbHelper();
    int? routeId;
    StreamSubscription<Position>? positionStream;

    service.on('stopTracking').listen((event) async {
      print("Background Service: Received stopTracking");
      await positionStream?.cancel();
      if (routeId != null) await db.endRoute(routeId!);
      service.invoke('stopped');
      service.stopSelf();
    });

    // Start tracking logic
    try {
      print("Background Service: Initializing tracking...");
      
      // Check if there is an existing active route to resume
      final activeRoutes = await db.getActiveRoutes();
      if (activeRoutes.isNotEmpty) {
        routeId = activeRoutes.first['id'] as int;
        print("Background Service: Resuming active route #$routeId");
      } else {
        routeId = await db.startNewRoute();
        print("Background Service: Started new route #$routeId");
      }
      
      service.invoke('started', {"route_id": routeId});

      // Optimized settings for background
      positionStream = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          forceLocationManager: true, // More stable in background for some devices
          intervalDuration: const Duration(seconds: 5),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "Route tracking is running in background",
            notificationTitle: "Appex Tracking",
            enableWakeLock: true,
          ),
        ),
      ).listen(
        (Position position) async {
          await db.insertPoint({
            'route_id': routeId,
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
                content: "Recorded: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
              );
            }
          }
        },
        onError: (e) {
          print("Background Service: Stream Error: $e");
        },
      );
    } catch (e) {
      print("Background Service: Fatal Error: $e");
      service.stopSelf();
    }
  }

  Future<void> toggleTracking() async {
    final service = FlutterBackgroundService();
    final prefs = await SharedPreferences.getInstance();
    bool isRunning = await service.isRunning();

    if (isRunning) {
      service.invoke('stopTracking');
      await prefs.setBool('is_tracking_manual_enabled', false);
      // Wait a bit for the service to actually stop
      await Future.delayed(const Duration(milliseconds: 500));
      isTracking.value = false;
      showToast(message: "Route Tracking Stopped!");
    } else {
      // Permission check
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      bool started = await service.startService();
      if (started) {
        await prefs.setBool('is_tracking_manual_enabled', true);
        isTracking.value = true;
        showToast(message: "Route Tracking Started!");
      } else {
        showToast(message: "Failed to start tracking service");
      }
    }
  }
}
