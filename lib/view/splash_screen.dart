// ignore_for_file: file_names

import 'package:appex_lead/controller/app_update_controller.dart';
import 'package:appex_lead/main.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:appex_lead/controller/theme/theme_controller.dart';
import 'package:appex_lead/service/splash_service.dart';
import 'package:appex_lead/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? userId, project;
  String? appVersion, platform;
  var updateCont = Get.put(UpdateController());
  final SplashService _services = SplashService();

  Future updateApp() async {
    if (mounted) {
      debugPrint('AppUpdate');
      appVersion = await updateCont.getAppVersion();
      // requiredVersion = updateCont.serverVersion;
      platform = await updateCont.checkPlatform();

      updateCont.showUpdateMessage().then((value) {
        value
            ? Future.delayed(const Duration(seconds: 5), () async {
                print(updateCont.serverVersion);
                await showBottomSheet(updateCont.serverVersion);
              })
            : null;
      });
    }
    // setState(() {

    // });
  }

  showBottomSheet(String serverVersion) async {
    await Get.bottomSheet(
      isDismissible: false,
      enableDrag: false,
      PopScope(
        onPopInvokedWithResult: (_, __) async => false,
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            color: colorManager.bgDark,
            borderRadius: BorderRadius.circular(12),
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 28.0, left: 28, right: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Available',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorManager.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You are using App version $appVersion. New Version $serverVersion is available on ${platform == "android_app" ? "PlayStore" : "AppStore"}',
                  style: TextStyle(color: colorManager.textColor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        updateCont.LaunchURL(updateCont.appUpdateURL);
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(color: colorManager.whiteColor),
                      ),
                    ),
                    const SizedBox(width: 18),
                    if (updateCont.appStatus != 'mandatory_update')
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: colorManager.whiteColor),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((value) {
      if (updateCont.appStatus == 'mandatory_update') {
        Future.delayed(const Duration(milliseconds: 100), () {
          showBottomSheet(serverVersion);
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    updateApp();

    _services.isLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ColorManager(),
      builder: (cont) {
        return Scaffold(
          backgroundColor: cont.bgDark,
          body: Center(
            child: Image.asset(cont.appLogo, height: 150, width: 150),
          ),
          floatingActionButton: tsWatermark(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
