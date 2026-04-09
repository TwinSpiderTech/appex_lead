import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:appex_lead/component/custom_appbar.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:appex_lead/view/shared_prefs_screen.dart';
import 'package:appex_lead/view/auth/login.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorManager.bgDark,
        title: Text(
          "Delete Account",
          style: primaryTextStyle.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
          style: primaryTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: primaryTextStyle),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // close dialog
              final response = await api.deleteAccount();
              if (response != null && response['status'] == 200) {
                await logoutUser(toastMessage: 'Account deleted.');
                Get.offAll(() => const LoginScreen());
              }
            },
            child: Text("Delete", style: primaryTextStyle.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorManager.bgDark,
      appBar: CustomAppBar(canNavigate: true, title: 'Settings'),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                style: primaryTextStyle.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Permanently delete your account",
                style: primaryTextStyle.copyWith(color: Colors.red.withOpacity(0.7), fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }
}
