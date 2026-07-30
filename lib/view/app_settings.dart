import 'package:ts_fieldforce/controller/tracking/route_controller.dart';
import 'package:ts_fieldforce/view/tracking/route_history.dart';
import 'package:ts_fieldforce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ts_fieldforce/component/custom_appbar.dart';
import 'package:ts_fieldforce/main.dart';
import 'package:ts_fieldforce/utils/helpers.dart';
import 'package:ts_fieldforce/view/shared_prefs_screen.dart';
import 'package:ts_fieldforce/view/auth/login.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final cont = Get.find<RouteController>();
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(canNavigate: true, title: 'Settings'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() {
              final isTracking = cont.isTracking.value;
              return ListTile(
                onTap: () {},
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isTracking ? Colors.green : Colors.grey)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedLocation01,
                    color: isTracking ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text(
                  "Route Tracking",
                  style: primaryTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isTracking
                      ? "Recording your movement in background"
                      : "Tap to start tracking movement",
                  style: primaryTextStyle.copyWith(
                    color: colorManager.textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                trailing: Switch(
                  value: isTracking,
                  onChanged: (val) => cont.toggleTracking(),
                  activeColor: colorManager.primaryColor,
                ),
              );
            }),

            // const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete02,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: Text(
                "Delete Account",
                style: primaryTextStyle.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Permanently delete your account",
                style: primaryTextStyle.copyWith(
                  color: Colors.red.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.red,
              ),
              onTap: () => deleteAccountPopup(context),
            ),
          ],
        ),
      ),
    );
  }
}
