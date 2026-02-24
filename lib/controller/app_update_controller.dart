import 'dart:developer';
import 'dart:io';

import 'package:appex_lead/service/api_service.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:url_launcher/url_launcher.dart';

class UpdateController extends GetxController {
  ApiServices apiServices = ApiServices();
  String serverVersion = '';
  String appStatus = '';
  String appUpdateURL = '';
  checkPlatform() {
    if (Platform.isAndroid) {
      var platform = "android_app";
      return platform;
    } else {
      var platform = "ios_app";

      return platform;
    }
  }

  getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    var appVersion = packageInfo.version;
    return appVersion;
  }

  showUpdateMessage() async {
    // return true;
    var appVersion = await getAppVersion();

    // updated appdetails in sharedPrefs

    var appVersionNumber = getExtendedVersionNumber(appVersion);
    var platform = checkPlatform();
    var res = await apiServices.getAppVersions(platform);
    print(res);
    if (res != null &&
        res['data'].isNotEmpty &&
        res['data'].containsKey("app_status") &&
        res['data']['app_status'] == 'under_maintenance') {
      await setDataToPrefs(key: 'maintenance_mode', value: true, type: 'bool');
      // Get.offAll(() => MaintenanceScreen());
    }
    prettyPrint(res ?? {});
    var sVersion = res?['data']['app_version'] ?? '';
    appUpdateURL = res?['data']['app_url'] ?? '';
    appStatus = res?['data']['app_status'] ?? '';
    serverVersion = sVersion.toString();
    log("Server Version : $serverVersion");
    var requiredVersion = getExtendedVersionNumber(sVersion ?? "0");

    log("appVerequiredVersion : $requiredVersion");
    log("appVersionNumber:$appVersionNumber");
    log(appVersionNumber.toString());
    update();
    // return true;
    if (appVersionNumber < requiredVersion) {
      print(true);
      return true;
    } else {
      print(false);

      return false;
    }
  }

  int getExtendedVersionNumber(String version) {
    // ignore: unnecessary_null_comparison

    if (version.isEmpty) {
      return 0;
    }
    assert(version != null);

    final List<String> versionCells = version.split('.');
    final List<int> parsedCells = versionCells.map(int.parse).toList();

    int extendedVersionNumber = 0;
    int multiplier = 1;

    // Loop through each version component in reverse order
    for (int i = parsedCells.length - 1; i >= 0; i--) {
      extendedVersionNumber += parsedCells[i] * multiplier;
      multiplier *= 1000; // Update multiplier for the next component
    }

    return extendedVersionNumber;
  }

  LaunchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
