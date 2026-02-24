import 'package:appex_lead/component/custom_button.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

import 'package:hugeicons/hugeicons.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42.0),
          child: Column(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedNoSignal,
                color: colorManager.primaryColor,
                size: 160,
              ),
              SizedBox(height: 12),
              Text(
                'No Internet Connection!',
                textAlign: TextAlign.center,
                style: primaryTextStyle.copyWith(
                  color: colorManager.primaryColor,
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Turn ON your internet connection and try again.',
                textAlign: TextAlign.center,
                style: primaryTextStyle.copyWith(
                  fontSize: 18,
                  color: colorManager.textColor,
                  height: 1.4,
                ),
              ),

              // SizedBox(
              //   height: 24,
              // ),
              CustomButton(
                label: 'Refresh',
                onTap: () async {
                  // try {
                  //   showLoading(message: 'Loading...');
                  //   var isIntenetAvailable = await loadDashboardDataFromApi(
                  //     // ApiServices(),
                  //   );
                  //   if (isIntenetAvailable) {
                  //     Get.offAll(Dashboard());
                  //   }
                  // } catch (e) {
                  //   print(e);
                  // }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
