import 'dart:io';
import 'package:flutter/services.dart';

/// Service interface to communicate with the native platform foreground service
/// for persistent background tracking.
class NativeLocatorService {
  static const MethodChannel _channel = MethodChannel('appex_lead_channel');

  /// Starts the native background service for tracking a specific route ID.
  /// Only runs on Android.
  static Future<bool> startTrackingService(int routeId) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>(
        'startTrackingService',
        {'route_id': routeId},
      );
      return success ?? false;
    } on PlatformException catch (e) {
      print('Failed to start native tracking service: ${e.message}');
      return false;
    }
  }

  /// Stops the native background service.
  /// Only runs on Android.
  static Future<bool> stopTrackingService() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>('stopTrackingService');
      return success ?? false;
    } on PlatformException catch (e) {
      print('Failed to stop native tracking service: ${e.message}');
      return false;
    }
  }
}
