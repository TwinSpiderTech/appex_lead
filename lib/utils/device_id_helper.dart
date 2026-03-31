import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceIdHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
static String? _deviceId;

  /// Returns the unique device identifier for the current platform.
  /// Result is cached after the first successful retrieval.
  static Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        _deviceId = webInfo.vendor.toString() + webInfo.userAgent.hashCode.toString();
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = androidInfo.id; // Usually a 64-bit number (hex string)
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor; // UUID that persists for the vendor
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        _deviceId = macInfo.systemGUID;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        _deviceId = windowsInfo.deviceId;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        _deviceId = linuxInfo.machineId;
      }
    } catch (e) {
      debugPrint("Error getting device ID: $e");
      _deviceId = "unknown_device";
    }

    return _deviceId ?? "unknown_device";
  }
}
