import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static final AppInfo _instance = AppInfo._internal();
  factory AppInfo() => _instance;

  AppInfo._internal();

  late final String version;
  late final String buildNumber;
  late final String platform;

  /// Call once at app start
  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();

    _instance.version = packageInfo.version;
    _instance.buildNumber = packageInfo.buildNumber;
    _instance.platform = Platform.isAndroid ? 'android' : 'ios';
  }
}